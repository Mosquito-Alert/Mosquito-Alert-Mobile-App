import 'package:flutter/material.dart';

import 'package:mosquito_alert_app/pages/info_pages/info_page_webview.dart';
import 'package:mosquito_alert_app/pages/settings_pages/components/settings_menu_widget.dart';
import 'package:mosquito_alert_app/pages/settings_pages/gallery_page.dart';
import 'package:mosquito_alert_app/pages/settings_pages/partners_page.dart';
import 'package:mosquito_alert_app/pages/settings_pages/tutorial_page.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';

class NewInfoPage extends StatefulWidget {
  NewInfoPage();

  @override
  _NewInfoPageState createState() => _NewInfoPageState();
}

class _NewInfoPageState extends State<NewInfoPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: key,

      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(15),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                  Widget>[

            SizedBox(
              height: 35,
            ),
            SettingsMenuWidget(
                MyLocalizations.of(context, 'mosquitos_gallery_txt'), () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GalleryPage()),
              );
            }),
            SizedBox(
              height: 10,
            ),
            SettingsMenuWidget(MyLocalizations.of(context, 'tutorial_txt'), () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TutorialPage(true)),
              );
            }),
            SizedBox(
              height: 10,
            ),
            SettingsMenuWidget(MyLocalizations.of(context, 'info_scores_txt'),
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        InfoPageInWebview(MyLocalizations.of(context, 'url_scoring_1'))),
              );
            }),
            SizedBox(
              height: 10,
            ),
            SettingsMenuWidget(
                MyLocalizations.of(context, 'about_the_project_txt'), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InfoPageInWebview(
                        MyLocalizations.of(context, 'url_about_project'))),
              );
            }),
            SizedBox(
              height: 10,
            ),
            SettingsMenuWidget(MyLocalizations.of(context, 'coordination_txt'),
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        InfoPageInWebview(MyLocalizations.of(context, 'url_about_us'))),
              );
            }),
            SizedBox(
              height: 10,
            ),
            SettingsMenuWidget(MyLocalizations.of(context, 'partners_txt'), () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PartnersPage()),
              );
            }),
            SizedBox(
              height: 30,
            ),
            SettingsMenuWidget(MyLocalizations.of(context, 'terms_of_use_txt'),
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InfoPageInWebview(
                          MyLocalizations.of(context, 'terms_link'),
                          localHtml: true,
                        )),
              );
            }),
            SizedBox(
              height: 10,
            ),
            SettingsMenuWidget(MyLocalizations.of(context, 'privacy_txt'), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InfoPageInWebview(
                          MyLocalizations.of(context, 'privacy_link'),
                          localHtml: true,
                        )),
              );
            }),
            SizedBox(
              height: 10,
            ),
            SettingsMenuWidget(MyLocalizations.of(context, 'license_txt'), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InfoPageInWebview(
                          MyLocalizations.of(context, 'lisence_link'),
                          localHtml: true,
                        )),
              );
            }),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 60,
            ),
          ]),
        ),
      ),
    );
  }
}
