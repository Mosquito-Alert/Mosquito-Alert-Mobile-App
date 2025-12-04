import 'package:mosquito_alert_app/core/adapters/breeding_site_report.dart';
import 'package:mosquito_alert_app/features/reports/presentation/state/report_provider.dart';
import 'package:mosquito_alert_app/features/breeding_sites/breeding_site_repository.dart';

class BreedingSiteProvider
    extends ReportProvider<BreedingSiteReport, BreedingSiteRepository> {
  BreedingSiteProvider({required super.repository});

  Future<BreedingSiteReport> createBreedingSite(
      {required BreedingSiteReportRequest request}) async {
    final newBreedingSite = await repository.create(request: request);
    addItem(newBreedingSite);
    return newBreedingSite;
  }
}
