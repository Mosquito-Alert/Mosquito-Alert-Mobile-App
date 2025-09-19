import 'dart:io';

/// Independent adult report data model - no dependencies on legacy Utils or models
class AdultReportData {
  // Step 1: Photos
  List<File> photos = [];

  // Step 2: Location
  double? latitude;
  double? longitude;
  String locationSource = 'auto'; // 'auto' or 'manual'

  // Step 3: Environment question
  String? environmentAnswer; // 'vehicle', 'building', 'outdoors'

  // Step 4: Notes
  String? notes;

  // Metadata
  DateTime createdAt = DateTime.now();

  /// Validates if the report data is complete enough to submit
  bool get isValid {
    return photos.isNotEmpty &&
        latitude != null &&
        longitude != null &&
        environmentAnswer != null;
  }

  /// Gets a user-friendly location description
  String get locationDescription {
    if (latitude != null && longitude != null) {
      return '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}';
    }
    return 'No location selected';
  }

  /// Gets environment answer display text
  String get environmentDisplayText {
    switch (environmentAnswer) {
      case 'vehicle':
        return 'Inside a vehicle';
      case 'building':
        return 'In a building';
      case 'outdoors':
        return 'Outdoors';
      default:
        return 'Not selected';
    }
  }

  /// Resets all data
  void reset() {
    photos.clear();
    latitude = null;
    longitude = null;
    locationSource = 'auto';
    environmentAnswer = null;
    notes = null;
    createdAt = DateTime.now();
  }

  /// Creates a copy of the current data
  AdultReportData copy() {
    final copy = AdultReportData();
    copy.photos = List.from(photos);
    copy.latitude = latitude;
    copy.longitude = longitude;
    copy.locationSource = locationSource;
    copy.environmentAnswer = environmentAnswer;
    copy.notes = notes;
    copy.createdAt = createdAt;
    return copy;
  }
}
