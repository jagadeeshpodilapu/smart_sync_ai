import 'conflict_strategy.dart';
import 'sync_model.dart';

typedef ConflictResolver<T extends SyncModel> = T Function(
  T local,
  T remote,
);

class SyncConfig<T extends SyncModel> {
  final ConflictStrategy strategy;
  final ConflictResolver<T>? resolver;

  const SyncConfig({
    this.strategy = ConflictStrategy.lastWriteWins,
    this.resolver,
  });
}
