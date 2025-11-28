import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/core/repositories/report_repository.dart';

class BreedingSiteRepository extends ReportRepository<BreedingSitesApi> {
  BreedingSiteRepository({required MosquitoAlert apiClient})
      : super(itemApi: apiClient.getBreedingSitesApi());
}
