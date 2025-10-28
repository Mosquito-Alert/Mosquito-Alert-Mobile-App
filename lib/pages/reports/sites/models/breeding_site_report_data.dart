import 'dart:io';

import 'package:mosquito_alert/mosquito_alert.dart';

class BreedingSiteReportData {
  // Step 1: Site type
  String? siteType; // 'storm_drain' or 'other'

  // Step 2: Photos
  List<File> photos = [];

  // Step 3: Water presence
  bool? hasWater; // true = yes, false = no

  // Step 3.1: Larvae presence (only asked if hasWater == true)
  bool? hasLarvae; // true = yes, false = no

  // Step 4: Location
  LocationRequest? locationRequest;

  // Step 5: Notes
  String? notes;

  // Metadata
  DateTime createdAt = DateTime.now();

  /// Validates if the report data is complete enough to submit
  bool get isValid {
    return siteType != null &&
        photos.isNotEmpty &&
        hasWater != null &&
        // If water is present, larvae question must be answered
        (hasWater == false || hasLarvae != null) &&
        locationRequest != null;
  }

  /// Gets a user-friendly location description
  String get locationDescription {
    if (locationRequest != null) {
      return '${locationRequest!.point.latitude.toStringAsFixed(4)}, ${locationRequest!.point.longitude.toStringAsFixed(4)}';
    }
    return 'No location selected';
  }

  /// Gets a user-friendly site type description
  String get siteTypeDescription {
    switch (siteType) {
      case 'storm_drain':
        return 'Storm drain';
      case 'other':
        return 'Other';
      default:
        return 'No site type selected';
    }
  }

  /// Gets a user-friendly water status description
  String get waterStatusDescription {
    if (hasWater == null) return 'Water status not selected';
    return hasWater! ? 'Water present' : 'No water';
  }

  /// Gets a user-friendly larvae status description
  String get larvaeStatusDescription {
    if (hasLarvae == null) return 'Larvae status not selected';
    return hasLarvae! ? 'Larvae visible' : 'No larvae visible';
  }

  /// Resets all data
  void reset() {
    siteType = null;
    photos.clear();
    hasWater = null;
    hasLarvae = null;
    locationRequest = null;
    notes = null;
    createdAt = DateTime.now();
  }

  /// Creates a copy of the current data
  BreedingSiteReportData copy() {
    final copy = BreedingSiteReportData();
    copy.siteType = siteType;
    copy.photos = List.from(photos);
    copy.hasWater = hasWater;
    copy.hasLarvae = hasLarvae;
    copy.locationRequest = locationRequest;
    copy.notes = notes;
    copy.createdAt = createdAt;
    return copy;
  }
}
