import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyReportsMap extends StatefulWidget {
  @override
  _MyReportsMapState createState() => _MyReportsMapState();
}

class _MyReportsMapState extends State<MyReportsMap> {
  GoogleMapController controller;

  Marker marker;

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,

      initialCameraPosition: const CameraPosition(
        target: LatLng(41.1613063, 0.4724329),
        zoom: 14.0,
      ),
      // markers: Set<Marker>.of(marker.values),
    );
  }
}
