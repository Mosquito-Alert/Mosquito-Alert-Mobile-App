import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'dart:math';

class MainVC extends StatefulWidget {
  @override
  _MainVCState createState() => _MainVCState();
}

class _MainVCState extends State<MainVC> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {},
        ),
        title: SvgPicture.asset('assets/img/logo_mosquito_alert.svg'),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications),
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Style.title(
                              " ${MyLocalizations.of(context, "welcome_text")} Alex."),
                          Style.body(
                              MyLocalizations.of(context, "what_to_do_txt"),
                              fontSize: 20),
                          Style.body("ñdsajfnñsldgjnañsdlg",
                              color: Color(0XFFC96F00))
                        ]),
                  ),
                  SizedBox(width:10,),
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/img/points_box.png"),
                      ),
                    ),
                    child: Center(
                        child: Style.title('2',
                            color: Color(0xFF4B3D04), fontSize: 30)),
                  ),
                ])
          ],
        ),
      ),
    );
  }
}
