import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/pages/forms_pages/adult_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/biting_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/breeding_report_page.dart';
import 'package:mosquito_alert_app/pages/info_pages/info_page.dart';
import 'package:mosquito_alert_app/pages/main/components/custom_card_wodget.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/my_reports_page.dart';
import 'package:mosquito_alert_app/pages/notification_pages/notifications_page.dart';
import 'package:mosquito_alert_app/pages/settings_pages/settings_page.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

class MainVC extends StatefulWidget {
  @override
  _MainVCState createState() => _MainVCState();
}

class _MainVCState extends State<MainVC> {
  String userName;
  int userScore = 1;
  String userUuid;
  String language;
  StreamController<bool> loadingStream = new StreamController<bool>.broadcast();

  @override
  void initState() {
    super.initState();
    _getData();
    loadingStream.add(true);
  }

  _getData() async {
    var user = await UserManager.fetchUser();
    userUuid = await UserManager.getUUID();
    language = Utils.getLanguage();
    int points = await ApiSingleton().getUserScores();

    if (user != null) {
      setState(() {
        userName = user.displayName;
      });
    }
    setState(() {
      userScore = points;
    });
    _bgTracking();

    await UserManager.startFirstTime(context);
    loadingStream.add(false);
  }

  _bgTracking() async {
    bool trackingDisabled = await UserManager.getTracking();
    if (trackingDisabled == null || !trackingDisabled) {
      // 1.  Listen to events (See docs for all 12 available events).

      // Fired whenever a location is recorded
      bg.BackgroundGeolocation.onLocation(_onLocation);

      // 2.  Configure the plugin
      bg.BackgroundGeolocation.ready(bg.Config(
              desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
              distanceFilter: 1000.0,
              stopOnTerminate: false,
              startOnBoot: true,
              debug: false,
              deferTime: 3600000, //1h
              logLevel: bg.Config.LOG_LEVEL_VERBOSE))
          .then((bg.State state) {
        if (!state.enabled) {
          // 3.  Start the plugin.
          bg.BackgroundGeolocation.start().then((bg.State bgState) {
            print('[start] success - ${bgState}');
          });
        }
      });
    }
  }

  void _onLocation(bg.Location location) {
    Utils.location = Position(
        latitude: location.coords.latitude,
        longitude: location.coords.longitude);

    double lat = (location.coords.latitude / Utils.maskCoordsValue).floor() *
        Utils.maskCoordsValue;
    double lon = (location.coords.longitude / Utils.maskCoordsValue).floor() *
        Utils.maskCoordsValue;

    ApiSingleton()
        .sendFixes(lat, lon, location.timestamp, location.battery.level);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.settings,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SettingsPage(enableTracking: _bgTracking)),
                  );
                },
              ),
              title: Image.asset(
                'assets/img/ic_logo.png',
                height: 40,
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationsPage()),
                    );
                  },
                )
              ],
            ),
            body: LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 24,
                                ),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Style.title(
                                                  userName != null
                                                      ? " ${MyLocalizations.of(context, "welcome_text")}, $userName."
                                                      : " ${MyLocalizations.of(context, "welcome_text")}",
                                                  fontSize: 20),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Style.body(
                                                  MyLocalizations.of(context,
                                                      "what_to_do_txt"),
                                                  fontSize: 14),
                                            ]),
                                      ),
                                      SizedBox(
                                        width: 12,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => InfoPage(
                                                    "${MyLocalizations.of(context, 'url_point_1')}$language${MyLocalizations.of(context, 'url_point_2')}$userUuid")),
                                          );
                                        },
                                        child: Container(
                                          height: 60,
                                          width: 60,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  "assets/img/points_box.png"),
                                            ),
                                          ),
                                          child: Center(
                                              child: AutoSizeText(
                                            userScore != null
                                                ? userScore.toString()
                                                : '',
                                            maxLines: 1,
                                            maxFontSize: 26,
                                            minFontSize: 16,
                                            style: TextStyle(
                                                color: Color(0xFF4B3D04),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 24),
                                          )),
                                        ),
                                      ),
                                    ]),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6.0),
                                  child: Divider(),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        loadingStream.add(true);
                                        _createBiteReport();
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        child: CustomCard(
                                          img: 'assets/img/ic_bite_report.png',
                                          title: MyLocalizations.of(
                                              context, 'report_biting_txt'),
                                          subtitle: MyLocalizations.of(context,
                                              'bitten_by_mosquito_question_txt'),
                                        ),
                                      ),
                                    ),
                                    // SizedBox(
                                    //   width: 5,
                                    // ),
                                    GestureDetector(
                                      onTap: () {
                                        loadingStream.add(true);
                                        _createAdultReport();
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        child: CustomCard(
                                          img:
                                              'assets/img/ic_mosquito_report.png',
                                          title: MyLocalizations.of(
                                              context, 'report_adults_txt'),
                                          subtitle: MyLocalizations.of(context,
                                              'report_us_adult_mosquitos_txt'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        child: GestureDetector(
                                          onTap: () {
                                            loadingStream.add(true);
                                            _createSiteReport();
                                          },
                                          child: CustomCard(
                                            img:
                                                'assets/img/ic_breeding_report.png',
                                            title: MyLocalizations.of(
                                                context, 'report_nest_txt'),
                                            subtitle: MyLocalizations.of(
                                                context,
                                                'found_breeding_place_question_txt'),
                                          ),
                                        )),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MyReportsPage()),
                                            );
                                          },
                                          child: CustomCard(
                                            img: 'assets/img/ic_my_reports.png',
                                            title: MyLocalizations.of(
                                                context, 'your_reports_txt'),
                                            subtitle: MyLocalizations.of(
                                                context,
                                                'explore_your_reports_txt'),
                                          ),
                                        )),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                // Card(
                                //   elevation: 2,
                                //   shape: RoundedRectangleBorder(
                                //       borderRadius: BorderRadius.circular(20)),
                                //   child: Container(
                                //     padding: EdgeInsets.only(left: 20, right: 10, top: 15, bottom: 15),
                                //     child: Row(
                                //       children: <Widget>[
                                //         Image.asset(
                                //           'assets/img/ic_validate_photos.png',
                                //           width: 55,
                                //           fit: BoxFit.fitWidth,
                                //         ),
                                //         SizedBox(width: 15,),
                                //         Expanded(
                                //           flex: 2,
                                //           child: Column(
                                //             children: <Widget>[
                                //               Style.titleMedium(
                                //                   MyLocalizations.of(context,
                                //                       'help_validating_other_photos_txt'),
                                //                   fontSize: 16),
                                //               SizedBox(
                                //                 height: 5,
                                //               ),
                                //               Style.bodySmall(MyLocalizations.of(
                                //                   context, 'we_need_help_txt')),
                                //               SizedBox(
                                //                 height: 5,
                                //               ),
                                //             ],
                                //           ),
                                //         )
                                //       ],
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Container(
                              margin: EdgeInsets.only(top: 25),
                              child: SvgPicture.asset(
                                'assets/img/ic_bottom_waves.svg',
                                width: double.infinity,
                                fit: BoxFit.fitWidth,
                                alignment: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )),
        StreamBuilder<bool>(
          stream: loadingStream.stream,
          initialData: true,
          builder: (BuildContext ctxt, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData == false || snapshot.data == false) {
              return Container();
            }
            return Utils.loading(
              snapshot.data,
            );
          },
        )
      ],
    );
  }

  _createBiteReport() async {
    bool createReport = await Utils.createNewReport('bite');
    loadingStream.add(false);
    if (createReport) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BitingReportPage()),
      );
    } else {
      Utils.showAlert(MyLocalizations.of(context, 'app_name'),
          MyLocalizations.of(context, 'save_report_ko_txt'), context);
    }
  }

  _createAdultReport() async {
    bool createReport = await Utils.createNewReport('adult');
    loadingStream.add(false);
    if (createReport) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdultReportPage()),
      );
    } else {
      Utils.showAlert(MyLocalizations.of(context, 'app_name'),
          MyLocalizations.of(context, 'save_report_ko_txt'), context);
    }
  }

  _createSiteReport() async {
    bool createReport = await Utils.createNewReport('site');
    loadingStream.add(false);
    if (createReport) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BreedingReportPage()),
      );
    } else {
      Utils.showAlert(MyLocalizations.of(context, 'app_name'),
          MyLocalizations.of(context, 'save_report_ko_txt'), context);
    }
  }
}
