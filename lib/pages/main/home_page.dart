import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/models/notification.dart';
import 'package:mosquito_alert_app/pages/forms_pages/adult_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/biting_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/breeding_report_page.dart';
import 'package:mosquito_alert_app/pages/main/components/custom_card_widget.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:mosquito_alert_app/utils/version_control.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userUuid;
  StreamController<bool> loadingStream = StreamController<bool>.broadcast();
  int unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    initAuthStatus();
  }

  @override
  void dispose() {
    loadingStream.close();
    super.dispose();
  }

  void initAuthStatus() async {
    loadingStream.add(true);

    if (Platform.isIOS) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
    VersionControl.getInstance().packageApiKey =
        'uqFb4yrdZCPFXsvXrJHBbJg5B5TqvSCYmxR7aPuN2uCcCKyu9FDVWettvbtNV9HKm';
    VersionControl.getInstance().packageLanguageCode = 'es';
    var check = await VersionControl.getInstance().checkVersion(context);
    if (check != null && check) {
      _getData();
    }

    loadingStream.add(false);
  }

  void _getData() async {
    await UserManager.startFirstTime(context);
    userUuid = await UserManager.getUUID();
    UserManager.userScore = await ApiSingleton().getUserScores();
    await UserManager.setUserScores(UserManager.userScore);
    await Utils.loadFirebase();

    await Utils.getLocation(context);
  }

  void _getNotificationCount() async {
    List<MyNotification> notifications = await ApiSingleton().getNotifications();
    var unacknowledgedCount = notifications.where((notification) => notification.acknowledged == false).length;
    updateNotificationCount(unacknowledgedCount);
  }

  void updateNotificationCount(int newCount) {
    setState(() {
      unreadNotifications = newCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.bottomCenter,
                          child: Image.asset(
                            'assets/img/bottoms/bottom_main.png',
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.bottomCenter,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 24,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Style.body(
                                              MyLocalizations.of(context, 'what_to_do_txt'),
                                              fontSize: 16),
                                        ]),
                                    )                                      
                                  ]
                                ),
                                SizedBox(height: 25),
                                CustomCard(
                                  text: 'single_mosquito',
                                  image_path: 'assets/img/ic_mosquito_report.png',
                                  color: '40DFD458',
                                  reportFunction: _createAdultReport
                                ),
                                SizedBox(height: 15),
                                CustomCard(
                                  text: 'single_bite',
                                  image_path: 'assets/img/ic_bite_report.png',
                                  color: '40D28A73',
                                  reportFunction: _createBiteReport
                                ),
                                SizedBox(height: 15),
                                CustomCard(
                                  text: 'single_breeding_site',
                                  image_path: 'assets/img/ic_breeding_report.png',
                                  color: '407D9393',
                                  reportFunction: _createSiteReport
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
        ),
        Positioned.fill(
          child: StreamBuilder<bool>(
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
          ),
        )
      ],
    );
  }

  Future<void> _createBiteReport() async {
    var createReport = await Utils.createNewReport('bite');
    loadingStream.add(false);
    if (createReport) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BitingReportPage()),
      );
    } else {
      print('Bite report was not created');
      loadingStream.add(false);
      await Utils.showAlert(MyLocalizations.of(context, 'app_name'),
          MyLocalizations.of(context, 'server_down'), context);
    }
  }

  Future<void> _createAdultReport() async {
    var createReport = await Utils.createNewReport('adult');
    loadingStream.add(false);
    if (createReport) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdultReportPage()),
      );
    } else {
      print('Adult report was not created');
      loadingStream.add(false);
      await Utils.showAlert(MyLocalizations.of(context, 'app_name'),
          MyLocalizations.of(context, 'server_down'), context);
    }
  }

  Future<void> _createSiteReport() async {
    var createReport = await Utils.createNewReport('site');
    loadingStream.add(false);
    if (createReport) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BreedingReportPage()),
      );
    } else {
      print('Site report was not created');
      loadingStream.add(false);
      await Utils.showAlert(MyLocalizations.of(context, 'app_name'),
          MyLocalizations.of(context, 'server_down'), context);
    }
  }
}