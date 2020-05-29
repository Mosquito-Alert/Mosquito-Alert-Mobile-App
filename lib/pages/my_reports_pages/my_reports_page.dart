import 'dart:async';

import 'package:flutter/material.dart';
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

import 'components/reports_list_widget.dart';

class MyReportsPage extends StatefulWidget {
  MyReportsPage({Key key}) : super(key: key);

  @override
  _MyReportsPageState createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  List<Report> _reports;

  Position location;

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
  GoogleMapController miniMapController;

  void _onMapCreated(GoogleMapController controller) {
    _initLocation();
    setState(() {
      mapController = controller;
    });
  }

  void _onMiniMapCreated(GoogleMapController controller) async {
    setState(() {
      miniMapController = controller;
    });
  }

  @override
  initState() {
    super.initState();

    Utils.getLocation();
    loadingStream.add(true);
    if (iconAdultYours == null) {
      setCustomMapPin();
    }
  }

  _initLocation() async {
    await Utils.getLocation();
    var loc;

    Utils.location != null
        ? loc = Utils.location
        : loc = Position(latitude: 41.3874, longitude: 2.1688);

    mapController.animateCamera(
        CameraUpdate.newLatLng(LatLng(loc.latitude, loc.longitude)));

    setState(() {
      location = loc;
    });

    // _getData();
  }

  _updateData() {
    loadingStream.add(true);
    _getData();
  }

  _getData() async {
    var loc = location != null
        ? location
        : Utils.location != null
            ? Utils.location
            : Position(latitude: 41.3948975, longitude: 2.0785562);
    List<Report> list = [];
    list = await ApiSingleton()
        .getReportsList(loc.latitude, loc.longitude, page: 1);
    loadingStream.add(false);

    if (list == null) {
      list = [];
    }

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

    setState(() {
      _reports = list;
    });

    dataStream.add(data);
    loadingStream.add(false);
    // _createMarkers();
  }

  void setCustomMapPin() async {
    iconAdultYours = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(150, 150), devicePixelRatio: 2.5),
        'assets/img/ic_adults_yours.png');
    iconBitesYours = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/img/ic_bites_yours.png');
    iconBreedingYours = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/img/ic_breeding_yours.png');
    iconAdultOthers = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(150, 150), devicePixelRatio: 2.5),
        'assets/img/ic_adult_other.png');
    iconBitesOthers = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(150, 150), devicePixelRatio: 2.5),
        'assets/img/ic_bites_other.png');
    iconBreedingOthers = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(150, 150), devicePixelRatio: 2.5),
        'assets/img/ic_breeding_other.png');
  }

  _createMarkers(BuildContext ctx) {
    var markers = <Marker>[];
    for (int i = 0; i < _reports.length; i++) {
      var position;
      // if (_reports[i].location_choice != 'missing') {
      if (_reports[i].location_choice == 'current' &&
          _reports[i].current_location_lat != null &&
          _reports[i].current_location_lon != null) {
        position = LatLng(
            _reports[i].current_location_lat, _reports[i].current_location_lon);
      } else if (_reports[i].location_choice == 'selected' &&
          _reports[i].selected_location_lat != null &&
          _reports[i].selected_location_lon != null) {
        position = LatLng(_reports[i].selected_location_lat,
            _reports[i].selected_location_lon);
      }
      var icon = setIconMarker(_reports[i].type, _reports[i].user);

      if (position != null) {
        markers.add(Marker(
          markerId: MarkerId(_reports[i].report_id),
          position: position,
          consumeTapEvents: true,
          onTap: () {
            _reportBottomSheet(ctx, _reports[i]);
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
      switch (type) {
        case "adult":
          return iconAdultOthers;
          break;
        case "bite":
          return iconBitesOthers;
          break;
        case "site":
          return iconBreedingOthers;
          break;
        default:
          break;
      }
    }
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
                          if (index == 0.0) {
                            return Stack(
                              alignment: Alignment.bottomLeft,
                              children: <Widget>[
                                GoogleMap(
                                  onMapCreated: _onMapCreated,
                                  mapType: MapType.normal,
                                  mapToolbarEnabled: false,
                                  zoomControlsEnabled: false,
                                  zoomGesturesEnabled: false,
                                  onCameraMove: (newPosition) {
                                    setState(() {
                                      location = Position(
                                          latitude: newPosition.target.latitude,
                                          longitude:
                                              newPosition.target.longitude);
                                    });
                                  },
                                  onCameraIdle: () {
                                    loadingStream.add(true);
                                    _getData();
                                  },
                                  initialCameraPosition: CameraPosition(
                                    target: location != null
                                        ? LatLng(location.latitude,
                                            location.longitude)
                                        : LatLng(41.3948975, 2.0785562),
                                    zoom: 15.7,
                                  ),
                                  markers: snapshot.data != null
                                      ? _createMarkers(context)
                                      : null,
                                ),
                                Style.button("Leyenda", () {
                                  _infoBottom(context);
                                })
                              ],
                            );
                          }

                          if (index == 1.0) {
                            return ReportsList(
                                snapshot.hasData ? snapshot.data : [],
                                _reportBottomSheet);
                          }
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

  void _infoBottom(BuildContext context) {
    CustomShowModalBottomSheet.customShowModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
              child: Container(
            height: MediaQuery.of(context).size.height * 0.40,
            color: Colors.white,
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
                          SvgPicture.asset('assets/img/ic_breeding_yours.svg'),
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
                          SvgPicture.asset('assets/img/ic_breeding_other.svg'),
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
                    height: 10,
                  ),
                ],
              ),
            ),
          ));
        });
  }

  _reportBottomSheet(BuildContext context, Report report) async {
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
          return SafeArea(
              child: Container(
            height: isMine
                ? MediaQuery.of(context).size.height * 0.80
                : MediaQuery.of(context).size.height * 0.35,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      height: 120,
                      width: double.infinity,
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
                                                itemCount: report.photos.length,
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    margin: EdgeInsets.only(
                                                        right: 5),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      child: Image.network(
                                                        'http://humboldt.ceab.csic.es/media/' +
                                                            report.photos[index]
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
                                                          child:
                                                              Style.titleMedium(
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
                                                        report.responses[index]
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
                                  height: 15,
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                        child: Style.noBgButton(
                                            MyLocalizations.of(context, "edit"),
                                            () {
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
                                        Utils.deleteReport(report);

                                        _updateData();
                                        Navigator.pop(context);
                                      }, context);
                                      //
                                    }, textColor: Colors.red))
                                  ],
                                )
                              ],
                            ),
                          )
                        : Container()
                  ]),
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
