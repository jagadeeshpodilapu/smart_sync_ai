import 'package:flutter/material.dart';
import 'package:smart_sync_ai/smart_sync_ai.dart';

import 'todo.dart';
import 'todo_local_store.dart';
import 'todo_remote_adapter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final localStore = InMemoryTodoLocalStore();
  final remoteAdapter = MockTodoRemoteAdapter();

  // Register collection with engine
  SyncEngine.I.registerCollection<Todo>(
    name: 'todos',
    localStore: localStore,
    remoteAdapter: remoteAdapter,
    config: const SyncConfig<Todo>(),
  );

  runApp(TodoExampleApp(localStore: localStore, remoteAdapter: remoteAdapter));
}

class TodoExampleApp extends StatelessWidget {
  final InMemoryTodoLocalStore localStore;
  final MockTodoRemoteAdapter remoteAdapter;

  const TodoExampleApp({
    super.key,
    required this.localStore,
    required this.remoteAdapter,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'smart_sync_ai Example',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: TodoHomePage(localStore: localStore, remoteAdapter: remoteAdapter),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  final InMemoryTodoLocalStore localStore;
  final MockTodoRemoteAdapter remoteAdapter;

  const TodoHomePage({
    super.key,
    required this.localStore,
    required this.remoteAdapter,
  });

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  List<Todo> _todos = [];
  bool _loading = true;
  bool _online = true;
  String? _syncMessage;
  SyncStatus _status = SyncStatus.idle;

  @override
  void initState() {
    super.initState();
    _loadLocal();
    SyncEngine.I.events.listen((event) {
      if (event.collection == 'todos') {
        setState(() {
          _status = event.status;
          _syncMessage = event.message;
        });
      }
    });
  }

  Future<void> _loadLocal() async {
    final items = await widget.localStore.getAll();
    setState(() {
      _todos = items;
      _loading = false;
    });
  }

  Future<void> _addTodo() async {
    final textController = TextEditingController();

    final title = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Todo'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, textController.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (title == null || title.isEmpty) return;

    final todo = Todo(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      done: false,
      updatedAt: DateTime.now(),
      version: 1,
    );

    await SyncEngine.I.create<Todo>('todos', todo);
    await _loadLocal();
  }

  Future<void> _toggleDone(Todo todo) async {
    final updated = todo.copyWith(
      done: !todo.done,
      updatedAt: DateTime.now(),
      version: todo.version + 1,
    );

    await SyncEngine.I.update<Todo>('todos', updated);
    await _loadLocal();
  }

  Future<void> _deleteTodo(Todo todo) async {
    await SyncEngine.I.delete<Todo>('todos', todo.id);
    await _loadLocal();
  }

  Future<void> _syncNow() async {
    await SyncEngine.I.syncNow();
    await _loadLocal();
  }

  void _toggleOnline(bool value) {
    setState(() {
      _online = value;
      widget.remoteAdapter.setOnline(value);
    });
  }

  String _statusText() {
    switch (_status) {
      case SyncStatus.idle:
        return 'Idle';
      case SyncStatus.syncing:
        return 'Syncing…';
      case SyncStatus.error:
        return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (_status) {
      SyncStatus.idle => Colors.green,
      SyncStatus.syncing => Colors.orange,
      SyncStatus.error => Colors.red,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('smart_sync_ai Example'),
        actions: [
          Row(
            children: [
              const Text('Online'),
              Switch(value: _online, onChanged: _toggleOnline),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(
              'Sync status: ${_statusText()}',
              style: TextStyle(color: statusColor),
            ),
            subtitle: _syncMessage != null ? Text(_syncMessage!) : null,
            trailing: ElevatedButton.icon(
              onPressed: _syncNow,
              icon: const Icon(Icons.sync),
              label: const Text('Sync Now'),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _todos.isEmpty
                ? const Center(child: Text('No todos yet'))
                : ListView.builder(
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      final todo = _todos[index];
                      return Dismissible(
                        key: ValueKey(todo.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _deleteTodo(todo),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: CheckboxListTile(
                          value: todo.done,
                          title: Text(todo.title),
                          subtitle: Text(
                            'Updated: ${todo.updatedAt.toLocal()}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          onChanged: (_) => _toggleDone(todo),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
