import 'package:mosquito_alert/mosquito_alert.dart' as sdk;

class FixRequest {
  final String coverageUuid;
  final DateTime createdAt;
  final sdk.FixLocationRequest point;
  final double? power;

  FixRequest({
    required this.coverageUuid,
    required this.createdAt,
    required sdk.FixLocationRequest point,
    this.power,
  }) : point = point.rebuild((b) {
         // Mask coordinates to 0.025 degrees
         final maskedLatitude = (point.latitude / 0.025).round() * 0.025;
         final maskedLongitude = (point.longitude / 0.025).round() * 0.025;

         b
           ..latitude = maskedLatitude
           ..longitude = maskedLongitude;
       });
}
