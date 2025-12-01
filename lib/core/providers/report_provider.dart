import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:mosquito_alert_app/core/models/base_report.dart';
import 'package:mosquito_alert_app/core/repositories/report_repository.dart';
import 'package:mosquito_alert_app/core/providers/pagination_provider.dart';

abstract class ReportProvider<T extends BaseReport>
    extends PaginatedProvider<T> {
  ReportProvider({
    required ReportRepository repository,
    super.itemFactory,
  }) : super(repository: repository);

  Future<void> delete({required T item}) async {
    await (repository as ReportRepository).delete(uuid: item.uuid);

    // Analytics logging
    await FirebaseAnalytics.instance.logEvent(
      name: 'delete_report',
      parameters: {'report_uuid': item.uuid},
    );
  }
}
