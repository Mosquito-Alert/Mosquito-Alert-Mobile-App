import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:badges/badges.dart' as badges;
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/app_config.dart';
import 'package:mosquito_alert_app/pages/info_pages/info_page_webview.dart';
import 'package:mosquito_alert_app/pages/main/home_page.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/my_reports_page.dart';
import 'package:mosquito_alert_app/pages/notification_pages/notifications_page.dart';
import 'package:mosquito_alert_app/pages/settings_pages/gallery_page.dart';
import 'package:mosquito_alert_app/pages/settings_pages/info_page.dart';
import 'package:mosquito_alert_app/pages/settings_pages/settings_page.dart';
import 'package:mosquito_alert_app/providers/auth_provider.dart';
import 'package:mosquito_alert_app/providers/device_provider.dart';
import 'package:mosquito_alert_app/providers/user_provider.dart';
import 'package:mosquito_alert_app/utils/BackgroundTracking.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/ObserverUtils.dart';
import 'package:mosquito_alert_app/utils/PushNotificationsManager.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class MainVC extends StatefulWidget {
  const MainVC({key});

  @override
  State<MainVC> createState() => _MainVCState();
}

class _MainVCState extends State<MainVC>
    with RouteAware, WidgetsBindingObserver {
  int _selectedIndex = 0;
  int unreadNotifications = 0;
  var packageInfo;
  String? userUuid;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startAsyncTasks();
  }

  @override
  void dispose() {
    ObserverUtils.routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ObserverUtils.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    // Called when returning from another page
    _fetchNotificationCount();
  }

  // Called when app lifecycle state changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchNotificationCount();
    }
  }

  Future<void> _onDrawerChanged(bool isOpened) async {
    await FirebaseAnalytics.instance.logEvent(
      name: isOpened ? 'drawer_open' : 'drawer_close',
    );
  }

  void _startAsyncTasks() async {
    await UserManager.startFirstTime(context);
    bool initSuccess = await initAuth();
    await PushNotificationsManager.init();
    if (initSuccess) {
      await initBackgroundTracking();
      FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
        final deviceProvider =
            Provider.of<DeviceProvider>(context, listen: false);
        await deviceProvider.updateFcmToken(fcmToken);
      });
    }
    setState(() {
      isLoading = !initSuccess;
    });
    await _fetchNotificationCount();
    await getPackageInfo();
  }

  Future<void> _fetchNotificationCount() async {
    int count = 0;
    try {
      MosquitoAlert apiClient =
          Provider.of<MosquitoAlert>(context, listen: false);
      NotificationsApi notificationsApi = apiClient.getNotificationsApi();

      final Response<PaginatedNotificationList> response =
          await notificationsApi.listMine(isRead: false, pageSize: 1);
      count = response.data?.count ?? 0;
    } catch (e, stackTrace) {
      print('Failed to fetch notification count: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
    setState(() {
      unreadNotifications = count;
    });
  }

  Future<bool> getPackageInfo() async {
    PackageInfo _packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      packageInfo = _packageInfo;
    });
    return true;
  }

  Future<bool> initAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);

    String? username = authProvider.username;
    String? password = authProvider.password;
    if (username == null && password == null) {
      // Create a guest user
      password = Utils.getRandomPassword(10);
      try {
        final GuestRegistration guestRegistration =
            await authProvider.createGuestUser(password: password);
        username = guestRegistration.username;
      } catch (e) {
        print('Error creating guest user: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create user: $e'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return false;
      }
    }

    // Check if the user is authenticated but the user data is not yet loaded
    if (userProvider.user == null) {
      try {
        // Try fetching user if already authenticated
        await userProvider.fetchUser();
      } catch (_) {
        // If fetching fails, try logging in and then fetch
        try {
          await authProvider.login(username: username!, password: password!);
          await userProvider.fetchUser();
        } catch (e) {
          print('Error logging in: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Login failed: $e'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return false;
        }
      }
    }
    // Register device
    try {
      await deviceProvider.registerDevice();
      if (deviceProvider.device != null) {
        await authProvider.setDevice(deviceProvider.device!);
      }
    } catch (e) {
      print('Error registering device: $e');
    }
    return true;
  }

  Future<void> initBackgroundTracking() async {
    BackgroundTracking.configure(
      apiClient: Provider.of<MosquitoAlert>(context, listen: false),
    );
    bool trackingEnabled = await BackgroundTracking.isEnabled();
    if (trackingEnabled) {
      await BackgroundTracking.start(requestPermissions: false);
    } else {
      await BackgroundTracking.stop();
    }
  }

  late final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    MyReportsPage(),
    GalleryPage(goBackToHomepage: _onItemTapped),
    InfoPage(),
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
          'assets/img/ic_logo.webp',
          height: 40,
        ),
        actions: <Widget>[
          badges.Badge(
              position: badges.BadgePosition.topEnd(top: 0, end: 3),
              showBadge: unreadNotifications > 0,
              badgeContent: Text(
                  unreadNotifications > 9 ? '+9' : '$unreadNotifications',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: unreadNotifications > 9 ? 10 : 13)),
              badgeStyle: badges.BadgeStyle(
                padding: unreadNotifications > 9
                    ? EdgeInsets.all(5)
                    : EdgeInsets.all(6),
                shape: badges.BadgeShape.circle,
                badgeColor: Colors.red,
                borderSide:
                    BorderSide(color: Colors.white, width: 2), // white border
              ),
              child: IconButton(
                  icon: Icon(Icons.notifications_none),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationsPage()),
                    );
                  }))
        ],
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : _widgetOptions[_selectedIndex],
      ),
      onDrawerChanged: (isOpened) async {
        await _onDrawerChanged(isOpened);
      },
      drawer: Drawer(
          backgroundColor: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                        child: Row(
                      children: <Widget>[
                        // User score
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  settings: RouteSettings(name: '/user_score'),
                                  builder: (context) => InfoPageInWebview(
                                      "${MyLocalizations.of(context, 'url_point_1')}$userUuid")),
                            );
                          },
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/img/points_box.webp'),
                              ),
                            ),
                            child: Consumer<UserProvider>(
                              builder: (context, userProvider, _) {
                                return Center(
                                  child: AutoSizeText(
                                    userProvider.userScore.toString(),
                                    maxLines: 1,
                                    maxFontSize: 26,
                                    minFontSize: 16,
                                    style: TextStyle(
                                        color: Color(0xFF4B3D04),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 24),
                                  ),
                                );
                              },
                            ),
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
                    )),
                    _buildCustomTile(0, Icons.home, 'home_tab', context),
                    _buildCustomTile(
                        1, Icons.file_copy, 'your_reports_txt', context),
                    _buildCustomTile(2, Icons.biotech, 'guide_tab', context),
                    _buildCustomTile(3, Icons.info, 'info_tab', context),
                    _buildCustomTile(
                        4, Icons.settings, 'settings_title', context),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    packageInfo != null
                        ? 'version ${packageInfo.version} (build ${packageInfo.buildNumber})'
                        : '',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 8.0,
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _uuidWithClipboard() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        String uuid = userProvider.user?.uuid ?? '';
        if (uuid.isEmpty) {
          // Don't show anything if UUID is not available
          return SizedBox.shrink();
        }
        return Row(
          children: [
            Text(
              'ID: ',
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.7),
                fontSize: 8,
              ),
            ),
            Container(
              width: 150,
              child: Text(
                uuid,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 8,
                ),
              ),
            ),
            GestureDetector(
              child: Icon(
                Icons.copy_rounded,
                size: 12,
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(text: uuid));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(MyLocalizations.of(
                        context, 'copied_to_clipboard_success')),
                  ),
                );
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildCustomTile(int index, IconData icon, String title, context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: _selectedIndex == index
              ? Colors.orange.shade200
              : Colors.transparent,
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: ListTile(
          title: Text(MyLocalizations.of(context, title),
              style: TextStyle(color: Colors.black)),
          leading: Icon(
            icon,
            color: Colors.black,
          ),
          minLeadingWidth: 0,
          selected: _selectedIndex == index,
          onTap: () {
            _onItemTapped(index);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
