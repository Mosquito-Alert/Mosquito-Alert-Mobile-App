import 'package:flutter/src/widgets/framework.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/core/models/base_report.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';

class BreedingSiteReport extends BaseReportWithPhotos<BreedingSite> {
  BreedingSiteReport(BreedingSite raw) : super(raw);

  @override
  String get uuid => raw.uuid;

  @override
  String get shortId => raw.shortId;

  @override
  String get userUuid => raw.userUuid;

  @override
  DateTime get createdAt => raw.createdAt;

  @override
  DateTime get createdAtLocal => raw.createdAtLocal;

  @override
  DateTime get sentAt => raw.sentAt;

  @override
  DateTime get receivedAt => raw.receivedAt;

  @override
  DateTime get updatedAt => raw.updatedAt;

  @override
  Location get location => raw.location;

  @override
  String? get note => raw.note;

  @override
  List<String>? get tags => raw.tags?.toList();

  @override
  String getTitle(BuildContext context) {
    return MyLocalizations.of(context, 'single_breeding_site');
  }
}
