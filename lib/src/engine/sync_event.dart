enum SyncStatus { idle, syncing, error }

class SyncEvent {
  final String collection;
  final SyncStatus status;
  final String? message;

  SyncEvent(
    this.collection,
    this.status, {
    this.message,
  });
}
