import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/question_option_widget.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class BitingLocationForm extends StatefulWidget {
  final Function setLocationType, setSelectedLocation;
  BitingLocationForm(this.setLocationType, this.setSelectedLocation);
  @override
  _BitingLocationFormState createState() => _BitingLocationFormState();
}

class _BitingLocationFormState extends State<BitingLocationForm> {
  int _selectedIndex;

  GoogleMapController controller;
  LatLng _lastTap;
  Marker marker;

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  updateMarker(LatLng markerPosition) {
    setState(() {
      this.marker =
          Marker(markerId: MarkerId('Marker 1'), position: markerPosition);
    });
    widget.setSelectedLocation(marker.position.latitude, marker.position.longitude);
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: 3,
                          itemBuilder: (ctx, index) {
                            return Column(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedIndex = index;
                                    });
                                    widget.setLocationType(index);
                                  },
                                  child: QuestionOption(
                                    index == _selectedIndex,
                                    "** En mi ubicación actual",
                                    'assets/img/ic_image.PNG',
                                    disabled: _selectedIndex != null
                                        ? index != _selectedIndex
                                        : false,
                                  ),
                                ),
                                _selectedIndex == index && index == 1
                                    ? Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 5),
                                        height: 300,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: GoogleMap(
                                            onMapCreated: _onMapCreated,
                                            rotateGesturesEnabled: false,
                                            mapToolbarEnabled: false,
                                            onTap: (LatLng pos) {
                                              updateMarker(pos);
                                            },
                                            initialCameraPosition:
                                                const CameraPosition(
                                              target:
                                                  LatLng(41.1613063, 0.4724329),
                                              zoom: 14.0,
                                            ),
                                            markers: marker != null
                                                ? <Marker>[marker].toSet()
                                                : null,
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            );
                          })
                    ],
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
