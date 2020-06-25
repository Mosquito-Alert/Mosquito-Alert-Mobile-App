import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/pages/forms_pages/adult_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/biting_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/breeding_report_page.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/customModalBottomSheet.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import 'components/reports_list_widget.dart';

class MyReportsPage extends StatefulWidget {
  MyReportsPage({Key key}) : super(key: key);

  @override
  _MyReportsPageState createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  Position location = Position(
      latitude: Utils.defaultLocation.latitude,
      longitude: Utils.defaultLocation.longitude);

  BitmapDescriptor iconAdultYours;
  BitmapDescriptor iconBitesYours;
  BitmapDescriptor iconBreedingYours;
  BitmapDescriptor iconAdultOthers;
  BitmapDescriptor iconBitesOthers;
  BitmapDescriptor iconBreedingOthers;

  final _pagesController = PageController();

  StreamController<List<Report>> dataMarkersStream =
      new StreamController<List<Report>>.broadcast();
  StreamController<List<Report>> dataStream =
      new StreamController<List<Report>>.broadcast();

  StreamController<bool> loadingStream = new StreamController<bool>.broadcast();

  int _currentIndex = 0;
  Map<int, Widget> _children;

  GoogleMapController mapController;
  GoogleMapController miniMapController;
  List<Report> data = [];

  @override
  initState() {
    super.initState();
    _initLocation();
    _initMarkers();
  }

  _initLocation() {
    if (Utils.location != null) {
      location = Utils.location;
    }
  }

  void _initMarkers() async {
    int width = 125;

    // iconAdultYours = BitmapDescriptor.fromBytes(
    //     await getBytesFromAsset('assets/img/ic_adults_yours.png', width));
    // iconBitesYours = BitmapDescriptor.fromBytes(
    //     await getBytesFromAsset('assets/img/ic_bites_yours.png', width));
    // iconBreedingYours = BitmapDescriptor.fromBytes(
    //     await getBytesFromAsset('assets/img/ic_breeding_yours.png', width));
    // iconAdultOthers = BitmapDescriptor.fromBytes(
    //     await getBytesFromAsset('assets/img/ic_adult_other.png', width));
    // iconBitesOthers = BitmapDescriptor.fromBytes(
    //     await getBytesFromAsset('assets/img/ic_bites_other.png', width));
    // iconBreedingOthers = BitmapDescriptor.fromBytes(
    //     await getBytesFromAsset('assets/img/ic_breeding_other.png', width));

    iconAdultYours = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    iconBitesYours = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    iconBreedingYours = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
    iconAdultOthers = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  _createMarkers(List<Report> reports) {
    if (reports == null || reports.isEmpty) {
      return;
    }

    var markers = <Marker>[];
    for (int i = 0; i < reports.length; i++) {
      var position;
      // if (_reports[i].location_choice != 'missing') {
      if (reports[i].location_choice == 'current' &&
          reports[i].current_location_lat != null &&
          reports[i].current_location_lon != null) {
        position = LatLng(
            reports[i].current_location_lat, reports[i].current_location_lon);
      } else if (reports[i].location_choice == 'selected' &&
          reports[i].selected_location_lat != null &&
          reports[i].selected_location_lon != null) {
        position = LatLng(
            reports[i].selected_location_lat, reports[i].selected_location_lon);
      }
      var icon = setIconMarker(reports[i].type, reports[i].user);

      if (position != null) {
        markers.add(Marker(
          markerId: MarkerId(reports[i].report_id),
          position: position,
          consumeTapEvents: true,
          onTap: () {
            _reportBottomSheet(reports[i]);
          },
          icon: icon,
        ));
      }
      // }
    }

    return Set<Marker>.of(markers).toSet();
  }

  BitmapDescriptor setIconMarker(type, user) {
    if (UserManager.profileUUIDs != null &&
        UserManager.profileUUIDs.any((id) => id == user)) {
      switch (type) {
        case "adult":
          // return
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
    } else {
      return iconAdultOthers; 
      // switch (type) {
      //   case "adult":
      //     return iconAdultOthers;
      //     break;
      //   case "bite":
      //     return iconBitesOthers;
      //     break;
      //   case "site":
      //     return iconBreedingOthers;
      //     break;
      //   default:
      //     break;
      // }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _getLocation();
  }

  _getLocation() async {
    LatLng loc = Utils.defaultLocation;
    if (location.latitude == Utils.defaultLocation.latitude &&
        location.longitude == Utils.defaultLocation.longitude) {
      await Utils.getLocation();
      if (Utils.location != null) {
        location = Utils.location;
        if (mapController != null) {
          mapController.animateCamera(CameraUpdate.newLatLng(
              LatLng(location.latitude, location.longitude)));
          _getData();
        }
      }
    }
  }

  void _onMiniMapCreated(GoogleMapController controller) async {
    miniMapController = controller;
  }

  _updateData() {
    loadingStream.add(true);
    _getData();
  }

  @override
  void dispose() {
    super.dispose();
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
      body: Stack(
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(top: 100),
              child: PageView.builder(
                  controller: _pagesController,
                  itemCount: 2,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0.0) {
                      return Stack(
                        alignment: Alignment.bottomLeft,
                        children: <Widget>[
                          StreamBuilder<List<Report>>(
                            stream: dataMarkersStream.stream,
                            builder: (BuildContext context,
                                AsyncSnapshot<List<Report>> snapshot) {
                              return GoogleMap(
                                onMapCreated: _onMapCreated,
                                mapType: MapType.normal,
                                mapToolbarEnabled: false,
                                zoomControlsEnabled: false,
                                zoomGesturesEnabled: false,
                                myLocationButtonEnabled: false,
                                onCameraMove: (newPosition) {
                                  location = Position(
                                      latitude: newPosition.target.latitude,
                                      longitude: newPosition.target.longitude);
                                },
                                onCameraIdle: () {
                                  _getData();
                                },
                                initialCameraPosition: CameraPosition(
                                  target: location != null
                                      ? LatLng(
                                          location.latitude, location.longitude)
                                      : Utils.defaultLocation,
                                  zoom: 15.7,
                                ),
                                markers: _createMarkers(snapshot.data),
                              );
                            },
                          ),
                          SafeArea(
                            child: Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Style.button("Leyenda", () {
                                _infoBottom(context);
                              }),
                            ),
                          )
                        ],
                      );
                    }

                    return StreamBuilder<List<Report>>(
                      stream: dataStream.stream,
                      initialData: data,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Report>> snapshot) {
                        return ReportsList(
                            snapshot.data != null ? snapshot.data : [],
                            _reportBottomSheet);
                      },
                    );
                  })),
          StreamBuilder<bool>(
              stream: loadingStream.stream,
              initialData: true,
              builder: (BuildContext context, AsyncSnapshot<bool> snapLoading) {
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
                bottom: false,
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
                          icon: Style.iconBack,
                        ),
                        Style.title(
                            MyLocalizations.of(context, "your_reports_txt")),
                        SizedBox(
                          width: 40,
                        )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15, bottom: 16),
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
    );
  }

  void _infoBottom(BuildContext context) {
    CustomShowModalBottomSheet.customShowModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            color: Colors.white,
            constraints: new BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                    ),
                    Row(children: <Widget>[
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            SvgPicture.asset('assets/img/ic_bites_yours.svg'),
                            SizedBox(
                              height: 5,
                            ),
                            Style.body(
                                MyLocalizations.of(
                                    context, "your_reports_bites_txt"),
                                textAlign: TextAlign.center)
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            SvgPicture.asset(
                                'assets/img/ic_breeding_yours.svg'),
                            SizedBox(
                              height: 5,
                            ),
                            Style.body(
                                MyLocalizations.of(
                                    context, "your_reports_breeding_txt"),
                                textAlign: TextAlign.center)
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            SvgPicture.asset('assets/img/ic_adults_yours.svg'),
                            Style.body(
                                MyLocalizations.of(
                                    context, "your_reports_adults_txt"),
                                textAlign: TextAlign.center)
                          ],
                        ),
                      ),
                    ]),
                    SizedBox(
                      height: 20,
                    ),
                    Row(children: <Widget>[
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            SvgPicture.asset('assets/img/ic_bites_other.svg'),
                            SizedBox(
                              height: 5,
                            ),
                            Style.body(
                                MyLocalizations.of(
                                    context, "other_reports_bites_txt"),
                                textAlign: TextAlign.center)
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            SvgPicture.asset(
                                'assets/img/ic_breeding_other.svg'),
                            SizedBox(
                              height: 5,
                            ),
                            Style.body(
                                MyLocalizations.of(
                                    context, "other_reports_breeding_txt"),
                                textAlign: TextAlign.center)
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            SvgPicture.asset('assets/img/ic_adults_other.svg'),
                            Style.body(
                                MyLocalizations.of(
                                    context, "other_reports_adults_txt"),
                                textAlign: TextAlign.center)
                          ],
                        ),
                      ),
                    ]),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  _reportBottomSheet(Report report) async {
    bool isMine = UserManager.profileUUIDs.any((id) => id == report.user);
    Coordinates coord;
    if (report.location_choice == "current") {
      coord =
          Coordinates(report.current_location_lat, report.current_location_lon);
    } else if (report.location_choice == 'selected') {
      coord = Coordinates(
          report.selected_location_lat, report.selected_location_lon);
    }
    var address = await Geocoder.local.findAddressesFromCoordinates(coord);
    CustomShowModalBottomSheet.customShowModalBottomSheet(
        context: context,
        dismissible: true,
        builder: (BuildContext bc) {
          return Container(
            height: isMine
                ? MediaQuery.of(context).size.height * 0.80
                : MediaQuery.of(context).size.height * 0.45,
            // color: Colors.white,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                )),
            child: SafeArea(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 15,
                      ),
                      Expanded(
                        child: Stack(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: GoogleMap(
                                rotateGesturesEnabled: false,
                                mapToolbarEnabled: false,
                                scrollGesturesEnabled: false,
                                zoomControlsEnabled: false,
                                zoomGesturesEnabled: false,
                                myLocationButtonEnabled: false,
                                onMapCreated: _onMiniMapCreated,
                                initialCameraPosition: _getPosition(report),
                                markers: _getMarker(report),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                                Style.body(
                                    ' ${MyLocalizations.of(context, "near_from_txt")} ${address[0].locality} (${address[0].subAdminArea})',
                                    fontSize: 12),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Style.titleMedium(
                                    MyLocalizations.of(
                                        context, "exact_time_register_txt"),
                                    fontSize: 14),
                                Style.body(
                                    DateFormat('EEEE, dd MMMM yyyy')
                                        .format(DateTime.parse(
                                            report.creation_time))
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
                      isMine
                          ? Expanded(
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: Divider(),
                                  ),
                                  report.photos.isNotEmpty
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Style.titleMedium(
                                                MyLocalizations.of(context,
                                                    "reported_images_txt"),
                                                fontSize: 14),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              height: 60,
                                              child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount:
                                                      report.photos.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Container(
                                                      margin: EdgeInsets.only(
                                                          right: 5),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        child: Image.network(
                                                          'http://humboldt.ceab.csic.es/media/' +
                                                              report
                                                                  .photos[index]
                                                                  .photo,
                                                          height: 60,
                                                          width: 60,
                                                          fit: BoxFit.cover,
                                                        ),
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
                                                    const EdgeInsets.symmetric(
                                                        vertical: 20.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    report.responses[index]
                                                                .question !=
                                                            null
                                                        ? Expanded(
                                                            flex: 3,
                                                            child: Style.titleMedium(
                                                                report
                                                                    .responses[
                                                                        index]
                                                                    .question,
                                                                fontSize: 14),
                                                          )
                                                        : Container(),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Style.body(
                                                          report
                                                                      .responses[
                                                                          index]
                                                                      .answer !=
                                                                  ' '
                                                              ? report
                                                                  .responses[
                                                                      index]
                                                                  .answer
                                                              : report
                                                                  .responses[
                                                                      index]
                                                                  .answer_value,
                                                          textAlign:
                                                              TextAlign.end),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                          child: Style.noBgButton(
                                              MyLocalizations.of(
                                                  context, "edit"), () {
                                        if (report.type == "bite") {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BitingReportPage(
                                                      editReport: report,
                                                      loadData: _updateData,
                                                    )),
                                          );
                                        } else if (report.type == "adult") {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AdultReportPage(
                                                      editReport: report,
                                                      loadData: _updateData,
                                                    )),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BreedingReportPage(
                                                      editReport: report,
                                                      loadData: _updateData,
                                                    )),
                                          );
                                        }
                                      })),
                                      Expanded(
                                          child: Style.noBgButton(
                                              MyLocalizations.of(
                                                  context, "delete"), () {
                                        Utils.showAlertYesNo(
                                            MyLocalizations.of(
                                                context, "delete_report_title"),
                                            MyLocalizations.of(
                                                context, "delete_report_txt"),
                                            () {
                                          _deleteReport(report);
                                        }, context);
                                        //
                                      }, textColor: Colors.red))
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      SizedBox(
                        height: 20,
                      ),
                    ]),
              ),
            ),
          );
        });
  }

  _getData() async {
    loadingStream.add(true);
    List<Report> list = [];
    bool res = await ApiSingleton().getReportsList(location.latitude, location.longitude,
        page: 1, callback: (List<Report> reports) {
      list = [...list, ...reports];
      dataMarkersStream.add(list);
    });

    if (list == null) {
      list = [];
    }

    
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
  }

  _deleteReport(report) async {
    Navigator.pop(context);
    loadingStream.add(true);
    bool res = await Utils.deleteReport(report);
    if (res) {
      loadingStream.add(false);
      _getData();
    } else {
      loadingStream.add(false);
      Utils.showAlert(
        MyLocalizations.of(context, "app_name"),
        MyLocalizations.of(context, 'save_report_ko_txt'),
        context,
      );
    }
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
    var icon = setIconMarker(report.type, report.user);
    if (report.location_choice == "current") {
      marker = Marker(
          markerId: MarkerId('currentMarker'),
          position: LatLng(
            report.current_location_lat,
            report.current_location_lon,
          ),
          icon: icon);
    } else {
      marker = Marker(
          markerId: MarkerId('selectedtMarker'),
          position: LatLng(
            report.selected_location_lat,
            report.selected_location_lon,
          ),
          icon: icon);
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
