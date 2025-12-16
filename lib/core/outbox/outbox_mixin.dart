import 'package:mosquito_alert_app/core/outbox/outbox_item.dart';
import 'package:mosquito_alert_app/core/outbox/outbox_service.dart';

mixin OutboxMixin {
  final OutboxService outbox = OutboxService();

  /// Each repository must return a unique name
  String get repoName;

  /// Repository must implement method dispatcher
  Future<void> execute(OutboxItem item) async {
    await unscheduleOutboxTask(item);
  }

  Future<void> schedule(
    String operation,
    Map<String, dynamic> payload, {
    bool runNow = true,
  }) async {
    final outboxItem = await outbox.add(repoName, operation, payload);
    if (!runNow) return;
    try {
      await execute(outboxItem);
    } catch (_) {
      // Do nothing
    }
  }

  Future<void> unscheduleOutboxTask(OutboxItem item) async {
    await outbox.remove(item.id);
  }

  Future<void> syncRepository() async {
    final items = outbox
        .getAll()
        .where((i) => i.repository == repoName)
        .toList();

    for (final item in items) {
      try {
        await execute(item);
      } catch (_) {
        // Do nothing
      }
    }
  }
}
