import 'dart:async';

import 'package:smart_sync_ai/smart_sync_ai.dart';
import 'todo.dart';

class MockTodoRemoteAdapter implements RemoteAdapter<Todo> {
  final Map<String, Todo> _remote = {};
  bool online = true;
  Duration latency = const Duration(milliseconds: 500);

  void setOnline(bool value) => online = value;

  void _requireOnline() {
    if (!online) {
      throw Exception('No network connectivity (mock).');
    }
  }

  @override
  Future<List<Todo>> fetchAll() async {
    _requireOnline();
    await Future.delayed(latency);
    return _remote.values.toList()
      ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
  }

  @override
  Future<Todo> createRemote(Todo item) async {
    _requireOnline();
    await Future.delayed(latency);
    _remote[item.id] = item;
    return item;
  }

  @override
  Future<Todo> updateRemote(Todo item) async {
    _requireOnline();
    await Future.delayed(latency);
    _remote[item.id] = item;
    return item;
  }

  @override
  Future<void> deleteRemote(String id) async {
    _requireOnline();
    await Future.delayed(latency);
    _remote.remove(id);
  }

  // Helper for debugging in example
  List<Todo> get remoteItems => _remote.values.toList();
}
