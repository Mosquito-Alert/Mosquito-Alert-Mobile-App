import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/components/my_reports_map.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/customModalBottomSheet.dart';
import 'package:mosquito_alert_app/utils/style.dart';

import 'components/reports_list_widget.dart';

class MyReportsPage extends StatefulWidget {
  @override
  _MyReportsPageState createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  List<Report> _reports = [
    Report(
        report_id: 'report1',
        current_location_lat: 41.1613063,
        current_location_lon: 0.4724329,
        creation_time: DateTime.now().toString()),
    Report(
        report_id: 'report2',
        current_location_lat: 41.1613063,
        current_location_lon: 0.5744329,
        creation_time: DateTime.now().toString()),
  ];

  int _currentIndex = 0;

  Map<int, Widget> _children;

  GoogleMapController mapController;
  List<Marker> markers;

  void _onMapCreated(GoogleMapController controller) {
    this.mapController = controller;
  }

  StreamController<int> selectedIndexStream =
      new StreamController<int>.broadcast();

  @override
  Widget build(BuildContext context) {
    _children = {
      0: Container(
        child: Text(MyLocalizations.of(context, "map_txt")),
      ),
      1: Container(
        child: Text(MyLocalizations.of(context, "list_txt")),
      ),
    };

    markers = [
      Marker(
          markerId: MarkerId('marker01'),
          position: LatLng(41.1613063, 0.4724329),
          onTap: () {
            _reportBottomSheet(context, _reports[0]);
          }),
      Marker(
          markerId: MarkerId('marker02'),
          position: LatLng(41.1613063, 0.5224329),
          onTap: () {
            _reportBottomSheet(context, _reports[1]);
          })
    ];

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<int>(
            stream: selectedIndexStream.stream,
            initialData: 0,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              return Stack(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 100),
                    child: snapshot.hasData
                        ? snapshot.data == 0
                            ? MyReportsMap(markers)
                            : ReportsList(_reports, _reportBottomSheet)
                        : Container(
                            color: Colors.blue,
                          ),
                  ),
                  Container(
                    child: Card(
                      margin: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0)),
                      color: Colors.white,
                      elevation: 2,
                      child: SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(Icons.arrow_back),
                                ),
                                Style.title(MyLocalizations.of(
                                    context, "your_reports_txt")),
                                SizedBox(
                                  width: 40,
                                )
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 15),
                              width: double.infinity,
                              child: MaterialSegmentedControl(
                                children: _children,
                                selectionIndex: snapshot.data,
                                borderColor: Style.colorPrimary,
                                selectedColor: Style.colorPrimary,
                                unselectedColor: Colors.white,
                                borderRadius: 5.0,
                                onSegmentChosen: (index) {
                                  _onItemTapped(index);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  void _reportBottomSheet(BuildContext context, Report report) {
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
                            Style.body(
                                '(' +
                                    report.current_location_lat.toString() +
                                    ', ' +
                                    report.current_location_lon.toString() +
                                    ')',
                                fontSize: 12),
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
                        Style.titleMedium(
                            MyLocalizations.of(context, "reported_species_txt"),
                            fontSize: 14),
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
                        Style.titleMedium(
                            MyLocalizations.of(context, "when_biting_txt"),
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
                        Style.titleMedium(
                            MyLocalizations.of(context, "which_situation_txt"),
                            fontSize: 14),
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

  void _onItemTapped(int index) {
    _currentIndex = index;
    selectedIndexStream.add(_currentIndex);
  }
}
