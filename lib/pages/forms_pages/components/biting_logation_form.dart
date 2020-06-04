import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/small_question_option_widget.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class BitingLocationForm extends StatefulWidget {
  final Function setValid;

  BitingLocationForm(this.setValid);

  @override
  _BitingLocationFormState createState() => _BitingLocationFormState();
}

enum LocationType { current, selected, missing }

class _BitingLocationFormState extends State<BitingLocationForm> {
  GoogleMapController controller;
  List<Marker> markers = [];

  Position location;
  Position currentLocation;

  Set<Circle> circles;

  StreamController<LocationType> streamType =
      StreamController<LocationType>.broadcast();

  @override
  void initState() {
    super.initState();
    Utils.getLocation();
    currentLocation = Utils.location;

    if (Utils.report != null) {
      switch (Utils.report.location_choice) {
        case "selected":
          streamType.add(LocationType.selected);
          updateMarker(LatLng(Utils.report.selected_location_lat,
              Utils.report.selected_location_lon));
          currentLocation = Position(
              latitude: Utils.report.selected_location_lat,
              longitude: Utils.report.selected_location_lon);
          // widget.setValid(true);
          break;
        case "current":
          streamType.add(LocationType.current);
          updateMarker(LatLng(Utils.report.current_location_lat,
              Utils.report.current_location_lon));
          currentLocation = Position(
              latitude: Utils.report.current_location_lat,
              longitude: Utils.report.current_location_lon);
          // widget.setValid(true);
          break;
        default:
          streamType.add(LocationType.missing);
      }
      if (Utils.report.responses.any((r) => r.question_id == 5)) {
        Utils.report.responses.forEach((q) {
          if (q.question_id == 5) {
            var res = q.answer_value
                .substring(q.answer_value.indexOf('( ') + 2,
                    q.answer_value.indexOf(')'))
                .split(', ');
            markers.add(new Marker(
                markerId: MarkerId('mk'),
                position: LatLng(double.parse(res[0]), double.parse(res[1]))));
          }
        });
      }
    } else {
      _getCurrentLocation();
    }
  }

  _getCurrentLocation() async {
    Position loc;
    Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;

    bool geolocationEnabled = await geolocator.isLocationServiceEnabled();

    if (geolocationEnabled) {
      Geolocator geolocator = Geolocator()..forceAndroidLocationManager = false;
      loc = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } else {
      await Utils.getLocation();
      loc = Utils.location;
    }
    if (loc != null) {
      controller.animateCamera(
          CameraUpdate.newLatLng(LatLng(loc.latitude, loc.longitude)));
    }
    setState(() {
      currentLocation = loc;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _getCurrentLocation();
    setState(() {
      this.controller = controller;
    });
  }

  updateMarker(LatLng markerPosition) {
    Marker mk = Marker(
        markerId: MarkerId('mk${markers.length}'), position: markerPosition);

    if (Utils.report.selected_location_lat != null &&
        Utils.report.type == "bite") {
      Utils.addLocationResponse(mk.position.latitude, mk.position.longitude);
      setState(() {
        markers.add(mk);
      });
    } else {
      Utils.setSelectedLocation(mk.position.latitude, mk.position.longitude);
      widget.setValid(true);

      setState(() {
        markers = [mk];
      });
    }
  }

  getPosition(type, {context}) async {
    streamType.add(type);
    List<Marker> currentMarkers = [];

    if (type == LocationType.current) {
      Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;

      bool geolocationEnabled = await geolocator.isLocationServiceEnabled();
      streamType.add(type);

      if (geolocationEnabled) {
        Geolocator geolocator = Geolocator()
          ..forceAndroidLocationManager = false;
        Position currentPosition = await Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        print(currentPosition);
        Utils.setCurrentLocation(
            currentPosition.latitude, currentPosition.longitude);
        widget.setValid(true);
        controller.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
                target:
                    LatLng(currentPosition.latitude, currentPosition.longitude),
                zoom: 16.0),
          ),
        );

        currentMarkers = [
          Marker(
              markerId: MarkerId('mk${markers.length}'),
              position:
                  LatLng(currentPosition.latitude, currentPosition.longitude))
        ];
      } else {
        Utils.showAlert(
            MyLocalizations.of(context, "location_not_active_title"),
            MyLocalizations.of(context, "location_not_active_txt"),
            context, onPressed: () {
          Navigator.pop(context);
        });
        streamType.add(LocationType.selected);
      }
    } else {
      if (Utils.report.selected_location_lat != null &&
          Utils.report.selected_location_lon != null) {
        currentMarkers.add(new Marker(
          markerId: MarkerId('selected'),
          position: LatLng(Utils.report.selected_location_lat,
              Utils.report.selected_location_lon),
        ));
        widget.setValid(true);
      }
      if (Utils.report.responses.any((r) => r.question_id == 5)) {
        int i = 0;
        Utils.report.responses.forEach((q) {
          i++;
          if (q.question_id == 5) {
            var res = q.answer_value
                .substring(q.answer_value.indexOf('( ') + 2,
                    q.answer_value.indexOf(')'))
                .split(', ');
            currentMarkers.add(new Marker(
                markerId: MarkerId('mk_$i'),
                position: LatLng(double.parse(res[0]), double.parse(res[1]))));
          }
        });
      }
    }
    setState(() {
      markers = currentMarkers;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 35,
                ),
                Style.title(MyLocalizations.of(context, "location_bited_txt")),
                Style.body(MyLocalizations.of(context, "chose_option_txt")),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 30),
                  child: StreamBuilder(
                    stream: streamType.stream,
                    initialData: LocationType.selected,
                    builder: (BuildContext context,
                        AsyncSnapshot<LocationType> snapshot) {
                      return Column(
                        children: <Widget>[
                          Container(
                            height: 60,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                    child: GestureDetector(
                                        onTap: () {
                                          getPosition(LocationType.current,
                                              context: context);
                                        },
                                        child: SmallQuestionOption(
                                          MyLocalizations.of(
                                              context, "current_location_txt"),
                                          selected: snapshot.data ==
                                              LocationType.current,
                                        ))),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                    child: GestureDetector(
                                  onTap: () {
                                    widget.setValid(false);
                                    getPosition(LocationType.selected);
                                  },
                                  child: SmallQuestionOption(
                                    MyLocalizations.of(
                                        context, "select_location_txt"),
                                    selected:
                                        snapshot.data == LocationType.selected,
                                  ),
                                )),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            height: 300,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: GoogleMap(
                                onMapCreated: _onMapCreated,
                                rotateGesturesEnabled: false,
                                myLocationButtonEnabled: false,
                                zoomControlsEnabled: false,
                                minMaxZoomPreference:
                                    MinMaxZoomPreference(6, 18),
                                mapToolbarEnabled: false,
                                onTap: (LatLng pos) {
                                  snapshot.data == LocationType.selected
                                      ? updateMarker(pos)
                                      : null;
                                },
                                initialCameraPosition: CameraPosition(
                                  target: currentLocation != null
                                      ? LatLng(currentLocation.latitude,
                                          currentLocation.longitude)
                                      : LatLng(41.3874, 2.1688),
                                  zoom: 15.0,
                                ),
                                markers: markers.isNotEmpty
                                    ? Set.from(markers)
                                    : null,
                              ),
                            ),
                          ),
                          // SizedBox(
                          //   height: 10,
                          // ),
                          // Style.noBgButton(
                          //     MyLocalizations.of(context, "not_sure_txt"), () {
                          //   getPosition(LocationType.missing);
                          // }, textColor: Colors.grey)
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
