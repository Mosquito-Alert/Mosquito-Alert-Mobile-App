import 'package:mosquito_alert/mosquito_alert.dart' as api;

class BiteReportData {
  // Bite counts by body part
  int headCount = 0;
  int leftArmCount = 0;
  int rightArmCount = 0;
  int chestCount = 0;
  int leftLegCount = 0;
  int rightLegCount = 0;

  // Location
  double? latitude;
  double? longitude;
  api.LocationRequestSource_Enum locationSource =
      api.LocationRequestSource_Enum.auto;

  // Environment question (where did the biting occur)
  api.BiteRequestEventEnvironmentEnum? eventEnvironment;

  // Event timing (when did the biting occur)
  api.BiteRequestEventMomentEnum? eventMoment;

  // Notes
  String? notes;

  // Metadata
  DateTime createdAt = DateTime.now();

  /// Gets total number of bites across all body parts
  int get totalBites {
    return headCount +
        leftArmCount +
        rightArmCount +
        chestCount +
        leftLegCount +
        rightLegCount;
  }

  /// Validates if the report data is complete enough to submit
  bool get isValid {
    return totalBites > 0 &&
        latitude != null &&
        longitude != null &&
        eventEnvironment != null &&
        eventMoment != null;
  }

  /// Gets a user-friendly location description
  String get locationDescription {
    if (latitude != null && longitude != null) {
      return '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}';
    }
    return 'No location selected';
  }

  /// Checks if bite counts step is complete
  bool get hasValidBiteCounts {
    return totalBites > 0;
  }

  /// Checks if location step is complete
  bool get hasValidLocation {
    return latitude != null && longitude != null;
  }

  /// Checks if environment question is answered
  bool get hasValidEnvironment {
    return eventEnvironment != null;
  }

  /// Checks if timing question is answered
  bool get hasValidTiming {
    return eventMoment != null;
  }

  /// Resets all data
  void reset() {
    headCount = 0;
    leftArmCount = 0;
    rightArmCount = 0;
    chestCount = 0;
    leftLegCount = 0;
    rightLegCount = 0;
    latitude = null;
    longitude = null;
    locationSource = api.LocationRequestSource_Enum.auto;
    eventEnvironment = null;
    eventMoment = null;
    notes = null;
    createdAt = DateTime.now();
  }

  /// Creates a copy of the current data
  BiteReportData copy() {
    final copy = BiteReportData();
    copy.headCount = headCount;
    copy.leftArmCount = leftArmCount;
    copy.rightArmCount = rightArmCount;
    copy.chestCount = chestCount;
    copy.leftLegCount = leftLegCount;
    copy.rightLegCount = rightLegCount;
    copy.latitude = latitude;
    copy.longitude = longitude;
    copy.locationSource = locationSource;
    copy.eventEnvironment = eventEnvironment;
    copy.eventMoment = eventMoment;
    copy.notes = notes;
    copy.createdAt = createdAt;
    return copy;
  }
}
