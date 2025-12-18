import 'dart:async';

import '../model/sync_model.dart';
import '../model/sync_config.dart';
import '../storage/mutation.dart';
import '../storage/mutation_queue.dart';
import '../storage/in_memory_mutation_queue.dart';
import '../storage/local_store.dart';
import '../remote/remote_adapter.dart';
import 'sync_event.dart';

class SyncEngine {
  SyncEngine._();
  static final SyncEngine I = SyncEngine._();

  final _collections = <String, _SyncCollection>{};
  final _events = StreamController<SyncEvent>.broadcast();

  Stream<SyncEvent> get events => _events.stream;

  void registerCollection<T extends SyncModel>({
    required String name,
    required LocalStore<T> localStore,
    required RemoteAdapter<T> remoteAdapter,
    SyncConfig<T> config = const SyncConfig(),
  }) {
    _collections[name] = _SyncCollection<T>(
      name: name,
      localStore: localStore,
      remoteAdapter: remoteAdapter,
      config: config,
      queue: InMemoryMutationQueue<T>(),
      emit: _events.add,
    );
  }

  // 🔥 Offline-safe APIs

  Future<void> create<T extends SyncModel>(String name, T item) async {
    final col = _collections[name] as _SyncCollection<T>;
    await col.localStore.upsert(item);
    await col.queue.add(Mutation.create(item));
  }

  Future<void> update<T extends SyncModel>(String name, T item) async {
    final col = _collections[name] as _SyncCollection<T>;
    await col.localStore.upsert(item);
    await col.queue.add(Mutation.update(item));
  }

  Future<void> delete<T extends SyncModel>(String name, String id) async {
    final col = _collections[name] as _SyncCollection<T>;
    await col.localStore.delete(id);
    await col.queue.add(Mutation.delete(id));
  }

  // 🔁 Manual sync
  Future<void> syncNow() async {
    for (final col in _collections.values) {
      await col.sync();
    }
  }
}

// ================= INTERNAL =================

class _SyncCollection<T extends SyncModel> {
  final String name;
  final LocalStore<T> localStore;
  final RemoteAdapter<T> remoteAdapter;
  final SyncConfig<T> config;
  final MutationQueue<T> queue;
  final void Function(SyncEvent) emit;

  _SyncCollection({
    required this.name,
    required this.localStore,
    required this.remoteAdapter,
    required this.config,
    required this.queue,
    required this.emit,
  });

  Future<void> sync() async {
    emit(SyncEvent(name, SyncStatus.syncing));

    try {
      final pending = await queue.pending();

      for (final mutation in pending) {
        if (mutation.type == MutationType.create) {
          await remoteAdapter.createRemote(mutation.item as T);
        }

        if (mutation.type == MutationType.update) {
          await remoteAdapter.updateRemote(mutation.item as T);
        }

        if (mutation.type == MutationType.delete) {
          await remoteAdapter.deleteRemote(mutation.id!);
        }

        await queue.remove(mutation);
      }

      emit(SyncEvent(name, SyncStatus.idle));
    } catch (e) {
      emit(SyncEvent(name, SyncStatus.error, message: e.toString()));
    }
  }
}
