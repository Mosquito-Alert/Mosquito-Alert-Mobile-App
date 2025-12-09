import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/features/reports/data/models/base_report_request.dart';

class BreedingSiteReportRequest
    extends BaseReportWithPhotosRequest<BreedingSite> {
  final BreedingSiteSiteTypeEnum siteType;
  final bool? hasWater;
  final bool? inPublicArea;
  final bool? hasNearMosquitoes;
  final bool? hasLarvae;

  BreedingSiteReportRequest({
    required super.createdAt,
    required super.location,
    required super.photos,
    required this.siteType,
    required this.hasWater,
    required this.hasLarvae,
    this.inPublicArea,
    this.hasNearMosquitoes,
    String? note,
    List<String>? tags,
  });
}
