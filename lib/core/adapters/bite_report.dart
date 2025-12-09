import 'package:flutter/material.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/core/models/base_report.dart';
import 'package:mosquito_alert_app/core/models/base_report_request.dart';
import 'package:mosquito_alert_app/core/localizations/MyLocalizations.dart';

class BiteReport extends BaseReportModel<Bite> {
  BiteReport(Bite raw) : super(raw);

  @override
  String getTitle(BuildContext context) {
    final totalBites = raw.counts.total;
    String text;

    if (totalBites == 0) {
      text = MyLocalizations.of(context, 'no_bites');
    } else if (totalBites == 1) {
      text = '1 ${MyLocalizations.of(context, 'single_bite').toLowerCase()}';
    } else {
      text =
          '$totalBites ${MyLocalizations.of(context, 'plural_bite').toLowerCase()}';
    }
    return text;
  }

  String? getLocalizedEnvironment(BuildContext context) {
    switch (raw.eventEnvironment) {
      case BiteEventEnvironmentEnum.vehicle:
        return MyLocalizations.of(context, 'question_13_answer_131');
      case BiteEventEnvironmentEnum.indoors:
        return MyLocalizations.of(context, 'question_13_answer_132');
      case BiteEventEnvironmentEnum.outdoors:
        return MyLocalizations.of(context, 'question_13_answer_133');
      default:
        return null;
    }
  }

  String? getEventMoment(BuildContext context) {
    switch (raw.eventMoment) {
      case BiteEventMomentEnum.now:
        return MyLocalizations.of(context, 'question_5_answer_51');
      case BiteEventMomentEnum.lastMorning:
        return MyLocalizations.of(context, 'question_3_answer_31');
      case BiteEventMomentEnum.lastMidday:
        return MyLocalizations.of(context, 'question_3_answer_32');
      case BiteEventMomentEnum.lastAfternoon:
        return MyLocalizations.of(context, 'question_3_answer_33');
      case BiteEventMomentEnum.lastNight:
        return MyLocalizations.of(context, 'question_3_answer_34');
      default:
        return null;
    }
  }
}

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
