import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mosquito_alert_app/pages/auth/login_password_page.dart';
import 'package:mosquito_alert_app/pages/auth/signup_page.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class LoginEmail extends StatefulWidget {
  @override
  _LoginEmailState createState() => _LoginEmailState();
}

class _LoginEmailState extends State<LoginEmail> {
  TextEditingController _emailController = TextEditingController();
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
            title: SvgPicture.asset('assets/img/logo_inverse.svg', width: 200),
          ),
          backgroundColor: Colors.transparent,
          // appBar: AppBar(
          //   backgroundColor: Colors.transparent,
          //   title: SvgPicture.asset('assets/img/logo_inverse.svg'),
          // ),
          body: SafeArea(
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
                        Style.titleMedium(
                            MyLocalizations.of(context, "enter_email_title")),
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
                                MyLocalizations.of(context, "access_txt"), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        LoginPassword(_emailController.text)),
                              );
                            })),
                        SizedBox(
                          height: 20,
                        ),
                        Divider(),
                        Container(
                          width: double.infinity,
                          child: Style.noBgButton(
                              MyLocalizations.of(
                                  context, "register_txt"), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignupPage()),
                            );
                          }, textColor: Colors.black),
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
      ],
    );
  }
}
