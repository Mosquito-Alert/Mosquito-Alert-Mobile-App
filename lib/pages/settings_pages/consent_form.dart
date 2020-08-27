import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/pages/settings_pages/tutorial_page.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:url_launcher/url_launcher.dart';

class ConsentForm extends StatefulWidget {
  @override
  _ConsentFormState createState() => _ConsentFormState();
}

class _ConsentFormState extends State<ConsentForm> {
  Widget linkText(text, link) {
    return InkWell(
      onTap: () async {
        if (await canLaunch(link))
          await launch(link);
        else
          throw 'Could not launch $link';
      },
      child: Text(text,
          style: TextStyle(
              color: Style.colorPrimary,
              fontSize: 14,
              decoration: TextDecoration.underline)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Image.asset(
          'assets/img/ic_logo.png',
          height: 40,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Style.body(MyLocalizations.of(context, "consent_form_txt_1")),
                Container(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    children: <Widget>[
                      Style.body(
                          MyLocalizations.of(context, "consent_form_txt_2")),
                      linkText(MyLocalizations.of(context, "terms_of_use"),
                          'http://webserver.mosquitoalert.com/es/terms/'),
                      Style.body(
                          MyLocalizations.of(context, "consent_form_txt_3")),
                      linkText(
                          MyLocalizations.of(
                              context, "privacy_policy_data_txt"),
                          'http://webserver.mosquitoalert.com/es/privacy/'),
                      Style.body(
                          MyLocalizations.of(context, "consent_form_txt_4")),
                      linkText(
                          MyLocalizations.of(
                                  context, "mosquito_webserver_txt") +
                              '.',
                          MyLocalizations.of(
                              context, "mosquito_webserver_txt")),
                      Style.body(
                          MyLocalizations.of(context, "consent_form_txt_5")),
                    ],
                  ),
                ),
                Style.body('\n' +
                    MyLocalizations.of(context, "consent_form_title") +
                    '\n'),
                Container(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    children: <Widget>[
                      Style.body("He leído y acepto las "),
                      linkText(MyLocalizations.of(context, "terms_of_use"),
                          "http://webserver.mosquitoalert.com/es/terms/"),
                      Style.body(
                          MyLocalizations.of(context, "consent_form_txt_3")),
                      linkText(
                          MyLocalizations.of(
                                  context, "privacy_policy_data_txt") +
                              '.',
                          "")
                    ],
                  ),
                ),
                Style.body(MyLocalizations.of(context, "consent_form_txt_6")),
                Style.body("· Blabla"),
                Style.body("· Blabla"),
                Container(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    children: <Widget>[
                      Style.body(
                          MyLocalizations.of(context, "consent_form_txt_7")),
                      linkText(
                          MyLocalizations.of(
                              context, "privacy_policy_data_txt"),
                          'http://webserver.mosquitoalert.com/es/terms/'),
                      Style.body(
                          MyLocalizations.of(context, "consent_form_txt_8")),
                      linkText(MyLocalizations.of(context, "terms_of_use"),
                          'http://webserver.mosquitoalert.com/es/terms/'),
                      Style.body(
                          MyLocalizations.of(context, "consent_form_txt_9")),
                    ],
                  ),
                ),
                Style.body(MyLocalizations.of(context, "consent_form_txt_10")),
                Container(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    children: <Widget>[
                      Style.body(
                          MyLocalizations.of(context, "consent_form_txt_11")),
                      linkText(MyLocalizations.of(context, "terms_of_use"),
                          'http://webserver.mosquitoalert.com/es/terms/'),
                      Style.body(
                          MyLocalizations.of(context, "consent_form_txt_3")),
                      linkText(
                          MyLocalizations.of(
                              context, "privacy_policy_data_txt"),
                          'http://webserver.mosquitoalert.com/es/privacy/'),
                      Style.body(
                          MyLocalizations.of(context, "consent_from_txt_12")),
                    ],
                  ),
                ),
                Style.body(MyLocalizations.of(context, "consent_form_txt_13")),
                Container(
                  padding: EdgeInsets.only(left: 25),
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    children: <Widget>[
                      Style.body(
                          MyLocalizations.of(context, "consent_form_txt_14")),
                      linkText(MyLocalizations.of(context, "terms_of_use"),
                          'http://webserver.mosquitoalert.com/es/terms/'),
                      Style.body(
                          MyLocalizations.of(context, "consent_form_txt_3")),
                      linkText(
                          MyLocalizations.of(
                              context, "privacy_policy_data_txt"),
                          'http://webserver.mosquitoalert.com/es/privacy/'),
                      Style.body(
                          MyLocalizations.of(context, "consent_from_txt_12")),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: Style.body(
                      MyLocalizations.of(context, "consent_form_txt_15")),
                ),
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: false,
                      onChanged: (newValue) {},
                      
                    ),
                    Expanded(
                      child: Style.body(
                          MyLocalizations.of(context, "consent_form_txt_16")),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  child: Style.button("continuar", () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TutorialPage(false)));
                  }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
