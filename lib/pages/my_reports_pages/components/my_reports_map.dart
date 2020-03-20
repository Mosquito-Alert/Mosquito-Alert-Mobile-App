import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyReportsMap extends StatefulWidget {
  List<Marker> markers; 

  MyReportsMap(this.markers);
  @override
  _MyReportsMapState createState() => _MyReportsMapState();
}

class _MyReportsMapState extends State<MyReportsMap> {
  GoogleMapController controller;

  // List<Marker> markers = [
  //   Marker(
  //     markerId: MarkerId('marker01'),
  //     position: LatLng(41.1613063, 0.4724329),
  //   ),
  //   Marker(
  //     markerId: MarkerId('marker02'),
  //     position: LatLng(41.1613063, 0.5224329),
  //   )
  // ];

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
        markers: Set<Marker>.of(widget.markers));
        
  }
}
