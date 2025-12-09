import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/features/reports/data/models/base_report_request.dart';

class ObservationReportRequest
    extends BaseReportWithPhotosRequest<Observation> {
  final ObservationEventEnvironmentEnum? eventEnvironment;
  final ObservationEventMomentEnum? eventMoment;

  ObservationReportRequest({
    required super.createdAt,
    required super.location,
    required super.photos,
    required this.eventEnvironment,
    required this.eventMoment,
    String? note,
    List<String>? tags,
  });
}
