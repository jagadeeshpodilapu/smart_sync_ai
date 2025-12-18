import 'package:smart_sync_ai/smart_sync_ai.dart';

class Todo extends SyncModel {
  @override
  final String id;

  final String title;
  final bool done;

  @override
  final DateTime updatedAt;

  @override
  final int version;

  Todo({
    required this.id,
    required this.title,
    required this.done,
    required this.updatedAt,
    required this.version,
  });

  Todo copyWith({
    String? title,
    bool? done,
    DateTime? updatedAt,
    int? version,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      done: done ?? this.done,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }
}
