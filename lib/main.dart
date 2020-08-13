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

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.ancestorStateOfType(TypeMatcher<_MyAppState>());

    state.setState(() {
      state.language = newLocale;
    });
  }
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Locale language = Utils.language;

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

    this._fetchLocale().then((language) {
      setState(() {
        this.language = language;
      });
    });
  }

  Future<Locale> _fetchLocale() async {
    String lang = await UserManager.getLanguage();
    String country = await UserManager.getLanguageCountry();

    if (lang == null) {
      return Utils.language;
    }
    
    return Locale(lang, country);
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
            locale: Utils.language,
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
            ],
          );
        });
  }
}
