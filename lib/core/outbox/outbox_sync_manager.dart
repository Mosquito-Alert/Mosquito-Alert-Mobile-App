import 'package:mosquito_alert_app/core/outbox/outbox_mixin.dart';

class OutboxSyncManager {
  final List<OutboxMixin> _repositories;

  OutboxSyncManager(this._repositories);

  Future<void> syncAll() async {
    for (final repo in _repositories) {
      await repo.syncRepository();
    }
  }
}
