import '../model/sync_model.dart';

enum MutationType { create, update, delete }

class Mutation<T extends SyncModel> {
  final MutationType type;
  final T? item;
  final String? id;
  final DateTime createdAt;

  Mutation.create(this.item)
      : type = MutationType.create,
        id = null,
        createdAt = DateTime.now();

  Mutation.update(this.item)
      : type = MutationType.update,
        id = item?.id,
        createdAt = DateTime.now();

  Mutation.delete(this.id)
      : type = MutationType.delete,
        item = null,
        createdAt = DateTime.now();
}
