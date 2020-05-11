import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/pages/auth/login_email_page.dart';
import 'package:mosquito_alert_app/pages/main/main_vc.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class LoginMainPage extends StatefulWidget {
  @override
  _LoginMainPageState createState() => _LoginMainPageState();
}

class _LoginMainPageState extends State<LoginMainPage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
            child: Container(
          child: Column(children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  decoration: new BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Image.asset("assets/img/bg_login.png"),
                ),
                SafeArea(
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Style.title(MyLocalizations.of(context, "welcome_app_title")),
                  Style.body(MyLocalizations.of(context, "login_method_txt")),
                  SizedBox(
                    height: 20,
                  ),
                  Style.loginButton(
                      SvgPicture.asset(
                        'assets/img/ic_facebook.svg',
                        height: 21,
                        fit: BoxFit.fitHeight,
                      ),
                      MyLocalizations.of(context, "login_btn1"),
                      Color(0XFF3B5998),
                      Colors.white, () {
                    _facebookSignIn();
                  }),
                  SizedBox(
                    height: 10,
                  ),
                  Style.loginButton(
                      SvgPicture.asset(
                        'assets/img/ic_google.svg',
                        height: 21,
                        fit: BoxFit.fitHeight,
                      ),
                      MyLocalizations.of(context, "login_btn2"),
                      Colors.white,
                      Colors.black, () {
                    _googleSignIn();
                  }, colorBorder: Colors.black.withOpacity(0.1)),
                  SizedBox(
                    height: 10,
                  ),
                  Style.loginButton(
                      SvgPicture.asset(
                        'assets/img/ic_apple.svg',
                        height: 21,
                        fit: BoxFit.fitHeight,
                      ),
                      MyLocalizations.of(context, "login_btn3"),
                      Colors.black,
                      Colors.white,
                      () {},
                      colorBorder: Colors.black.withOpacity(0.1)),
                  SizedBox(
                    height: 20,
                  ),
                  Divider(),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: double.infinity,
                    child: Style.noBgButton(
                        MyLocalizations.of(context, "login_btn4"), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginEmail()),
                      );
                    }, textColor: Colors.black),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                      alignment: Alignment.bottomCenter,
                      child: Style.body(
                        MyLocalizations.of(context, "terms_and_conditions_txt"),
                        textAlign: TextAlign.center,
                        color: Style.greyColor,
                      ))
                ],
              ),
            ),
          ]),
        )),
      ),
    );
  }

  _showSocialError() {
    //TODO: set texts
    Utils.showAlert(MyLocalizations.of(context, "app_name"), "text", context);
  }

  _googleSignIn() async {
    //TODO: add loading
    ApiSingleton().sigInWithGoogle().then((FirebaseUser user) async {
      //TODO: save token
      print(user);
      if (user != null) {
        await UserManager.setUserName(user.displayName);
        var createProfile = ApiSingleton().createProfile(user.uid);

        if (createProfile == true) {}
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainVC()),
        );
      }
    }).catchError((e) {
      _showSocialError();
      print(e);
    });
  }

  _facebookSignIn() async {
    //TODO: add loading
    ApiSingleton().singInWithFacebook().then((FirebaseUser user) {
      //TODO: save token
      print(user);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainVC()),
      );
    }).catchError((e) {
      _showSocialError();
      print(e);
    });
  }
}
