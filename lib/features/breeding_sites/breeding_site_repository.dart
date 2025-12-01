import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/features/reports/report_repository.dart';

class BreedingSiteRepository extends ReportRepository<BreedingSitesApi> {
  BreedingSiteRepository({required MosquitoAlert apiClient})
      : super(itemApi: apiClient.getBreedingSitesApi());
}
