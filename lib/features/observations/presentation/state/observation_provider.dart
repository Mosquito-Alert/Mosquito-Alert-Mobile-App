import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/core/adapters/observation_report.dart';
import 'package:mosquito_alert_app/features/reports/presentation/state/report_provider.dart';
import 'package:mosquito_alert_app/features/observations/observation_repository.dart';

class ObservationProvider extends ReportProvider<ObservationReport> {
  ObservationProvider({required ObservationRepository repository})
      : super(
            repository: repository,
            itemFactory: (item) => ObservationReport(item as Observation));

  Future<ObservationReport> createObservation(
      {required ObservationReportRequest request}) async {
    final rawObservation =
        await (repository as ObservationRepository).create(request: request);
    final observationReport = itemFactory!(rawObservation);
    addItem(observationReport);
    return observationReport;
  }
}
