import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mosquito_alert_app/pages/auth/login_email_page.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class LoginMainPage extends StatefulWidget {
  @override
  _LoginMainPageState createState() => _LoginMainPageState();
}

class _LoginMainPageState extends State<LoginMainPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
            child: Container(
          child: Column(children: <Widget>[
            Container(
              width: double.infinity,
              decoration: new BoxDecoration(
                color: Colors.white,
              ),
              child: Image.asset("assets/img/bg_login.png"),
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
                      Colors.white,
                      () {}),
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
                      Colors.black,
                      () {},
                      colorBorder: Colors.black.withOpacity(0.1)),
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
}
