import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/app_config.dart';
import 'package:mosquito_alert_app/pages/main/drawer_and_header.dart';
import 'package:mosquito_alert_app/utils/Application.dart';
import 'package:mosquito_alert_app/utils/BackgroundTracking.dart';
import 'package:mosquito_alert_app/utils/MyLocalizationsDelegate.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:workmanager/workmanager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main({String env = 'prod'}) async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppConfig.setEnvironment(env);
  await ApiSingleton.initialize();

  try {
    await Firebase.initializeApp();
  } catch (err) {
    print('$err');
  }

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  bool trackingEnabled = await BackgroundTracking.isEnabled();
  if (trackingEnabled) {
    await BackgroundTracking.start(requestPermissions: false);
  } else {
    await BackgroundTracking.stop();
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  static void setLocale(BuildContext context) {}
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<List<ConnectivityResult>> subscription;

  MyLocalizationsDelegate _newLocaleDelegate = MyLocalizationsDelegate();

  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: FirebaseAnalytics.instance,
    routeFilter: (route) {
      return route is PageRoute && route.settings.name != '/';
    },
  );

  @override
  void initState() {
    super.initState();

    //backgroud sync reports
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      print('Connectivity status changed to $results');
      for (var result in results) {
        switch (result) {
          case ConnectivityResult.mobile:
          case ConnectivityResult.wifi:
            Utils.checkForUnfetchedData();
            Utils.syncReports();
            break;
          case ConnectivityResult.none:
            break;
          default:
            break;
        }
      }
    });
    application.onLocaleChanged = onLocaleChange;
  }

  void onLocaleChange(Locale locale) {
    setState(() {
      _newLocaleDelegate = MyLocalizationsDelegate(newLocale: locale);
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
      ),
      navigatorKey: navigatorKey,
      navigatorObservers: <NavigatorObserver>[
        observer,
      ],
      home: MainVC(),
      localizationsDelegates: [
        _newLocaleDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: application.supportedLocales(),
    ));
  }
}
