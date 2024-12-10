import 'dart:async';

import 'package:mosquito_alert_app/pages/main/main_vc.dart';
import 'package:mosquito_alert_app/utils/BackgroundTracking.dart';
import 'package:workmanager/workmanager.dart';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mosquito_alert_app/utils/Application.dart';
import 'package:mosquito_alert_app/utils/MyLocalizationsDelegate.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:overlay_support/overlay_support.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main({String env = 'prod'}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiSingleton.initialize(env);

  try {
    await Firebase.initializeApp();
  } catch (err) {
    print('$err');
  }

  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false
  );

  // Start background tracking at midnight to ensure 5 random samples per day
  var now = DateTime.now().toLocal();
  var nextMidnight = DateTime(now.year, now.month, now.day + 1);
  var timeUntilMidnight = nextMidnight.difference(now);

  await Workmanager().registerPeriodicTask(
    'scheduleDailyTasks',
    'scheduleDailyTasks',
    tag: 'scheduleDailyTasks',
    frequency: Duration(days: 1),
    initialDelay: timeUntilMidnight,
  );

  runApp(MyApp());
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Firebase.initializeApp();

    switch (task) {
      case 'trackingTask':
        await BackgroundTracking.trackingTask();
        break;
      case 'scheduleDailyTasks':
        await BackgroundTracking.scheduleMultipleTrackingTask(5);
        break;
    }
    return Future.value(true);
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  static void setLocale(BuildContext context) {}
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<ConnectivityResult> subscription;

  MyLocalizationsDelegate _newLocaleDelegate = MyLocalizationsDelegate();

  @override
  void initState() {
    super.initState();

    //backgroud sync reports
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      print('Connectivity status changed to $result');
      switch (result) {
        case ConnectivityResult.mobile:
        case ConnectivityResult.wifi:
          Utils.checkForUnfetchedData();
          Utils.syncReports();
          break;
        case ConnectivityResult.none:
          break;
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
          colorScheme: ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFFEDB20C),
            onPrimary: Colors.black, 
            secondary: Color(0xFF7A3B69),
            onSecondary: Colors.white,
            error: Color(0xFFE94F37),
            onError: Colors.white,
            background: Colors.white,
            onBackground: Colors.black,
            surface: Colors.white,
            onSurface: Colors.black,
            // TODO: info #A3D9FF
            // TODO: positive #5BBA6F
          ),
          fontFamily: 'Nunito',
          textTheme: TextTheme(            
            titleMedium: TextStyle(
              color: Color(0xFF000000),
              fontSize: 25.0,
              fontWeight: FontWeight.w400,
            ),
            bodyMedium: TextStyle(
              color: Color(0xFF000000),
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
            ),
            bodySmall: TextStyle(
              color: Colors.grey[600],
              fontSize: 11.0,
              fontWeight: FontWeight.w400,
            ),
            labelMedium: TextStyle(
              color: Colors.white,
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
            labelSmall: TextStyle(
              color: Color(0xFF979797),
              fontSize: 10.0,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        navigatorKey: navigatorKey,
        home: MainVC(),
        localizationsDelegates: [
          _newLocaleDelegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: application.supportedLocales(),
      ),
    );
  }
}
