import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/models/question.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/models/session.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:random_string/random_string.dart';
import 'package:uuid/uuid.dart';

import 'MyLocalizations.dart';

class Utils {
  static List<CameraDescription> cameras;

  //images
  static String imagePath;

  static void saveImgPath(String path) {
    imagePath = path;
  }

  static String getImagePath() {
    return imagePath;
  }

  //REPORTS form
  static Report report;
  static Session session;
  static List<Report> reportsList;

  static closeSession() {
    session.session_end_time = DateTime.now().toIso8601String();
    ApiSingleton().closeSession(session);
  }

  static createNewReport(String type) async {
    if (session == null) {
      reportsList = new List();

      String userUUID = await UserManager.getUUID();

      int sessionId = await ApiSingleton().getLastSession(userUUID);
      sessionId = sessionId + 1;

      session = new Session(
          session_ID: sessionId,
          user: userUUID,
          session_start_time: DateTime.now().toIso8601String());

      session.id = await ApiSingleton().createSession(session);
    }

    var userUUID = await UserManager.getUUID();
    report = new Report(
        type: type,
        report_id: randomAlphaNumeric(4).toString(),
        version_number: 0,
        version_UUID: new Uuid().v4(),
        user: userUUID,
        session: session.id,
        responses: new List());
  }

  static setEditReport(Report editReport) {
    report = editReport;
    report.version_number = report.version_number + 1;
  }

  static addOtherReport(String type) {
    report.version_time = DateTime.now().toUtc().toString();
    report.creation_time = DateTime.now().toUtc().toString();
    report.phone_upload_time = DateTime.now().toUtc().toString();
    reportsList.add(report);
    createNewReport(type);
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

  static void addResponses(questions) {
    report.responses = questions;
    // //TODO: adapt functions and fix double questions
    // var _responses = report.responses;
    // if (_responses == null) {
    //   _responses = new List();
    // }
    // for (Question question in questions) {
    //   _responses.add(question);
    // }
    // report.responses = _responses;
    // print(report.responses);
  }

  static void addBiteResponse(String question, String answer,
      {question_id, answer_id}) {
    List<Question> _questions = report.responses;

    // TODO: fix question_id!
    //increase answer_value question 2
    if (question_id == 2) {
      int currentIndex = _questions.indexWhere((question) =>
          // question.question_id == question_id &&
          question.answer_id == answer_id.toString());
      if (currentIndex == -1) {
        _questions.add(Question(
          question: question.toString(),
          answer: answer.toString(),
          answer_id: answer_id,
          question_id: question_id,
          answer_value: '1',
        ));
      } else {
        int value = int.parse(_questions[currentIndex].answer_value);
        value = value + 1;
        _questions[currentIndex].answer_value = value.toString();
      }

      //increase total bites answer_value
      int bitesIndex =
          _questions.indexWhere((question) => question.question_id == '1');

      if (bitesIndex == -1) {
        _questions.add(Question(
            question: 'Cuantas picads',
            answer: ' ',
            question_id: 1,
            answer_value: '1'));
      } else {
        int value = int.parse(_questions[bitesIndex].answer_value);
        value = value + 1;
        _questions[bitesIndex].answer_value = value.toString();
      }
    }
    //add other questions without answer_value
    if (question_id != 2 && question_id != 1) {
      _questions.add(Question(
        question: question.toString(),
        answer: answer.toString(),
        answer_id: answer_id,
        question_id: question_id,
      ));
    }
  }

  static void addResponse(question) {
    var _responses = report.responses;
    if (_responses == null) {
      _responses = new List();
    }
    _responses.add(question);
    report.responses = _responses;
    // print(report);
  }

  static Future<void> createReport() async {
    if (report.version_number > 0) {
      report.version_time = DateTime.now().toIso8601String();
      report.version_UUID = Uuid().v4();
    } else {
      report.version_time = DateTime.now().toIso8601String();
      report.creation_time = DateTime.now().toIso8601String();
      report.phone_upload_time = DateTime.now().toIso8601String();
    }
    reportsList.add(report);
    for (Report r in reportsList) {
      ApiSingleton().createReport(r);
    }
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
