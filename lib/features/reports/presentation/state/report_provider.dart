import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:mosquito_alert_app/core/models/base_report.dart';
import 'package:mosquito_alert_app/features/reports/report_repository.dart';
import 'package:mosquito_alert_app/core/providers/pagination_provider.dart';

abstract class ReportProvider<T extends BaseReportModel,
        RepositoryType extends ReportRepository<T, dynamic, dynamic>>
    extends PaginatedProvider<T, RepositoryType> {
  ReportProvider({
    required super.repository,
  }) : super(orderFunction: (items) {
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return items;
        });

  Future<void> delete({required T item}) async {
    await repository.delete(uuid: item.uuid);

    deleteItem(item);

    // Analytics logging
    await FirebaseAnalytics.instance.logEvent(
      name: 'delete_report',
      parameters: {'report_uuid': item.uuid},
    );
  }
}
