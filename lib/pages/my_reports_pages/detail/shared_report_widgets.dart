import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

/// Shared widgets for report detail pages
class ReportDetailWidgets {
  /// Builds an info item card with icon, optional title, and content
  static Widget buildInfoItem({
    required IconData icon,
    String? title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Style.colorPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Style.colorPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: title != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        content,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  )
                : Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Builds a combined location widget with address text and map
  static Widget buildLocationWidget({
    required BuildContext context,
    required double latitude,
    required double longitude,
    required String locationText,
    required bool isLoadingLocation,
    String? markerId,
  }) {
    final location = LatLng(latitude, longitude);
    final markerIdValue = markerId ?? 'report_location';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Address/Location text section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Style.colorPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: Style.colorPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        MyLocalizations.of(context, 'location_txt'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      isLoadingLocation
                          ? Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Style.colorPrimary),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('...'),
                              ],
                            )
                          : Text(
                              locationText,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Map section
          Container(
            height: 200,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: location,
                  zoom: 15.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(markerIdValue),
                    position: location,
                    infoWindow: InfoWindow(
                      title: MyLocalizations.of(context, 'location_txt'),
                    ),
                  ),
                },
                // Disable all interactions to make it a static view
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                zoomGesturesEnabled: false,
                scrollGesturesEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                myLocationButtonEnabled: false,
                myLocationEnabled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
  // Groups reports into a map keyed by "Day Month Year"
  static Map<String, List<dynamic>> groupByMonth(List<dynamic> reports) {
    final sorted = reports.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final formatter = DateFormat('dd MMMM yyyy');
    final Map<String, List<dynamic>> grouped = {};
    for (final report in sorted) {
      final key = formatter.format(report.createdAt);
      grouped.putIfAbsent(key, () => []).add(report);
    }
    return grouped;
  }

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

  static String formatDate(dynamic report) {
    return DateFormat('yyyy-MM-dd HH:mm').format(report.createdAtLocal);
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
