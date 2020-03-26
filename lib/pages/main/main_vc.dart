import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mosquito_alert_app/pages/forms_pages/biting_report_page.dart';
import 'package:mosquito_alert_app/pages/info_pages/points_info_page.dart';
import 'package:mosquito_alert_app/pages/main/components/custom_card_wodget.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/my_reports_page.dart';
import 'package:mosquito_alert_app/pages/notification_pages/notifications_page.dart';
import 'package:mosquito_alert_app/pages/settings_pages/settings_page.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'dart:math';

class MainVC extends StatefulWidget {
  @override
  _MainVCState createState() => _MainVCState();
}

class _MainVCState extends State<MainVC> {
  @override
  void initState() {
    super.initState();
    UserManager.startFirstTime(context);
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
        title: SvgPicture.asset('assets/img/logo_mosquito_alert.svg'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // print('jeasld');
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
                                    " ${MyLocalizations.of(context, "welcome_text")} Alex.",
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
                              child: Style.title('2',
                                  color: Color(0xFF4B3D04), fontSize: 30)),
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
                            img: 'assets/img/mosquito_placeholder.PNG',
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
                          var uuid = await UserManager.getUUID();
                          print(uuid);
                        },
                        child: CustomCard(
                          img: 'assets/img/mosquito_placeholder.PNG',
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
                        child: CustomCard(
                          img: 'assets/img/mosquito_placeholder.PNG',
                          title:
                              MyLocalizations.of(context, 'report_adults_txt'),
                          subtitle: MyLocalizations.of(
                              context, 'report_us_adult_mosquitos_txt'),
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
                          img: 'assets/img/mosquito_placeholder.PNG',
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
                            padding: EdgeInsets.all(25),
                            child: Image.asset(
                              'assets/img/ic_image.PNG',
                              height: 50,
                              width: 50,
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
                child: Image.asset(
                  'assets/img/bottom_main.PNG',
                  width: 500,
                  fit: BoxFit.cover,
                )),
          ],
        ),
      ),
    );
  }
}
