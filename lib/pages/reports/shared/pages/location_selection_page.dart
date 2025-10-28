import 'package:flutter/material.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/pages/reports/shared/widgets/location_selector.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';

/// Shared location selection page that can be used by any report workflow
/// Configurable location handling through callbacks
class LocationSelectionPage extends StatefulWidget {
  // New interface - preferred
  final LocationRequest? initialLocationRequest;
  final Function(LocationRequest locationRequest)? onLocationRequestSelected;
  
  // Legacy interface - for backward compatibility
  final double? initialLatitude;
  final double? initialLongitude;
  final Function(
          double latitude, double longitude, LocationRequestSource_Enum source)?
      onLocationSelected;
  final LocationRequestSource_Enum? locationSource;
  
  // Common interface
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool canProceed;
  final String? locationDescription;

  const LocationSelectionPage({
    Key? key,
    this.initialLocationRequest,
    this.onLocationRequestSelected,
    this.initialLatitude,
    this.initialLongitude,
    this.onLocationSelected,
    this.locationSource,
    required this.onNext,
    required this.onPrevious,
    required this.canProceed,
    this.locationDescription,
  }) : assert(
          (onLocationRequestSelected == null) != (onLocationSelected == null),
          'Must provide either onLocationRequestSelected or onLocationSelected, but not both',
        ),
        super(key: key);

  @override
  _LocationSelectionPageState createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  void _handleLocationSelected(
      double latitude, double longitude, LocationRequestSource_Enum source) {
    // If using new interface, create LocationRequest object
    if (widget.onLocationRequestSelected != null) {
      final locationRequest = LocationRequest((b) => b
        ..source_ = source
        ..point.latitude = latitude
        ..point.longitude = longitude);
      widget.onLocationRequestSelected!(locationRequest);
    } else {
      // Legacy interface - pass individual parameters
      widget.onLocationSelected!(latitude, longitude, source);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract initial values - support both new and legacy interfaces
    final initialLatitude = widget.initialLocationRequest?.point.latitude ??
        widget.initialLatitude;
    final initialLongitude = widget.initialLocationRequest?.point.longitude ??
        widget.initialLongitude;

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
