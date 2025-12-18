import '../model/sync_model.dart';

abstract class LocalStore<T extends SyncModel> {
  Future<T?> get(String id);
  Future<List<T>> getAll();
  Future<void> upsert(T item);
  Future<void> delete(String id);
}
