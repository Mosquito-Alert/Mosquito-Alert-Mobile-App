import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mosquito_alert_app/pages/forms_pages/mosquito_type_page.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';

import 'components/question_option_widget.dart';

class BitinLogationPage extends StatefulWidget {
  @override
  _BitinLogationPageState createState() => _BitinLogationPageState();
}

class _BitinLogationPageState extends State<BitinLogationPage> {
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
          Marker(markerId: MarkerId('jdjaflds'), position: markerPosition);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Style.title(MyLocalizations.of(context, "biting_report_txt"),
            fontSize: 16),
        actions: <Widget>[
          Style.noBgButton(
              MyLocalizations.of(context, "next"),
              _selectedIndex != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MosquitoTypePage()),
                      );
                    }
                  : null)
        ],
      ),
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
                                  },
                                  child: QuestionOption(
                                    index == _selectedIndex,
                                    "Por la tarde",
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
                                            onTap: (LatLng pos) {
                                              updateMarker(pos);
                                            },
                                            initialCameraPosition:
                                                const CameraPosition(
                                              target:
                                                  LatLng(41.1613063, 0.4724329),
                                              zoom: 14.0,
                                            ),
                                            // markers: Set<Marker>.of(marker.values),
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
