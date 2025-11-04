import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';

/// Shared widgets for report detail pages
class ReportDetailWidgets {
  /// Builds a leading image widget for report lists
  /// Shows the first photo from the report or falls back to a default asset
  static Widget buildLeadingImage({
    required dynamic report,
  }) {
    final photos = report.photos;

    if (photos.isEmpty) {
      // Fallback to default icon
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!, width: 2),
          borderRadius: BorderRadius.circular(15),
          color: Colors.grey[50],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.hide_image, size: 30, color: Colors.grey[600]),
          ],
        ),
      );
    }

    // Use the first photo from the report
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: photos.first.url,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey.withValues(alpha: 0.3),
          child: Icon(
            Icons.photo_camera,
            size: 20,
            color: Colors.grey,
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey.withValues(alpha: 0.3),
          child: Icon(
            Icons.hide_image,
            size: 20,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

/// Shared utility methods for report formatting
class ReportUtils {
  static String formatLocationCoordinates(dynamic report) {
    final point = report.location.point;
    return '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
  }

  /// Format location with city name or fallback to coordinates
  static Future<String> formatLocationWithCity(dynamic report) async {
    // First try to get the display name from the location object
    final displayName = report.location.displayName;
    if (displayName != null && displayName.isNotEmpty) {
      final parts = displayName.split(',').map((p) => p.trim()).toList();
      final first = parts.isNotEmpty ? parts.first : '';
      final last = parts.length > 1 ? parts.last : '';

      return last.isNotEmpty ? '$first, $last' : first;
    }

    // Fall back to reverse geocoding using coordinates
    final point = report.location.point;
    try {
      final cityName =
          await Utils.getCityNameFromCoords(point.latitude, point.longitude);
      if (cityName != null && cityName.isNotEmpty) {
        return cityName;
      }
    } catch (e) {
      print('Error getting city name: $e');
    }

    // Final fallback to coordinates
    return formatLocationCoordinates(report);
  }

  static String? getHashtag(dynamic report) {
    final tags = report.tags;
    if (tags == null || tags.isEmpty) {
      return null;
    }
    // Join multiple tags with spaces, adding # prefix to each
    return tags.map((tag) => '#$tag').join(' ');
  }
}
