import 'package:mosquito_alert_app/core/adapters/observation_report.dart';
import 'package:mosquito_alert_app/features/reports/presentation/state/report_provider.dart';
import 'package:mosquito_alert_app/features/observations/observation_repository.dart';

class ObservationProvider
    extends ReportProvider<ObservationReport, ObservationRepository> {
  ObservationProvider({required super.repository});

  Future<ObservationReport> createObservation(
      {required ObservationReportRequest request}) async {
    final newObservation = await repository.create(request: request);
    addItem(newObservation);
    return newObservation;
  }
}
