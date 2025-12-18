import 'mutation_queue.dart';
import 'mutation.dart';
import '../model/sync_model.dart';

class InMemoryMutationQueue<T extends SyncModel>
    implements MutationQueue<T> {
  final List<Mutation<T>> _queue = [];

  @override
  Future<void> add(Mutation<T> mutation) async {
    _queue.add(mutation);
  }

  @override
  Future<List<Mutation<T>>> pending() async {
    return List.unmodifiable(_queue);
  }

  @override
  Future<void> remove(Mutation<T> mutation) async {
    _queue.remove(mutation);
  }
}
