import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/pages/auth/login_main_page.dart';
import 'package:mosquito_alert_app/pages/info_pages/info_page.dart';
import 'package:mosquito_alert_app/pages/main/main_vc.dart';
import 'package:mosquito_alert_app/pages/settings_pages/components/settings_menu_widget.dart';
import 'package:mosquito_alert_app/pages/settings_pages/gallery_page.dart';
import 'package:mosquito_alert_app/pages/settings_pages/tutorial_page.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

class SettingsPage extends StatefulWidget {
  final Function enableTracking;

  SettingsPage({this.enableTracking});
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool enableTracking = false;

  @override
  void initState() {
    super.initState();
    getTracking();
  }

  getTracking() async {
    enableTracking = await UserManager.getTracking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Style.title(MyLocalizations.of(context, "settings_title"),
            fontSize: 16),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(15),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                  Widget>[
            SizedBox(
              height: 35,
            ),
            UserManager.user != null
                ? SettingsMenuWidget(MyLocalizations.of(context, "logout_txt"),
                    () {
                    Utils.showAlertYesNo(
                        MyLocalizations.of(context, "logout_txt"),
                        MyLocalizations.of(context, "logout_alert_txt"), () {
                      _signOut();
                    }, context);
                  })
                : Column(
                    children: <Widget>[
                      SettingsMenuWidget(
                          MyLocalizations.of(
                              context, "login_with_your_account_txt"), () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginMainPage()),
                        );
                      }),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Style.bodySmall(
                            MyLocalizations.of(
                                context, "use_your_acount_details_txt"),
                            color: Colors.grey),
                      ),
                    ],
                  ),
            SizedBox(
              height: 10,
            ),
            SettingsMenuWidget(
                MyLocalizations.of(context, "select_language_txt"), () {}),
            SizedBox(
              height: 10,
            ),
            SettingsMenuWidget(
                enableTracking
                    ? MyLocalizations.of(context, "enable_background_tracking")
                    : MyLocalizations.of(
                        context, "disable_background_tracking"), () {
              _disableBgTracking();
            }),
            SizedBox(
              height: 35,
            ),
            SettingsMenuWidget(
                MyLocalizations.of(context, "mosquitos_gallery_txt"), () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GalleryPage()),
              );
            }),
            SizedBox(
              height: 10,
            ),
            SettingsMenuWidget(MyLocalizations.of(context, "tutorial_txt"), () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TutorialPage()),
              );
            }),
            SizedBox(
              height: 10,
            ),
            SettingsMenuWidget(
                MyLocalizations.of(context, "info_scores_txt"), () {}),
            SizedBox(
              height: 10,
            ),
            SettingsMenuWidget(
                MyLocalizations.of(context, "about_the_project_txt"), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        InfoPage(MyLocalizations.of(context, "url_web"))),
              );
            }),
            SizedBox(
              height: 10,
            ),
            SettingsMenuWidget(
                MyLocalizations.of(context, "about_us_txt"), () {}),
            SizedBox(
              height: 10,
            ),
            SettingsMenuWidget(MyLocalizations.of(context, "terms_of_use_txt"),
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        InfoPage(MyLocalizations.of(context, "url_politics"))),
              );
            }),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 60,
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Style.title(MyLocalizations.of(context, "app_name"),
                      fontSize: 8, textAlign: TextAlign.center),
                  Style.bodySmall('v2.0.0 (build 504)',
                      fontSize: 8, textAlign: TextAlign.center),
                ],
              ),
            ),
            SizedBox(
              height: 60,
            ),
          ]),
        ),
      ),
    );
  }

  _signOut() async {
    ApiSingleton().logout().then((res) {
      UserManager.signOut();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainVC()));
    }).catchError((e) {
      print(e);
    });
  }

  _disableBgTracking() {
    Utils.showAlertYesNo(
        MyLocalizations.of(context, "app_name"),
        enableTracking
            ? MyLocalizations.of(context, "enable_tracking_question_text")
            : MyLocalizations.of(context, "disable_tracking_question_text"),
        () async {
      await UserManager.setTracking(!enableTracking);
      if (enableTracking) {
        widget.enableTracking();
      } else {
        bg.BackgroundGeolocation.stop();
        bg.BackgroundGeolocation.stopSchedule();
        print('disable');
      }

      setState(() {
        enableTracking = !enableTracking;
      });
    }, context);
  }
}
