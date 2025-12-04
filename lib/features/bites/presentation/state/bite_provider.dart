import 'package:mosquito_alert_app/core/adapters/bite_report.dart';
import 'package:mosquito_alert_app/features/reports/presentation/state/report_provider.dart';
import 'package:mosquito_alert_app/features/bites/bite_repository.dart';

class BiteProvider extends ReportProvider<BiteReport, BiteRepository> {
  BiteProvider({required super.repository});

  Future<BiteReport> createBite({required BiteReportRequest request}) async {
    final newBite = await repository.create(request: request);
    addItem(newBite);
    return newBite;
  }
}
