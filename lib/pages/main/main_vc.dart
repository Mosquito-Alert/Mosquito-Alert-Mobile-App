import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/pages/forms_pages/adult_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/biting_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/breeding_report_page.dart';
import 'package:mosquito_alert_app/pages/info_pages/points_info_page.dart';
import 'package:mosquito_alert_app/pages/main/components/custom_card_wodget.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/my_reports_page.dart';
import 'package:mosquito_alert_app/pages/notification_pages/notifications_page.dart';
import 'package:mosquito_alert_app/pages/settings_pages/settings_page.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class MainVC extends StatefulWidget {
  @override
  _MainVCState createState() => _MainVCState();
}

class _MainVCState extends State<MainVC> {
  String userName;
  @override
  void initState() {
    super.initState();
    UserManager.startFirstTime(context);
    _getLastLocation();
    _getData();
  }

  _getData() async {
    var user = await UserManager.fetchUser();
    if (user != null && user.displayName != null) {
      setState(() {
        userName = user.displayName;
      });
    }
  }

  _getLastLocation() async {
    GeolocationStatus geolocationStatus =
        await Geolocator().checkGeolocationPermissionStatus();
    if (geolocationStatus != null &&
        geolocationStatus == GeolocationStatus.granted) {
      Utils.getLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          },
        ),
        title: Image.asset(
          'assets/img/ic_logo.png',
          height: 45,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Style.title(
                                    userName != null
                                        ? " ${MyLocalizations.of(context, "welcome_text")}, $userName."
                                        : " ${MyLocalizations.of(context, "welcome_text")}",
                                    fontSize: 18),
                                SizedBox(
                                  height: 5,
                                ),
                                Style.body(
                                    MyLocalizations.of(
                                        context, "what_to_do_txt"),
                                    fontSize: 16),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PointsInfo()),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    child: Style.body(
                                        MyLocalizations.of(
                                            context, "more_info_points_txt"),
                                        color: Color(0XFFC96F00),
                                        fontSize: 10),
                                  ),
                                )
                              ]),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/img/points_box.png"),
                            ),
                          ),
                          child: Center(
                              child: AutoSizeText(
                            '188',
                            maxLines: 1,
                            maxFontSize: 26,
                            minFontSize: 16,
                            style: TextStyle(
                                color: Color(0xFF4B3D04),
                                fontWeight: FontWeight.w700,
                                fontSize: 30),
                          )),
                        ),
                      ]),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Divider(),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BitingReportPage()),
                            );
                          },
                          child: CustomCard(
                            img: 'assets/img/ic_bite_report.png',
                            title: MyLocalizations.of(
                                context, 'report_biting_txt'),
                            subtitle: MyLocalizations.of(
                                context, 'bitten_by_mosquito_question_txt'),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                          child: GestureDetector(
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BreedingReportPage()),
                          );
                        },
                        child: CustomCard(
                          img: 'assets/img/ic_breeding_report.png',
                          title: MyLocalizations.of(context, 'report_nest_txt'),
                          subtitle: MyLocalizations.of(
                              context, 'found_breeding_place_question_txt'),
                        ),
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AdultReportPage()),
                            );
                          },
                          child: CustomCard(
                            img: 'assets/img/ic_mosquito_report.png',
                            title: MyLocalizations.of(
                                context, 'report_adults_txt'),
                            subtitle: MyLocalizations.of(
                                context, 'report_us_adult_mosquitos_txt'),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                          child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyReportsPage()),
                          );
                        },
                        child: CustomCard(
                          img: 'assets/img/ic_my_reports.png',
                          title:
                              MyLocalizations.of(context, 'your_reports_txt'),
                          subtitle: MyLocalizations.of(
                              context, 'explore_your_reports_txt'),
                        ),
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(15),
                            child: Image.asset(
                              'assets/img/ic_validate_photos.png',
                              height: 70,
                              width: 70,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: <Widget>[
                                Style.titleMedium(
                                    MyLocalizations.of(context,
                                        'help_validating_other_photos_txt'),
                                    fontSize: 16),
                                SizedBox(
                                  height: 5,
                                ),
                                Style.bodySmall(MyLocalizations.of(
                                    context, 'we_need_help_txt'))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
                width: double.infinity,
                child: SvgPicture.asset('assets/img/ic_bottom_waves.svg',
                    width: 500, fit: BoxFit.cover)),
          ],
        ),
      ),
    );
  }
}
