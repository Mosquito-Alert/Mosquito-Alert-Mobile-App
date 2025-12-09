import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/features/reports/data/models/base_report_request.dart';

class BiteReportRequest extends BaseReportRequest<Bite> {
  final BiteRequestEventEnvironmentEnum? eventEnvironment;
  final BiteRequestEventMomentEnum? eventMoment;
  final BiteCountsRequest counts;

  BiteReportRequest({
    required super.location,
    required super.createdAt,
    required this.eventEnvironment,
    required this.eventMoment,
    required this.counts,
    String? note,
    List<String>? tags,
  });
}
