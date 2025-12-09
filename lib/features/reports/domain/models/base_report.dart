import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mosquito_alert/mosquito_alert.dart' as sdk;
import 'package:mosquito_alert_app/features/reports/domain/models/photo.dart';

abstract class BaseReport<T> {
  final DateTime createdAt;
  // final DateTime sentAt;
  final String? note;
  final List<String>? tags;

  BaseReport({
    required this.createdAt,
    this.note,
    this.tags,
  });
}

abstract class BaseReportModel<T> extends BaseReport<T> {
  final T raw;
  BaseReportModel(this.raw)
      : super(
          createdAt: (raw as dynamic).createdAt,
          note: (raw as dynamic).note,
          tags: ((raw as dynamic).tags)?.toList(),
        );

  String get pk => uuid;

  String get uuid => (raw as dynamic).uuid;
  String get shortId => (raw as dynamic).shortId;
  String get userUuid => (raw as dynamic).userUuid;
  DateTime get createdAtLocal => (raw as dynamic).createdAtLocal;
  DateTime get sentAt => (raw as dynamic).sentAt;
  DateTime get receivedAt => (raw as dynamic).receivedAt;
  DateTime get updatedAt => (raw as dynamic).updatedAt;
  sdk.Location get location => (raw as dynamic).location;
  String? get note => (raw as dynamic).note;
  List<String>? get tags => (raw as dynamic).tags?.toList();

  String getTitle(BuildContext context);
  bool get titleItalicized => false;

  Future<String> get locationDisplayName async {
    String? cityName;
    String? countryName;

    // 1. Try using administrative boundaries first
    final admBoundaries = location.admBoundaries;
    if (admBoundaries.isNotEmpty) {
      try {
        // Use the most specific administrative boundary available
        final cityBoundary = admBoundaries.firstWhere(
          (adm) => adm.level == 4 && adm.code == 'NUTS',
        );
        cityName = cityBoundary.nameValue;
      } catch (_) {
        // No city-level boundary found
      }
      countryName = location.country?.nameEn;
      if (cityName != null && countryName != null) {
        return '$cityName, $countryName';
      }
    }

    // 2. Use displayName if available (preferred human-readable name)
    final displayName = location.displayName;
    if (displayName != null && displayName.isNotEmpty) {
      final parts = displayName.split(',').map((p) => p.trim()).toList();
      if (parts.isNotEmpty) cityName = parts.first;
      if (parts.length > 1) countryName = parts.last;
      if (cityName != null && countryName != null) {
        return '$cityName, $countryName';
      }
    }

    // 3. Fallback: Reverse geocoding from coordinates
    final point = location.point;
    try {
      final placemarks =
          await placemarkFromCoordinates(point.latitude, point.longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        cityName ??= placemark.locality?.trim();
        countryName ??= placemark.country?.trim();
        if (cityName != null && countryName != null) {
          return '$cityName, $countryName';
        }
      }
    } catch (e) {
      print('Error getting city name: $e');
    }

    // 4. Final fallback: just coordinates if no name found
    if (cityName != null && countryName != null)
      return '$cityName, $countryName';
    if (cityName != null) return cityName;
    if (countryName != null) return countryName;

    return '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
  }
}

abstract class BaseReportWithPhotos<T> extends BaseReportModel<T> {
  BaseReportWithPhotos(T raw) : super(raw);

  List<BasePhoto>? get photos =>
      ((raw as dynamic).photos as BuiltList<sdk.SimplePhoto>?)
          ?.map((photo) => BasePhoto.fromSimplePhoto(photo))
          .toList();

  BasePhoto? get thumbnail {
    if (photos != null && photos!.isNotEmpty) {
      return photos!.first;
    }
    return null;
  }
}
