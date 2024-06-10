import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:badges/badges.dart' as badges;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/models/notification.dart';
import 'package:mosquito_alert_app/pages/forms_pages/adult_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/biting_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/breeding_report_page.dart';
import 'package:mosquito_alert_app/pages/info_pages/info_page.dart';
import 'package:mosquito_alert_app/pages/main/components/custom_card_widget.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/my_reports_page.dart';
import 'package:mosquito_alert_app/pages/notification_pages/notifications_page.dart';
import 'package:mosquito_alert_app/pages/settings_pages/campaign_tutorial_page.dart';
import 'package:mosquito_alert_app/pages/settings_pages/settings_page.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:mosquito_alert_app/utils/version_control.dart';

class MainVC extends StatefulWidget {
  @override
  _MainVCState createState() => _MainVCState();
}

class _MainVCState extends State<MainVC> {
  String? userName;

  StreamController<String?> nameStream = StreamController<String?>.broadcast();
  String? userUuid;
  StreamController<bool> loadingStream = StreamController<bool>.broadcast();
  int unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    initAuthStatus();
    _getNotificationCount();
  }

  @override
  void dispose() {
    nameStream.close();
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
    if (UserManager.user != null) {
      nameStream.add(UserManager.user!.email);
      setState(() {
        userName = UserManager.user!.email;
      });
    }
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
            appBar: AppBar(
              backgroundColor: Colors.white,
              centerTitle: true,
              title: Image.asset(
                'assets/img/ic_logo.png',
                height: 40,
              ),
              actions: <Widget>[
                badges.Badge(
                  position: badges.BadgePosition.topEnd(top: 2, end: 2),
                  showBadge: unreadNotifications > 0,
                  badgeContent: Text('$unreadNotifications', style: TextStyle(color: Colors.white)),
                  child: IconButton(
                    padding: EdgeInsets.only(top: 6),
                    icon: Icon(Icons.notifications, size: 32, ), 
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NotificationsPage(onNotificationUpdate: updateNotificationCount)),
                      );
                    },
                  )
                )
              ],
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    child: Row(
                      children: <Widget>[
                        // User score
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/img/points_box.png'),
                            ),
                          ),
                          child: StreamBuilder<int?>(
                            stream: Utils
                                .userScoresController
                                .stream,
                            initialData:
                                UserManager.userScore,
                            builder: (context, snapshot) {
                              return Center(
                                  child: AutoSizeText(
                                snapshot.data != null &&
                                        snapshot.hasData
                                    ? snapshot.data
                                        .toString()
                                    : '',
                                maxLines: 1,
                                maxFontSize: 26,
                                minFontSize: 16,
                                style: TextStyle(
                                    color:
                                        Color(0xFF4B3D04),
                                    fontWeight:
                                        FontWeight.w500,
                                    fontSize: 24),
                              ));
                            }),
                        ),

                        SizedBox(width: 12),

                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 50.0, right: 135.0, bottom: 10.0),
                              child: 
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  'Hello,',
                                  style: TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                            _uuidWithClipboard(),
                          ],
                        )
                      ],
                    )
                  ),
                  // TODO: Does it make sense to have HomePage here when it's always the base widget?
                  /*ListTile(
                    title: const Text('Home'),
                    leading: Icon(Icons.home),
                    onTap: () {

                    },
                  ),*/
                  ListTile(
                    title: const Text('My reports'),
                    leading: Icon(Icons.file_copy),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyReportsPage()),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Public map'),
                    leading: Icon(Icons.map),
                    onTap: () {
                      // TODO: Public map
                    },
                  ),
                  ListTile(
                    title: const Text('Guide'),
                    leading: Icon(Icons.science),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CampaignTutorialPage()),
                      );
                    },
                  ),
                  ListTile(
                    title: Text(MyLocalizations.of(context, 'settings_title')),
                    leading: Icon(Icons.settings),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsPage()),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('About'),
                    leading: Icon(Icons.info),
                    onTap: () {
                      // TODO: About page
                    },
                  )
                ],
              )),
            body: LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                StreamBuilder<String?>(
                                                    stream: nameStream.stream,
                                                    initialData: userName,
                                                    builder: (context,
                                                        AsyncSnapshot<String?>
                                                            snapshot) {
                                                      if (snapshot.hasData) {
                                                        print(snapshot.data);
                                                        return Style.title(
                                                            "${MyLocalizations.of(context, "welcome_text")}, ${snapshot.data}.",
                                                            fontSize: 20);
                                                      } else {
                                                        return Style.title(
                                                            "${MyLocalizations.of(context, "welcome_text")}",
                                                            fontSize: 20);
                                                      }
                                                    }),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Style.body(
                                                    MyLocalizations.of(context,
                                                        'what_to_do_txt'),
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
                                                      "${MyLocalizations.of(context, 'url_point_1')}$userUuid")),
                                            );
                                          },
                                          child: Container(
                                            height: 60,
                                            width: 60,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage(
                                                    'assets/img/points_box.png'),
                                              ),
                                            ),
                                            child: StreamBuilder<int?>(
                                                stream: Utils
                                                    .userScoresController
                                                    .stream,
                                                initialData:
                                                    UserManager.userScore,
                                                builder: (context, snapshot) {
                                                  return Center(
                                                      child: AutoSizeText(
                                                    snapshot.data != null &&
                                                            snapshot.hasData
                                                        ? snapshot.data
                                                            .toString()
                                                        : '',
                                                    maxLines: 1,
                                                    maxFontSize: 26,
                                                    minFontSize: 16,
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF4B3D04),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 24),
                                                  ));
                                                }),
                                          ),
                                        ),
                                      ]),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6.0),
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          child: CustomCard(
                                            img:
                                                'assets/img/ic_bite_report.png',
                                            title: MyLocalizations.of(
                                                context, 'report_biting_txt'),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          loadingStream.add(true);
                                          _createAdultReport();
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          child: CustomCard(
                                            img:
                                                'assets/img/ic_mosquito_report.png',
                                            title: MyLocalizations.of(
                                                context, 'report_adults_txt'),
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
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
                                            ),
                                          )),
                                      Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
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
                                              img:
                                                  'assets/img/ic_my_reports.png',
                                              title: MyLocalizations.of(
                                                  context, 'your_reports_txt'),
                                            ),
                                          )),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
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
            )),
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

  Widget _uuidWithClipboard(){
    return FutureBuilder(
      future: UserManager.getUUID(),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          print(snapshot.data);
          return Row(
            children: [
              Text(snapshot.data ?? '',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 9
                )
              ),
              GestureDetector(
                child: Icon(
                  Icons.copy_rounded,
                  size: 18,
                ),
                onTap: () {
                  final data = snapshot.data;
                  if (data != null) {
                    Clipboard.setData(ClipboardData(text: data));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied to Clipboard'),
                      ),
                    );
                  } else {
                    // Display an error message for troubleshooting
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: Unable to copy to clipboard. Data is null.'),
                      ),
                    );
                  }
                },
              )
            ],            
          );
        }
      },
    );
  }

  _createBiteReport() async {
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

  _createAdultReport() async {
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

  _createSiteReport() async {
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
