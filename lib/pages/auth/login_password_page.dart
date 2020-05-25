import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/pages/auth/recover_password_page.dart';
import 'package:mosquito_alert_app/pages/main/main_vc.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class LoginPassword extends StatefulWidget {
  final String email;

  LoginPassword(this.email);
  @override
  _LoginPasswordState createState() => _LoginPasswordState();
}

class _LoginPasswordState extends State<LoginPassword> {
  TextEditingController _passwordController = TextEditingController();
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
                                context, "enter_password_title")),
                            SizedBox(
                              height: 20,
                            ),
                            Style.textField(
                                MyLocalizations.of(
                                    context, "user_password_txt"),
                                _passwordController,
                                context,
                                obscure: true),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                                width: double.infinity,
                                child: Style.button(
                                    MyLocalizations.of(context, "access_txt"),
                                    () {
                                  _login();
                                })),
                            SizedBox(
                              height: 20,
                            ),
                            Divider(),
                            Container(
                              width: double.infinity,
                              child: Style.noBgButton(
                                  MyLocalizations.of(
                                      context, "forgot_password_txt"), () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RecoverPassword()),
                                );
                              }, textColor: Colors.black),
                            )
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

  _login() async {
    loadingStream.add(true);
    ApiSingleton()
        .loginEmail(widget.email, _passwordController.text)
        .then((FirebaseUser user) {
      loadingStream.add(false);
      ApiSingleton().createProfile(user.uid);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainVC()),
      );
    }).catchError((e) {
      //Todo: show alert
      loadingStream.add(false);
      print(e);
    });
  }
}
