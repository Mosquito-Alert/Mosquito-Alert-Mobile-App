import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/customModalBottomSheet.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class MyReportsMap extends StatefulWidget {
  final List<Marker> markers;

  MyReportsMap(this.markers);

  @override
  _MyReportsMapState createState() => _MyReportsMapState();
}

class _MyReportsMapState extends State<MyReportsMap> {
  GoogleMapController controller;

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: <Widget>[
        GoogleMap(
          onMapCreated: _onMapCreated,
          mapToolbarEnabled: false,
          initialCameraPosition: CameraPosition(
            target: Utils.defaultLocation,
            zoom: 16.0,
          ),
          markers: widget.markers != null ? Set<Marker>.of(widget.markers) : null,
        ),
        Style.button("Leyenda", () {
          _reportBottomSheet(context);
        })
      ],
    );
  }

  void _reportBottomSheet(BuildContext context) {
    CustomShowModalBottomSheet.customShowModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
              child: Container(
            height: MediaQuery.of(context).size.height * 0.40,
            // color: Colors.white,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                )),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Row(children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          SvgPicture.asset('assets/img/ic_bites_yours.svg'),
                          Style.body("Tus reportes de picadas",
                              textAlign: TextAlign.center)
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          SvgPicture.asset('assets/img/ic_breeding_yours.svg'),
                          Style.body("Tus reportes de picadas",
                              textAlign: TextAlign.center)
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          SvgPicture.asset('assets/img/ic_adults_yours.svg'),
                          Style.body("Tus reportes de picadas",
                              textAlign: TextAlign.center)
                        ],
                      ),
                    ),
                  ]),
                  Row(children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          SvgPicture.asset('assets/img/ic_bites_other.svg'),
                          Style.body("Tus reportes de picadas",
                              textAlign: TextAlign.center)
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          SvgPicture.asset('assets/img/ic_breeding_other.svg'),
                          Style.body("Tus reportes de picadas",
                              textAlign: TextAlign.center)
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          SvgPicture.asset('assets/img/ic_adults_other.svg'),
                          Style.body("Tus reportes de picadas",
                              textAlign: TextAlign.center)
                        ],
                      ),
                    ),
                  ]),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ));
        });
  }
}
