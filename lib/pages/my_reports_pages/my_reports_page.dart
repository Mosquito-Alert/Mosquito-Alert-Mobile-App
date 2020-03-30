import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/components/my_reports_map.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/customModalBottomSheet.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:intl/intl.dart';

import 'components/reports_list_widget.dart';

class MyReportsPage extends StatefulWidget {
  @override
  _MyReportsPageState createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  List<Report> _reports;

  final _pagesController = PageController();

  StreamController<List<Report>> dataStream =
      new StreamController<List<Report>>.broadcast();

  int _currentIndex = 0;
  Map<int, Widget> _children;

  GoogleMapController mapController;
  List<Marker> markers;

  void _onMapCreated(GoogleMapController controller) {
    this.mapController = controller;
  }

  @override
  initState() {
    super.initState();
    if (_reports == null) {
      _getData();
    }
  }

  _getData() async {
    var list = await ApiSingleton().getMyReports();
    setState(() {
      _reports = list;
    });
    dataStream.add(list);
    _createMarkers();
  }

  _createMarkers() {
    markers = List();
    for (int i = 0; i < _reports.length; i++) {
      var position;
      if (_reports[i].location_choice == 'current') {
        position = LatLng(
            _reports[i].current_location_lat, _reports[i].current_location_lon);
            markers.add(Marker(
        markerId: MarkerId(_reports[i].report_id),
        position: position,
        // onTap: _reportBottomSheet(context, _reports[i])   //TODO: get context
      ));
      } else if (_reports[i].location_choice == 'selected') {
        position = LatLng(_reports[i].selected_location_lat,
            _reports[i].selected_location_lon);
            markers.add(Marker(
        markerId: MarkerId(_reports[i].report_id),
        position: position,
        // onTap: _reportBottomSheet(context, _reports[i])   //TODO: get context
      ));
      }
      
    }
  }

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

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(top: 100),
                child: StreamBuilder<List<Report>>(
                  stream: dataStream.stream,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Report>> snapshot) {
                    return PageView.builder(
                        controller: _pagesController,
                        itemCount: 2,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          if (index == 0.0) return MyReportsMap(markers);
                          if (index == 1.0)
                            return ReportsList(
                                snapshot.data, _reportBottomSheet);
                        });
                  },
                )),
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
                          Style.title(
                              MyLocalizations.of(context, "your_reports_txt")),
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
                          selectionIndex: _currentIndex,
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
        ),
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
                  report.location_choice != 'missing'
                      ? Container(
                          height: 120,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: GoogleMap(
                              rotateGesturesEnabled: false,
                              mapToolbarEnabled: false,
                              scrollGesturesEnabled: false,
                              onMapCreated: _onMapCreated,
                              initialCameraPosition: _getPosition(report),
                              markers: _getMarker(report),
                            ),
                          ),
                        )
                      : Container(),
                  SizedBox(
                    height: 20,
                  ),
                  Style.titleMedium(
                      MyLocalizations.of(context, "report_of_the_day_txt") +
                          DateFormat('dd-MM-yyyy')
                              .format(DateTime.parse(report.creation_time))
                              .toString()),
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
                                report.location_choice == "current"
                                    ? '(' +
                                        report.current_location_lat.toString() +
                                        ', ' +
                                        report.current_location_lon.toString() +
                                        ')'
                                    : '(' +
                                        report.selected_location_lat
                                            .toString() +
                                        ', ' +
                                        report.selected_location_lon
                                            .toString() +
                                        ')',
                                fontSize: 12),
                            Style.body('Cercad de **Bellaterra (Barcelona)',
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
                            Style.body(
                                DateFormat('dddd, dd MMMM yyyy')
                                    .format(
                                        DateTime.parse(report.creation_time))
                                    .toString(),
                                fontSize: 12),
                            Style.body(
                                'A las ' +
                                    DateFormat.Hms()
                                        .format(DateTime.parse(
                                            report.creation_time))
                                        .toString() +
                                    ' horas',
                                fontSize: 12),
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

  _getPosition(Report report) {
    var _target;

    if (report.location_choice == "current") {
      _target =
          LatLng(report.current_location_lat, report.current_location_lon);
    } else {
      _target =
          LatLng(report.selected_location_lat, report.selected_location_lon);
    }

    return CameraPosition(
      target: _target,
      zoom: 15.0,
    );
  }

  _getMarker(Report report) {
    var marker;
    if (report.location_choice == "current") {
      marker = Marker(
          markerId: MarkerId('currentMarker'),
          position:
              LatLng(report.current_location_lat, report.current_location_lon));
    } else {
      marker = Marker(
          markerId: MarkerId('selectedtMarker'),
          position: LatLng(
              report.selected_location_lat, report.selected_location_lon));
    }

    return <Marker>[marker].toSet();
  }

  _onItemTapped(index) {
    setState(() {
      _currentIndex = index;
    });
    _pagesController.animateToPage(index,
        duration: Duration(milliseconds: 300), curve: Curves.ease);
  }
}
