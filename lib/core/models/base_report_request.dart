import 'package:mosquito_alert/mosquito_alert.dart' as sdk;
import 'package:mosquito_alert_app/core/models/base_report.dart';
import 'package:mosquito_alert_app/core/models/photo.dart';

abstract class BaseReportRequest<T> extends BaseReport<T> {
  final sdk.LocationRequest location;

  BaseReportRequest({
    required this.location,
    required super.createdAt,
    super.note,
    super.tags,
  });
}

abstract class BaseReportWithPhotosRequest<T> extends BaseReportRequest<T> {
  List<BaseUploadPhoto> photos;

  BaseReportWithPhotosRequest({
    required this.photos,
    required super.location,
    required super.createdAt,
    super.note,
    super.tags,
  });
}
