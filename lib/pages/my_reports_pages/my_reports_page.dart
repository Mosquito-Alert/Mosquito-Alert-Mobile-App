import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/models/question.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/pages/forms_pages/adult_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/biting_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/breeding_report_page.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/components/my_reports_map.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
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

  BitmapDescriptor iconAdultYours;
  BitmapDescriptor iconBitesYours;
  BitmapDescriptor iconBreedingYours;
  BitmapDescriptor iconAdultOthers;
  BitmapDescriptor iconBitesOthers;
  BitmapDescriptor iconBreedingOthers;

  final _pagesController = PageController();

  StreamController<List<Report>> dataStream =
      new StreamController<List<Report>>.broadcast();

  StreamController<bool> loadingStream = new StreamController<bool>.broadcast();

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
    loadingStream.add(true);
    if (_reports == null) {
      _getData();
    }
    if (iconAdultYours == null) {
      setCustomMapPin();
    }
  }

  _getData() async {
    List<Report> list =
        await ApiSingleton().getReportsList(41.1613063, 0.4724329, page: 1);

    setState(() {
      _reports = list;
    });

    List<Report> data = [];
    for (int i = 0; i < list.length; i++) {
      if (list[i].location_choice != "missing" &&
              list[i].current_location_lat != null &&
              list[i].current_location_lon != null ||
          list[i].selected_location_lat != null &&
              list[i].selected_location_lon != null) {
        data.add(list[i]);
      }
    }

    dataStream.add(data);
    loadingStream.add(false);
    _createMarkers();
  }

  void setCustomMapPin() async {
    iconAdultYours = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/img/ic_adults_yours.png');
    iconBitesYours = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/img/ic_bites_yours.png');
    iconBreedingYours = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/img/ic_breeding_yours.png');
    // iconAdultOthers = await BitmapDescriptor.fromAssetImage(
    //     ImageConfiguration(devicePixelRatio: 2.5),
    //     'assets/img/ic_adults_yours.png');
    // iconBitesOthers = await BitmapDescriptor.fromAssetImage(
    //     ImageConfiguration(devicePixelRatio: 2.5),
    //     'assets/img/ic_bites_yours.png');
    // iconBreedingOthers = await BitmapDescriptor.fromAssetImage(
    //     ImageConfiguration(devicePixelRatio: 2.5),
    //     'assets/img/ic_breeding_yours.png');
  }

  _createMarkers() {
    markers = List();
    for (int i = 0; i < _reports.length; i++) {
      var position;
      if (_reports[i].location_choice != 'missing') {
        if (_reports[i].location_choice == 'current' &&
            _reports[i].current_location_lat != null &&
            _reports[i].current_location_lon != null) {
          position = LatLng(_reports[i].current_location_lat,
              _reports[i].current_location_lon);
        } else if (_reports[i].location_choice == 'selected' &&
            _reports[i].selected_location_lat != null &&
            _reports[i].selected_location_lon != null) {
          position = LatLng(_reports[i].selected_location_lat,
              _reports[i].selected_location_lon);
        }
        var icon = setIconMarcker(_reports[i].type);

        if (position != null) {
          markers.add(Marker(
            markerId: MarkerId(_reports[i].report_id),
            position: position,
            // onTap: _reportBottomSheet(context, _reports[i])   //TODO: get context
            icon: icon,
          ));
        }
      }
    }
  }

  BitmapDescriptor setIconMarcker(type) {
    switch (type) {
      case "adult":
        return iconAdultYours;
        break;
      case "bite":
        return iconBitesYours;
        break;
      case "site":
        return iconBreedingYours;
        break;
      default:
        break;
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
                 StreamBuilder<bool>(
                stream: loadingStream.stream,
                initialData: true,
                builder:
                    (BuildContext context, AsyncSnapshot<bool> snapLoading) {
                  if (snapLoading.data == true)
                    return Container(
                      child: Center(
                        child: Utils.loading(true),
                      ),
                    );
                  return Container();
                }),
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
                                        report.current_location_lat
                                            .toStringAsFixed(5) +
                                        ', ' +
                                        report.current_location_lon
                                            .toStringAsFixed(5) +
                                        ')'
                                    : '(' +
                                        report.selected_location_lat
                                            .toStringAsFixed(5) +
                                        ', ' +
                                        report.selected_location_lon
                                            .toStringAsFixed(5) +
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
                                DateFormat('EEEE, dd MMMM yyyy')
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
                  report.photos.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Style.titleMedium(
                                MyLocalizations.of(
                                    context, "reported_images_txt"),
                                fontSize: 14),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 60,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: report.photos.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: EdgeInsets.only(right: 5),
                                      child: Image.asset(
                                        report.photos[index],
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
                          ],
                        )
                      : Container(),
                  Expanded(
                    child: ListView.builder(
                        itemCount: report.responses.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    report.responses[index].question != null
                                        ? Style.titleMedium(
                                            report.responses[index].question,
                                            fontSize: 14)
                                        : Container(),
                                    Style.body(report.responses[index].answer !=
                                            null
                                        ? report.responses[index].answer
                                        : report.responses[index].answer_value),
                                  ],
                                ),
                              ),
                              Divider(),
                            ],
                          );
                        }),
                  ),
                  // Expanded(child: _showResponses(report.responses)),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: Style.noBgButton(
                              MyLocalizations.of(context, "edit"), () {
                        if (report.type == "bite") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    BitingReportPage(editReport: report)),
                          );
                        } else if (report.type == "adult") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AdultReportPage(editReport: report)),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    BreedingReportPage(editReport: report)),
                          );
                        }
                      })),
                      Expanded(
                          child: Style.noBgButton(
                              MyLocalizations.of(context, "delete"), () {
                        Utils.showAlertYesNo(
                            MyLocalizations.of(context, "delete_report_title"),
                            MyLocalizations.of(context, "delete_report_txt"),
                            () {
                          Utils.deleteReport(report);
                          Navigator.pop(context);
                          //Todo: Reload list?
                        }, context);
                        //
                      }))
                    ],
                  ),
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
          position: LatLng(
            report.current_location_lat,
            report.current_location_lon,
          ),
          icon: setIconMarcker(report.type));
    } else {
      marker = Marker(
          markerId: MarkerId('selectedtMarker'),
          position: LatLng(
            report.selected_location_lat,
            report.selected_location_lon,
          ),
          icon: setIconMarcker(report.type));
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
