import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/small_question_option_widget.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class BitingLocationForm extends StatefulWidget {
  @override
  _BitingLocationFormState createState() => _BitingLocationFormState();
}

enum LocationType { current, selected, missing }

class _BitingLocationFormState extends State<BitingLocationForm> {
  GoogleMapController controller;
  List<Marker> markers = [];

  Position location;

  Set<Circle> circles;

  StreamController<LocationType> streamType =
      StreamController<LocationType>.broadcast();

  @override
  void initState() {
    location = Utils.location;
    if (Utils.report != null) {
      switch (Utils.report.location_choice) {
        case "selected":
          streamType.add(LocationType.selected);
          updateMarker(LatLng(Utils.report.selected_location_lat,
              Utils.report.selected_location_lon));
          break;
        case "current":
          streamType.add(LocationType.current);
          updateMarker(LatLng(Utils.report.current_location_lat,
              Utils.report.current_location_lon));
          break;
        default:
          streamType.add(LocationType.missing);
      }
      if (Utils.report.responses.any((r) => r.question_id == 5)) {
        //TODO: save responses as markers
      }
    }
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
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
      setState(() {
        markers = [mk];
      });
    }
  }

  getPosition(type, {context}) async {
    streamType.add(type);
    if (type == LocationType.current) {
      Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
      bool geolocationEnabled = await geolocator.isLocationServiceEnabled();
      if (geolocationEnabled) {
        Position currentPosition = await Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        circles = Set.from([
          Circle(
              circleId: CircleId('Circle 1'),
              center:
                  LatLng(currentPosition.latitude, currentPosition.longitude),
              radius: 100,
              strokeColor: Colors.transparent,
              fillColor: Colors.blue.withOpacity(0.1))
        ]);
        Utils.setCurrentLocation(
            currentPosition.latitude, currentPosition.longitude);
      } else {
        Utils.showAlert(
            MyLocalizations.of(context, "location_not_active_title"),
            MyLocalizations.of(context, "location_not_active_txt"),
            context, onPressed: () {
          Navigator.pop(context);
        });
        streamType.add(LocationType.selected);
      }
    }
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
                          Row(
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
                                myLocationEnabled:
                                    snapshot.data == LocationType.current
                                        ? true
                                        : false,
                                mapToolbarEnabled: false,
                                onTap: (LatLng pos) {
                                  snapshot.data == LocationType.selected
                                      ? updateMarker(pos)
                                      : null;
                                },
                                initialCameraPosition: CameraPosition(
                                  target: location != null
                                      ? LatLng(
                                          location.latitude, location.longitude)
                                      : LatLng(41.3874, 2.1688),
                                  zoom: 15.0,
                                ),
                                markers:
                                    snapshot.data == LocationType.selected &&
                                            markers.isNotEmpty
                                        ? Set.from(markers)
                                        : null,
                                circles: snapshot.data == LocationType.current
                                    ? circles
                                    : null,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Style.noBgButton(
                              MyLocalizations.of(context, "not_sure_txt"), () {
                            getPosition(LocationType.missing);
                          }, textColor: Colors.grey)
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
