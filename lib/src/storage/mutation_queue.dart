import 'mutation.dart';
import '../model/sync_model.dart';

abstract class MutationQueue<T extends SyncModel> {
  Future<void> add(Mutation<T> mutation);
  Future<List<Mutation<T>>> pending();
  Future<void> remove(Mutation<T> mutation);
}
