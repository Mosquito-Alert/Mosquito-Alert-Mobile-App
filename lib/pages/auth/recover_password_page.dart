import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class RecoverPassword extends StatefulWidget {
  @override
  _RecoverPasswordState createState() => _RecoverPasswordState();
}

class _RecoverPasswordState extends State<RecoverPassword> {
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
                                context, "recover_password_title")),
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
                                    MyLocalizations.of(
                                        context, "recover_password_btn"), () {
                                  _recoverPassword();
                                })),
                            SizedBox(
                              height: 20,
                            ),
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

  _recoverPassword() {
    loadingStream.add(true);
    ApiSingleton().recoverPassword(_emailController.text).then((value) {
      loadingStream.add(false);
    }).catchError((e) {
      loadingStream.add(false);
    });
  }
}
