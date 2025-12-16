import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/app.dart';
import 'package:mosquito_alert_app/app_config.dart';
import 'package:mosquito_alert_app/core/utils/random.dart';
import 'package:mosquito_alert_app/features/auth/presentation/state/auth_provider.dart';
import 'package:mosquito_alert_app/features/device/presentation/state/device_provider.dart';
import 'package:mosquito_alert_app/features/fixes/services/tracking_service.dart';
import 'package:mosquito_alert_app/features/notifications/data/firebase_messaging_service.dart';
import 'package:mosquito_alert_app/features/notifications/presentation/state/notification_provider.dart';
import 'package:mosquito_alert_app/features/notifications/presentation/widgets/notification_badge.dart';
import 'package:mosquito_alert_app/features/user/presentation/state/user_provider.dart';
import 'package:mosquito_alert_app/screens/widgets/custom_drawer.dart';
import 'package:mosquito_alert_app/core/localizations/MyLocalizations.dart';
import 'package:mosquito_alert_app/core/utils/ObserverUtils.dart';
import 'package:provider/provider.dart';
import 'package:mosquito_alert_app/features/settings/presentation/pages/settings_page.dart';
import 'package:mosquito_alert_app/screens/home_page.dart';
import 'package:mosquito_alert_app/screens/my_reports_page.dart';
import 'package:mosquito_alert_app/screens/guide_page.dart';
import 'package:mosquito_alert_app/screens/settings_pages/info_page.dart';

class LayoutPage extends StatefulWidget {
  @override
  _LayoutPageState createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage>
    with RouteAware, WidgetsBindingObserver {
  int _selectedDrawerIndex = 0;

  late final NotificationProvider notificationProvider;

  @override
  void initState() {
    super.initState();
    notificationProvider = context.read<NotificationProvider>();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
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

  // Called when app lifecycle state changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      notificationProvider.fetchUnreadNotificationsCount();
    }
  }

  void _initialize() async {
    try {
      bool isSuccess = await _initUser();
      if (isSuccess) {
        await _initTrackingService();
        await _initNotificationsService();
      }
    } catch (e) {
      // Handle errors if needed
      debugPrint('Initialization error: $e');
    }
  }

  Future<bool> _initUser() async {
    final appConfig = await AppConfig.loadConfig();
    if (!appConfig.useAuth) {
      // Requesting permissions on automated tests creates many problems
      // and mocking permission acceptance is difficult on Android and iOS
      return true;
    }

    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final deviceProvider = context.read<DeviceProvider>();

    if (userProvider.user != null) {
      return true; // User is already initialized
    }

    if (userProvider.user == null) {
      try {
        await userProvider.fetchUser();
      } catch (_) {
        // If fetching fails, try logging in and then fetch
        try {
          await authProvider.login(
            username: authProvider.username!,
            password: authProvider.password!,
          );
          await userProvider.fetchUser();
        } catch (e) {
          _showErrorSnackBar(e.toString());
          return false;
        }
      }
    }

    if (authProvider.needNewPassword) {
      await authProvider.changePassword(password: getRandomPassword(10));
    }

    // TODO: auto register device on login.
    // Register device
    try {
      await deviceProvider.registerDevice();
      if (deviceProvider.device != null) {
        await authProvider.setDevice(deviceProvider.device!);
      }
    } catch (e) {
      debugPrint('Error registering device: $e');
    }
    return true;
  }

  Future<void> _initTrackingService() async {
    await TrackingService.configure(
      apiClient: Provider.of<MosquitoAlert>(context, listen: false),
    );

    final trackingEnabled = await TrackingService.isEnabled;
    if (trackingEnabled) {
      await TrackingService.start();
    } else {
      await TrackingService.stop();
    }
  }

  Future<void> _initNotificationsService() async {
    unawaited(
      Future(() async {
        await notificationProvider.refresh();
      }),
    );
    final deviceProvider = context.read<DeviceProvider>();
    await FirebaseMessagingService(
      navigatorKey: navigatorKey,
    ).init(deviceProvider: deviceProvider);
  }

  void _showErrorSnackBar(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = context.watch<UserProvider>();

    final drawerItems = <CustomDrawerItem>[
      CustomDrawerItem(
        icon: Icons.home,
        title: MyLocalizations.of(context, 'home_tab'),
        destination: HomePage(),
      ),
      CustomDrawerItem(
        icon: Icons.file_copy,
        title: MyLocalizations.of(context, 'your_reports_txt'),
        destination: MyReportsPage(),
      ),
      CustomDrawerItem(
        icon: Icons.biotech,
        title: MyLocalizations.of(context, 'guide_tab'),
        destination: GuidePage(
          goBackToHomepage: () {
            setState(() {
              _selectedDrawerIndex = 0;
            });
          },
        ),
      ),
      CustomDrawerItem(
        icon: Icons.info,
        title: MyLocalizations.of(context, 'info_tab'),
        destination: InfoPage(),
      ),
      CustomDrawerItem(
        icon: Icons.settings,
        title: MyLocalizations.of(context, 'settings_title'),
        destination: SettingsPage(),
      ),
    ];

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Image.asset('assets/img/ic_logo.webp', height: 40),
          actions: <Widget>[NotificationBadge()],
        ),
        drawer: CustomDrawer(
          selectedIndex: _selectedDrawerIndex,
          items: drawerItems,
          onTapChanged: (index) => setState(() {
            _selectedDrawerIndex = index;
          }),
        ),
        onDrawerChanged: (isOpened) async {
          await FirebaseAnalytics.instance.logEvent(
            name: isOpened ? 'drawer_open' : 'drawer_close',
          );
        },
        body: userProvider.isLoading
            ? Center(child: CircularProgressIndicator())
            : userProvider.user == null
            ? _retryPage()
            : drawerItems[_selectedDrawerIndex].destination,
      ),
    );
  }

  Widget _retryPage() {
    return Center(
      key: Key("retryPage"),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(MyLocalizations.of(context, 'loading_failed_try_again')),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _initUser();
              },
              child: Text(MyLocalizations.of(context, 'retry')),
            ),
          ],
        ),
      ),
    );
  }
}
