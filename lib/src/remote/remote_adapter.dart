import '../model/sync_model.dart';

abstract class RemoteAdapter<T extends SyncModel> {
  Future<List<T>> fetchAll();
  Future<T> createRemote(T item);
  Future<T> updateRemote(T item);
  Future<void> deleteRemote(String id);
}
