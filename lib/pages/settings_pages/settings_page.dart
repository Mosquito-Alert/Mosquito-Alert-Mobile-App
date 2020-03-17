import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/pages/auth/login_main_page.dart';
import 'package:mosquito_alert_app/pages/settings_pages/components/settings_menu_widget.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
              SizedBox(
                height: 35,
              ),
              SettingsMenuWidget(
                  MyLocalizations.of(context, "login_with_your_account_txt"),
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginMainPage()),
                );
              }),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Style.bodySmall(
                    MyLocalizations.of(context, "use_your_acount_details_txt"),
                    color: Colors.grey),
              ),
              SizedBox(
                height: 35,
              ),
              SettingsMenuWidget(
                  MyLocalizations.of(context, "share_app_txt"), () {}),
              SizedBox(
                height: 10,
              ),
              SettingsMenuWidget(
                  MyLocalizations.of(context, "open_web_txt"), () {}),
              SizedBox(
                height: 10,
              ),
              SettingsMenuWidget(
                  MyLocalizations.of(context, "more_info_app_txt"), () {}),
              SizedBox(
                height: 10,
              ),
              SettingsMenuWidget(
                  MyLocalizations.of(context, "our_partners_txt"), () {}),
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
            ]),
          ),
        ),
      ),
    );
  }
}
