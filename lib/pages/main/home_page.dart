import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/pages/main/components/custom_card_widget.dart';
import 'package:mosquito_alert_app/pages/notification_pages/notifications_page.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamController<bool> loadingStream = StreamController<bool>.broadcast();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    loadingStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MyLocalizations.of(context, "app_name"),
                  style: TextStyle(
                    color: Color(0xFFEDB20C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()),
                );
              },
            )
          ],
          bottom: PreferredSize(
            child: Container(
              color: Colors.black,
              height: 0.25,
            ),
            preferredSize: Size.fromHeight(4.0)),
          ),
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Stack(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: 24,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Style.body(
                                              MyLocalizations.of(context, getRandomWhatToDoText()),
                                              fontSize: 16),
                                        ]),
                                    )                                      
                                  ]
                                ),
                                SizedBox(height: 30),
                                CustomCard(
                                  text: 'single_mosquito',
                                  image_path: 'assets/img/ic_mosquito_report.png',
                                  color: '40DFD458',
                                  reportFunction: _createAdultReport
                                ),
                                SizedBox(height: 10),
                                CustomCard(
                                  text: 'single_bite',
                                  image_path: 'assets/img/ic_bite_report.png',
                                  color: '40D28A73',
                                  reportFunction: _createBiteReport
                                ),
                                SizedBox(height: 10),
                                CustomCard(
                                  text: 'single_breeding_site',
                                  image_path: 'assets/img/ic_breeding_report.png',
                                  color: '407D9393',
                                  reportFunction: _createSiteReport
                                ),
                                SizedBox(height: 30),
                                Text(
                                  "Information pills (HC)",
                                  style: TextStyle(
                                    fontFamily: "Nunito",
                                    fontSize: 18.0, // TODO: Change to use TextTheme after the other PR is merged
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: List.generate(3, (index) {
                                      return Container(
                                        margin: EdgeInsets.all(20.0),
                                        width: 200.0,
                                        height: 150.0,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(16.0),
                                        ),
                                      );
                                    }),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
        ),

        // TODO: Can we remove the Positioned.fill?
        Positioned.fill(
          child: StreamBuilder<bool>(
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
          ),
        )
      ],
    );
  }

  String getRandomWhatToDoText() {
    var rnd = Random();
    var i = rnd.nextInt(5) + 1;
    return 'what_to_do_txt_$i';
  }

  Future<void> _createBiteReport() async {
    var createReport = await Utils.createNewReport('bite');
    loadingStream.add(false);
    if (createReport) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CircularProgressIndicator()),
      );
    } else {
      print('Bite report was not created');
      loadingStream.add(false);
    }
  }

  Future<void> _createAdultReport() async {
    var createReport = await Utils.createNewReport('adult');
    loadingStream.add(false);
    if (createReport) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CircularProgressIndicator()),
      );
    } else {
      print('Adult report was not created');
      loadingStream.add(false);
    }
  }

  Future<void> _createSiteReport() async {
    var createReport = await Utils.createNewReport('site');
    loadingStream.add(false);
    if (createReport) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CircularProgressIndicator()),
      );
    } else {
      print('Site report was not created');
      loadingStream.add(false);
    }
  }
}