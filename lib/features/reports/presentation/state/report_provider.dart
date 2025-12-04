import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:mosquito_alert_app/core/models/base_report.dart';
import 'package:mosquito_alert_app/features/reports/report_repository.dart';
import 'package:mosquito_alert_app/core/providers/pagination_provider.dart';

abstract class ReportProvider<T extends BaseReportModel>
    extends PaginatedProvider<T> {
  ReportProvider({
    required ReportRepository repository,
    required super.itemFactory,
  }) : super(
            repository: repository,
            orderFunction: (items) {
              items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              return items;
            });

  Future<void> delete({required T item}) async {
    await (repository as ReportRepository).delete(uuid: item.uuid);

    deleteItem(item);

    // Analytics logging
    await FirebaseAnalytics.instance.logEvent(
      name: 'delete_report',
      parameters: {'report_uuid': item.uuid},
    );
  }
}
