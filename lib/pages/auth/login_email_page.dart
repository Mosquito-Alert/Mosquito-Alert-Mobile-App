import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/pages/auth/login_password_page.dart';
import 'package:mosquito_alert_app/pages/auth/signup_page.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class LoginEmail extends StatefulWidget {
  @override
  _LoginEmailState createState() => _LoginEmailState();
}

class _LoginEmailState extends State<LoginEmail> {
  TextEditingController _emailController = TextEditingController();
  StreamController<bool> loadingStream = StreamController<bool>.broadcast();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.topCenter,
          decoration: new BoxDecoration(
            color: Colors.white,
          ),
          child: SvgPicture.asset(
            'assets/img/bg_login_small.svg',
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            title: Image.asset('assets/img/ic_logo.png', width: 200),
          ),
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: ClampingScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 80,
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Style.titleMedium(MyLocalizations.of(
                                context, "enter_email_title")),
                            SizedBox(
                              height: 20,
                            ),
                            Style.textField(
                                MyLocalizations.of(context, "email_txt"),
                                _emailController,
                                context),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                                width: double.infinity,
                                child: Style.button(
                                    MyLocalizations.of(context, "access_txt"),
                                    () {
                                  _checkEmail();
                                })),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                          margin: EdgeInsets.all(10.0),
                          alignment: Alignment.bottomCenter,
                          child: Style.body(
                              MyLocalizations.of(
                                  context, "terms_and_conditions_txt"),
                              color: Style.greyColor,
                              textAlign: TextAlign.center)),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        StreamBuilder<bool>(
          stream: loadingStream.stream,
          initialData: false,
          builder: (BuildContext ctxt, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData == false || snapshot.data == false) {
              return Container();
            }
            return Utils.loading(
              snapshot.data,
            );
          },
        )
      ],
    );
  }

  _checkEmail() async {
    loadingStream.add(true);
    if (!Utils.mailRegExp.hasMatch(_emailController.text)) {
      Utils.showAlert(MyLocalizations.of(context, "app_name"),
          MyLocalizations.of(context, "invalid_mail_txt"), context);
      loadingStream.add(false);
    } else {
      ApiSingleton().checkEmail(_emailController.text).then((res) {
        loadingStream.add(false);
        if (res.length > 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LoginPassword(_emailController.text)),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SignupPage(_emailController.text)),
          );
        }
      }).catchError((e) {
        loadingStream.add(false);
        Utils.showAlert(MyLocalizations.of(context, "app_name"),
            MyLocalizations.of(context, "email_error_txt"), context);
        print(e);
      });
    }
  }
}
