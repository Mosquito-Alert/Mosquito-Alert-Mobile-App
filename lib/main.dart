import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/pages/auth/login_main_page.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mosquito alert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Rubik',
        primarySwatch: Colors.orange,
      ),
      home: LoginMainPage(),
      localizationsDelegates: [
        const MyLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        // CupertinoEnLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('es'),
      ],
    );
  }
}
