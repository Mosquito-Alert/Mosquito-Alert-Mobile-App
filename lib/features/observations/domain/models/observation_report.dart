import 'package:flutter/material.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/features/reports/domain/models/base_report.dart';
import 'package:mosquito_alert_app/core/localizations/MyLocalizations.dart';

class ObservationReport extends BaseReportWithPhotos<Observation> {
  ObservationReport(Observation raw) : super(raw);

  @override
  String getTitle(BuildContext context) {
    if (raw.identification == null) {
      return MyLocalizations.of(context, 'non_identified_specie');
    }

    // Navigate through nested nullable fields
    final identification = raw.identification;
    final result = identification?.result;
    final taxon = result?.taxon;
    final nameValue = taxon?.nameValue;

    if (nameValue == null || nameValue.isEmpty) {
      return MyLocalizations.of(context, 'non_identified_specie');
    }

    return nameValue;
  }

  @override
  bool get titleItalicized {
    return raw.identification?.result?.taxon?.italicize ?? false;
  }

  String? getLocalizedEnvironment(BuildContext context) {
    switch (raw.eventEnvironment) {
      case ObservationEventEnvironmentEnum.vehicle:
        return MyLocalizations.of(context, 'question_13_answer_131');
      case ObservationEventEnvironmentEnum.indoors:
        return MyLocalizations.of(context, 'question_13_answer_132');
      case ObservationEventEnvironmentEnum.outdoors:
        return MyLocalizations.of(context, 'question_13_answer_133');
      default:
        return null;
    }
  }
}
