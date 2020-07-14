import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/pages/auth/login_main_page.dart';
import 'package:mosquito_alert_app/pages/info_pages/info_page.dart';
import 'package:mosquito_alert_app/pages/main/main_vc.dart';
import 'package:mosquito_alert_app/pages/settings_pages/components/settings_menu_widget.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:share/share.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 35,
                ),
                UserManager.user != null
                    ? SettingsMenuWidget(
                        MyLocalizations.of(context, "logout_txt"), () {
                        Utils.showAlertYesNo(
                            MyLocalizations.of(context, "logout_txt"),
                            MyLocalizations.of(context, "logout_alert_txt"),
                            () {
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
                  height: 35,
                ),
                SettingsMenuWidget(MyLocalizations.of(context, "share_app_txt"),
                    () {
                  Share.share('https://www.google.es'); //TODO: fix url
                }),
                SizedBox(
                  height: 10,
                ),
                // SettingsMenuWidget(
                //     MyLocalizations.of(context, "select_language_txt"), () {}),
                // SizedBox(
                //   height: 10,
                // ),
                // SettingsMenuWidget(
                //     MyLocalizations.of(context, "info_scores_txt"), () {}),
                // SizedBox(
                //   height: 10,
                // ),
                SettingsMenuWidget(
                    MyLocalizations.of(context, "consent_form_txt"), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => InfoPage(
                            'http://webserver.mosquitoalert.com/es/terms/')),
                  );
                }),
                SizedBox(
                  height: 10,
                ),
                // SettingsMenuWidget(
                //     MyLocalizations.of(context, "tutorial_txt"), () {}),
                // SizedBox(
                //   height: 10,
                // ),
                // SettingsMenuWidget(
                //     MyLocalizations.of(context, "mosquito_gallery_txt"), () {}),
                // SizedBox(
                //   height: 10,
                // ),
                SettingsMenuWidget(MyLocalizations.of(context, "open_web_txt"),
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            InfoPage('http://www.mosquitoalert.com')),
                  );
                }),
                SizedBox(
                  height: 10,
                ),
                // SettingsMenuWidget(
                //     MyLocalizations.of(context, "more_info_app_txt"), () {}),
                // SizedBox(
                //   height: 10,
                // ),
                SettingsMenuWidget(
                    MyLocalizations.of(context, "privacy_policy_txt"), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => InfoPage(
                            'http://webserver.mosquitoalert.com/es/privacy/')),
                  );
                }),
                SizedBox(
                  height: 10,
                ),
                // SettingsMenuWidget(
                //     MyLocalizations.of(context, "our_partners_txt"), () {}),
                // SizedBox(
                //   height: 10,
                // ),

                SettingsMenuWidget(
                    MyLocalizations.of(context, "disable_background_tracking"),
                    () {
                  _disableBgTracking();
                }),
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
    UserManager.setTracking(false);
    bg.BackgroundGeolocation.stop();
    bg.BackgroundGeolocation.stopSchedule();
  }
}
