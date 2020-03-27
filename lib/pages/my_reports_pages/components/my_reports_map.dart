import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyReportsMap extends StatelessWidget {
  List<Marker> markers;

  MyReportsMap(this.markers);

  GoogleMapController controller;

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      mapToolbarEnabled: false,
      initialCameraPosition: const CameraPosition(
        target: LatLng(41.1613063, 0.4724329),
        zoom: 12.0,
      ),
      markers: Set<Marker>.of(markers),
    );
  }
}
