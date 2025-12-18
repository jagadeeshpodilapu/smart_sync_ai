import 'package:smart_sync_ai/smart_sync_ai.dart';
import 'todo.dart';

class InMemoryTodoLocalStore implements LocalStore<Todo> {
  final Map<String, Todo> _items = {};

  @override
  Future<Todo?> get(String id) async {
    return _items[id];
  }

  @override
  Future<List<Todo>> getAll() async {
    return _items.values.toList()
      ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
  }

  @override
  Future<void> upsert(Todo item) async {
    _items[item.id] = item;
  }

  @override
  Future<void> delete(String id) async {
    _items.remove(id);
  }
}
