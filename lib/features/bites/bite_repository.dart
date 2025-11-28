import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/core/repositories/report_repository.dart';

class BiteRepository extends ReportRepository<BitesApi> {
  BiteRepository({required MosquitoAlert apiClient})
      : super(itemApi: apiClient.getBitesApi());
}
