import 'package:flutter/src/widgets/framework.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/core/models/base_report.dart';
import 'package:mosquito_alert_app/core/models/base_report_request.dart';
import 'package:mosquito_alert_app/core/localizations/MyLocalizations.dart';

class BreedingSiteReport extends BaseReportWithPhotos<BreedingSite> {
  BreedingSiteReport(BreedingSite raw) : super(raw);

  @override
  String getTitle(BuildContext context) {
    return MyLocalizations.of(context, 'single_breeding_site');
  }
}

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
