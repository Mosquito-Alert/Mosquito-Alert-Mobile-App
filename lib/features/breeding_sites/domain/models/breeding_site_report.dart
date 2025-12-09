import 'package:flutter/src/widgets/framework.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/features/reports/domain/models/base_report.dart';
import 'package:mosquito_alert_app/core/localizations/MyLocalizations.dart';

class BreedingSiteReport extends BaseReportWithPhotos<BreedingSite> {
  BreedingSiteReport(BreedingSite raw) : super(raw);

  @override
  String getTitle(BuildContext context) {
    return MyLocalizations.of(context, 'single_breeding_site');
  }
}
