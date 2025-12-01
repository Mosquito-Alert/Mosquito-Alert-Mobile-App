import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/core/adapters/breeding_site_report.dart';
import 'package:mosquito_alert_app/features/reports/presentation/state/report_provider.dart';
import 'package:mosquito_alert_app/features/breeding_sites/breeding_site_repository.dart';

class BreedingSiteProvider extends ReportProvider<BreedingSiteReport> {
  BreedingSiteProvider({required BreedingSiteRepository repository})
      : super(
            repository: repository,
            itemFactory: (item) => BreedingSiteReport(item as BreedingSite));
}
