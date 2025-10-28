import 'package:flutter/material.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/pages/reports/shared/widgets/location_selector.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';

/// Shared location selection page that can be used by any report workflow
/// Configurable location handling through callbacks
class LocationSelectionPage extends StatefulWidget {
  final LocationRequest? initialLocationRequest;
  final Function(LocationRequest locationRequest) onLocationSelected;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool canProceed;
  final String? locationDescription;

  const LocationSelectionPage({
    Key? key,
    this.initialLocationRequest,
    required this.onLocationSelected,
    required this.onNext,
    required this.onPrevious,
    required this.canProceed,
    this.locationDescription,
  }) : super(key: key);

  @override
  _LocationSelectionPageState createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  void _handleLocationSelected(
      double latitude, double longitude, LocationRequestSource_Enum source) {
    // Create LocationRequest object here instead of in the controller
    final locationRequest = LocationRequest((b) => b
      ..source_ = source
      ..point.latitude = latitude
      ..point.longitude = longitude);

    // Pass the LocationRequest object to the callback
    widget.onLocationSelected(locationRequest);
  }

  @override
  Widget build(BuildContext context) {
    // Extract initial values from LocationRequest if available
    final initialLatitude = widget.initialLocationRequest?.point.latitude;
    final initialLongitude = widget.initialLocationRequest?.point.longitude;

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen map background (WhatsApp style)
          LocationSelector(
            initialLatitude: initialLatitude,
            initialLongitude: initialLongitude,
            onLocationSelected: _handleLocationSelected,
            autoGetLocation: true, // Enable auto-location by default
          ),

          // Bottom overlay with location info and navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: Style.button(
                    MyLocalizations.of(context, 'continue_txt'),
                    widget.canProceed ? widget.onNext : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
