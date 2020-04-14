import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/models/session.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:random_string/random_string.dart';
import 'package:uuid/uuid.dart';

import 'MyLocalizations.dart';

class Utils {
  static List<CameraDescription> cameras;

  static String imagePath;

  static void saveImgPath(String path) {
    imagePath = path;
  }

  static String getImagePath() {
    return imagePath;
  }

  //REPORTS form
  static bool continueForm = false;

  static Report report;
  static Session session;
  static List<Report> reportsList;

  static createNewSession() async {
    session = new Session();
    reportsList = new List();
    //TODO: get last session id, create session, and save session id.
  }

  static createNewReport(String type) async {
    if (report != null) {
      reportsList.add(report);
    }
    //  createNewSession();
    var userUUID = await UserManager.getUUID();
    report = new Report(
      type: type,
      report_id: randomAlphaNumeric(4).toString(),
      version_number: 0,
      version_UUID: new Uuid().v4(),
      user: userUUID,
    );
    print(reportsList);
  }

  static setContinue() {
    continueForm = !continueForm;
  }

  static setCurrentLocation(double latitude, double longitude) {
    report.location_choice = 'current';
    report.current_location_lat = latitude;
    report.current_location_lon = longitude;
  }

  static setSelectedLocation(double lat, lon) {
    report.location_choice = "selected";
    report.selected_location_lat = lat;
    report.selected_location_lon = lon;
  }

  static void addResponse(questions) {
    // int currentIndex =
    //     responses.indexWhere((question) => responses.contains(question));
    // if (currentIndex != -1) {
    //   responses[currentIndex].answer = answer;
    // } else {
    //   setState(() {
    //     responses.add(new Questions(question: question, answer: answer));
    //   });
    // }
    report.responses = questions;
  }

  static Future<void> createReport() async {
    report.version_time = DateTime.now().toUtc().toString();
    report.creation_time = DateTime.now().toUtc().toString();
    report.phone_upload_time = DateTime.now().toUtc().toString();
    ApiSingleton().createReport(report);
  }

  //Alerts
  static Future showAlert(String title, String text, BuildContext context,
      {onPressed, barrierDismissible}) {
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        barrierDismissible: barrierDismissible != null
            ? barrierDismissible
            : true, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(text),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(MyLocalizations.of(context, 'ok')),
                onPressed: () {
                  if (onPressed != null) {
                    onPressed();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      );
    } else {
      return showDialog(
        context: context, //
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: new Text(
              title,
              style: TextStyle(letterSpacing: -0.3),
            ),
            content: Column(
              children: <Widget>[
                SizedBox(
                  height: 4,
                ),
                Text(
                  text,
                  style: TextStyle(height: 1.2),
                )
              ],
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(MyLocalizations.of(context, 'ok')),
                onPressed: () {
                  if (onPressed != null) {
                    onPressed();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }

  //Manage Data
  static String getLanguage() {
    return 'en';
  }
}
