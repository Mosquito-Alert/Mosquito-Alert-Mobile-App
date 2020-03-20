import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/customModalBottomSheet.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class ReportsList extends StatefulWidget {
  @override
  _ReportsListState createState() => _ReportsListState();
}

class _ReportsListState extends State<ReportsList> {
  GoogleMapController controller;

  Marker marker;

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // shrinkWrap:
      itemCount: 8,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            _reportBottomSheet(context);
          },
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.location_on,
                    color: Colors.yellow,
                    size: 40,
                  ),
                  Container(height: 60, child: VerticalDivider()),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Style.titleMedium(
                            MyLocalizations.of(
                                    context, "report_of_the_day_txt") +
                                "19/03/2020",
                            fontSize: 14),
                        Style.body(MyLocalizations.of(context, "location_txt") +
                            "Mi casa"),
                        Style.body(
                            MyLocalizations.of(context, "at_time_txt") +
                                "12:00h",
                            color: Colors.grey),
                      ],
                    ),
                  ),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/img/placeholder.jpg',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _reportBottomSheet(BuildContext context) {
    CustomShowModalBottomSheet.customShowModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
              child: Container(
            height: MediaQuery.of(context).size.height * 0.80,
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
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    height: 120,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: GoogleMap(
                        rotateGesturesEnabled: false,
                        mapToolbarEnabled: false,
                        scrollGesturesEnabled: false,
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(41.1613063, 0.4724329),
                          zoom: 14.0,
                        ),
                        //
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Style.titleMedium(
                      MyLocalizations.of(context, "report_of_the_day_txt") +
                          '9/03/2020'),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Style.titleMedium(
                                MyLocalizations.of(
                                    context, "registered_location_txt"),
                                fontSize: 14),
                            Style.body('(numeros, numeros)', fontSize: 12),
                            Style.body('Cercad de Bellaterra (Barcelona)',
                                fontSize: 12),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Style.titleMedium(
                                MyLocalizations.of(
                                    context, "exact_time_register_txt"),
                                fontSize: 14),
                            Style.body('una fecha muyyy muyy larga',
                                fontSize: 12),
                            Style.body('A las 15:00:25 horas'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Divider(),
                  ),
                  Style.titleMedium(
                      MyLocalizations.of(context, "reported_images_txt"),
                      fontSize: 14),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 60,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(right: 5),
                            child: Image.asset(
                              'assets/img/placeholder.jpg',
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                            ),
                          );
                        }),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Style.titleMedium(MyLocalizations.of(context, "reported_species_txt"), fontSize: 14),
                        Style.body(MyLocalizations.of(context, "unknoun")),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Style.titleMedium(MyLocalizations.of(context, "when_biting_txt"),
                            fontSize: 14),
                        Style.body("Por la tarde"),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Style.titleMedium(MyLocalizations.of(context, "which_situation_txt"), fontSize: 14),
                        Style.body("Espacio interior"),
                      ],
                    ),
                  ),
                  Divider(),
                ],
              ),
            ),
          ));
        });
  }
}
