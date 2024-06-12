import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/services.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/models/notification.dart';
import 'package:mosquito_alert_app/pages/info_pages/info_page.dart';
import 'package:mosquito_alert_app/pages/main/home_page.dart';
import 'package:mosquito_alert_app/pages/map/punlic_map.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/my_reports_page.dart';
import 'package:mosquito_alert_app/pages/notification_pages/notifications_page.dart';
import 'package:mosquito_alert_app/pages/settings_pages/settings_page.dart';
import 'package:mosquito_alert_app/pages/settings_pages/tutorial_page.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:package_info/package_info.dart';



class MainVC extends StatefulWidget {
  const MainVC({key});

  @override
  State<MainVC> createState() => _MainVCState();
}

class _MainVCState extends State<MainVC> {
  int _selectedIndex = 0;
  int unreadNotifications = 0;
  var packageInfo;

  @override
  void initState() {
    super.initState();
    _getNotificationCount();
    getPackageInfo();
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

  void getPackageInfo() async {
    var _packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      packageInfo = _packageInfo;
    });
  }

  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    MyReportsPage(),
    PublicMap(),
    TutorialPage(true),
    SettingsPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
      body: Center(
        child: _widgetOptions[_selectedIndex],
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
                        image: AssetImage('assets/img/points_box.png'),
                      ),
                    ),
                    child: StreamBuilder<int?>(
                      stream: Utils.userScoresController.stream,
                      initialData: UserManager.userScore,
                      builder: (context, snapshot) {
                        return Center(
                          child: AutoSizeText(
                            snapshot.data != null && snapshot.hasData
                              ? snapshot.data.toString()
                              : '',
                            maxLines: 1,
                            maxFontSize: 26,
                            minFontSize: 16,
                            style: TextStyle(
                              color: Color(0xFF4B3D04),
                              fontWeight: FontWeight.w500,
                              fontSize: 24),
                          )
                        );
                      }
                    ),
                  ),

                  SizedBox(width: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 50.0, bottom: 10.0),
                        child: Text(
                          MyLocalizations.of(context, 'welcome_text'),
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                      _uuidWithClipboard(),
                    ],
                  )
                ],
              )
            ),
            ListTile(
              title: Text(MyLocalizations.of(context, 'home_tab')),
              leading: Icon(Icons.home),
              selected: _selectedIndex == 0,
              onTap: () {
                // Update the state of the app
                _onItemTapped(0);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(MyLocalizations.of(context, 'your_reports_txt')),
              leading: Icon(Icons.file_copy),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(MyLocalizations.of(context, 'public_map_tab')),
              leading: Icon(Icons.map),
              selected: _selectedIndex == 2,
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(MyLocalizations.of(context, 'guide_tab')),
              leading: Icon(Icons.science),
              selected: _selectedIndex == 3,
              onTap: () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(MyLocalizations.of(context, 'settings_title')),
              leading: Icon(Icons.settings),
              selected: _selectedIndex == 4,
              onTap: () {
                _onItemTapped(4);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(MyLocalizations.of(context, 'info_tab')),
              leading: Icon(Icons.info),
              selected: _selectedIndex == 5,
              onTap: () {
                _onItemTapped(5);
                Navigator.pop(context);
              },
            ),
            SizedBox(
              height: 100,
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Style.bodySmall(
                    packageInfo != null
                        ? 'version ${packageInfo.version} (build ${packageInfo.buildNumber})'
                        : '',
                    fontSize: 8,
                    textAlign: TextAlign.center),
                ],
              ),
            ),
          ],
        ),
      ),
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
        }

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
    );
  }
}