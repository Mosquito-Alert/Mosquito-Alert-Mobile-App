import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';

import '../models/adult_report_data.dart';
import '../widgets/map_location_picker.dart';

class LocationSelectionPage extends StatefulWidget {
  final AdultReportData reportData;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const LocationSelectionPage({
    Key? key,
    required this.reportData,
    required this.onNext,
    required this.onPrevious,
  }) : super(key: key);

  @override
  _LocationSelectionPageState createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  bool _isGettingLocation = false;
  String? _locationError;
  final _latController = TextEditingController();
  final _lonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill if location already exists
    if (widget.reportData.latitude != null) {
      _latController.text = widget.reportData.latitude!.toStringAsFixed(6);
    }
    if (widget.reportData.longitude != null) {
      _lonController.text = widget.reportData.longitude!.toStringAsFixed(6);
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _locationError = null;
    });

    try {
      // Check location services
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 30),
      );

      setState(() {
        widget.reportData.latitude = position.latitude;
        widget.reportData.longitude = position.longitude;
        widget.reportData.locationSource = 'auto';
        _latController.text = position.latitude.toStringAsFixed(6);
        _lonController.text = position.longitude.toStringAsFixed(6);
      });
    } catch (e) {
      setState(() {
        _locationError = e.toString();
      });
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  void _updateManualLocation() {
    final lat = double.tryParse(_latController.text);
    final lon = double.tryParse(_lonController.text);

    if (lat != null && lon != null) {
      setState(() {
        widget.reportData.latitude = lat;
        widget.reportData.longitude = lon;
        widget.reportData.locationSource = 'manual';
      });
    }
  }

  Future<void> _selectLocationOnMap() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPicker(
          initialLatitude: widget.reportData.latitude,
          initialLongitude: widget.reportData.longitude,
          onLocationSelected: (latitude, longitude) {
            setState(() {
              widget.reportData.latitude = latitude;
              widget.reportData.longitude = longitude;
              widget.reportData.locationSource = 'manual';
              _latController.text = latitude.toStringAsFixed(6);
              _lonController.text = longitude.toStringAsFixed(6);
            });
          },
        ),
      ),
    );
  }

  bool get _canProceed =>
      widget.reportData.latitude != null && widget.reportData.longitude != null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instructions
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Location Selection',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Select where you found the mosquito. You can use your current GPS location or enter coordinates manually.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Location selection buttons
          Row(
            children: [
              // GPS Location Button
              Expanded(
                child: _isGettingLocation
                    ? ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          disabledBackgroundColor: Colors.grey[400],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('(HC) Getting...'),
                          ],
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _getCurrentLocation,
                        icon: Icon(Icons.gps_fixed),
                        label: Text('(HC) Use GPS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
              ),
              SizedBox(width: 12),
              // Map Selection Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _selectLocationOnMap,
                  icon: Icon(Icons.map),
                  label: Text('(HC) Select on Map'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          if (_locationError != null) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                border: Border.all(color: Colors.red[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _locationError!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 20),

          // Manual location input
          Text(
            'Or enter coordinates manually:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _latController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Latitude',
                    border: OutlineInputBorder(),
                    hintText: '41.385064',
                  ),
                  onChanged: (value) => _updateManualLocation(),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _lonController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Longitude',
                    border: OutlineInputBorder(),
                    hintText: '2.173404',
                  ),
                  onChanged: (value) => _updateManualLocation(),
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Current location display
          if (_canProceed) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border.all(color: Colors.green[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Location Selected',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '(HC) Coordinates: ${widget.reportData.locationDescription}',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    '(HC) Source: ${widget.reportData.locationSource == 'auto' ? 'GPS' : 'Manual'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],

          Spacer(),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onPrevious,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('(HC) Back'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _canProceed ? widget.onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: Text(
                    MyLocalizations.of(context, 'continue_txt'),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
