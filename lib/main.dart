import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/pages/main/main_vc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mosquito_alert_app/utils/MyLocalizationsDelegate.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';

main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  static void setLocale(BuildContext context) {
    _MyAppState state = context.ancestorStateOfType(TypeMatcher<_MyAppState>());

    state.setState(() {
      state.language = Utils.language;
    });
  }
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Locale language = Utils.language;

  StreamSubscription<ConnectivityResult> subscription;

  @override
  void initState() {
    super.initState();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
    });

    //backgroud sync reports
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      switch (result) {
        case ConnectivityResult.mobile:
        case ConnectivityResult.wifi:
          Utils.syncReports();
          break;
        case ConnectivityResult.none:
          break;
      }
    });

    //fetch locale
    this._fetchLocale().then((language) {
      setState(() {
        this.language = language;
      });
    });
  }

  Future<Locale> _fetchLocale() async {
    await Utils.getLanguage();
    return Utils.language;
  }

  @override
  dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Utils.loadTranslations(),
        builder: (context, AsyncSnapshot snapshot) {
          return MaterialApp(
            title: 'Mosquito alert',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'Rubik',
              primarySwatch: Colors.orange,
            ),
            home: snapshot.hasData
                ? MainVC()
                : Scaffold(
                    body: Container(
                      margin: EdgeInsets.all(10),
                      child: Center(
                        child: Image.asset('assets/img/ic_logo.png'),
                      ),
                    ),
                  ),
            locale: language,
            // localeResolutionCallback:
            //     (Locale newLocale, Iterable<Locale> supportedLocales) {
            //   if (supportedLocales.any((loc) => loc == newLocale)) {
            //     language = newLocale;
            //   } else {
            //     language = Locale('en', 'US');
            //   }

            //   Utils.language = language;

            //   return newLocale;
            // },
            localizationsDelegates: [
              const MyLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('es', "ES"),
              const Locale('en', "US"),
              const Locale('ca', "ES"),
              const Locale('sq', "AL"),
              const Locale('bg', "BG"),
              const Locale('nl', "NL"),
              const Locale('de', "DE"),
              const Locale('it', "IT"),
              const Locale('pt', "PT"),
              const Locale('ro', "RO"),
            ],
          );
        });
  }
}
