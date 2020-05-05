import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/models/question.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/models/session.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:random_string/random_string.dart';
import 'package:uuid/uuid.dart';

import 'MyLocalizations.dart';

class Utils {
  static List<CameraDescription> cameras;

  static Position location;

  //images
  static List<Map> imagePath;

  static void saveImgPath(File path) {
    if (imagePath == null) {
      imagePath = [];
    }
    imagePath.add({'image': path, 'id': report.version_UUID});
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
      reportsList = [];

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
        responses: []);
  }

  static resetReport() {
    report = null;
    session = null;
    reportsList = null;
  }

  static setEditReport(Report editReport) {
    report = editReport;
    report.version_number = report.version_number + 1;
    report.version_UUID = new Uuid().v4();
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
    report.selected_location_lat = null;
    report.selected_location_lon = null;
    report.current_location_lat = latitude;
    report.current_location_lon = longitude;
  }

  static setSelectedLocation(double lat, lon) {
    report.location_choice = "selected";
    report.current_location_lat = null;
    report.current_location_lon = null;
    report.selected_location_lat = lat;
    report.selected_location_lon = lon;
  }

  static void addLocationResponse(double lat, lon) {
    var newQuestion = new Question(
        question: "¿DOnde estabas cuando te picaron?",
        answer: " ",
        question_id: 5,
        answer_id: 51,
        answer_value: "POINT( $lat, $lon)");

    report.responses.add(newQuestion);
  }

  static void addBiteResponse(String question, String answer,
      {question_id, answer_id}) {
    List<Question> _questions = report.responses;

    //increase answer_value question 2
    if (question_id == 2) {
      int currentIndex = _questions.indexWhere((question) =>
          // question.question_id == question_id &&
          question.answer_id == answer_id);
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
          _questions.indexWhere((question) => question.question_id == 1);

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

  static void addAdultPartsResponse(answer, answerId, i) {
    var _questions = report.responses;
    int index =
        _questions.indexWhere((q) => q.answer_id > i && q.answer_id < i + 10);
    if (index != -1) {
      _questions[index].answer_id = answerId;
      _questions[index].answer = answer;
    } else {
      Question newQuestion = new Question(
        question: '¿Como era el mosquito?',
        answer: answer,
        question_id: 7,
        answer_id: answerId,
      );
      _questions.add(newQuestion);
    }
    report.responses = _questions;
  }

  static void addResponse(Question question) {
    int index = report.responses
        .indexWhere((q) => q.question_id == question.question_id);
    var _responses = report.responses;
    if (_responses == null) {
      _responses = [];
    }
    if (index != -1) {
      _responses[index] = question;
    } else {
      _responses.add(question);
      report.responses = _responses;
    }
  }

  static Future<void> createReport() async {
    List<Map> reportImages = [];
    if (report.version_number > 0) {
      report.version_time = DateTime.now().toIso8601String();
      ApiSingleton().createReport(report);
    } else {
      report.version_time = DateTime.now().toIso8601String();
      report.creation_time = DateTime.now().toIso8601String();
      report.phone_upload_time = DateTime.now().toIso8601String();
      reportsList.add(report);
      print(reportsList);

      reportsList.forEach((r) {
        ApiSingleton().createReport(r);
      });
      closeSession();
      resetReport();
      imagePath = [];
    }
  }

  static Future<void> deleteReport(r) async {
    Report deleteReport = r;
    deleteReport.version_time = DateTime.now().toIso8601String();
    deleteReport.version_number = -1;
    deleteReport.version_UUID = Uuid().v4();

    ApiSingleton().createReport(deleteReport);
  }

  static getLocation() async {
    location = await Geolocator().getLastKnownPosition();
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

  static Future showAlertYesNo(
    String title,
    String text,
    onYesPressed,
    BuildContext context,
  ) {
    if (Platform.isAndroid) {
      return showDialog(
        context: context, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Style.title(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Style.body(text),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Style.body(MyLocalizations.of(context, 'ok'),
                    color: Style.colorPrimary),
                onPressed: () {
                  Navigator.of(context).pop();
                  onYesPressed();
                },
              ),
              FlatButton(
                child: Style.body(MyLocalizations.of(context, 'cancel')),
                onPressed: () {
                  Navigator.of(context).pop();
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
            title: Style.title(title),
            content: Style.body(text),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Style.body(MyLocalizations.of(context, 'ok')),
                onPressed: () {
                  Navigator.of(context).pop();
                  onYesPressed();
                },
              ),
              CupertinoDialogAction(
                child: Style.body(MyLocalizations.of(context, 'cancel')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  static Widget loading(_isLoading, [Color indicatorColor]) {
    return _isLoading == true
        ? new Container(
            color: Colors.transparent,
            child: Center(
              child: new CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                    indicatorColor == null
                        ? Style.colorPrimary
                        : indicatorColor),
              ),
            ),
          )
        : new Container();
  }

  //Manage Data
  static String getLanguage() {
    return 'en';
  }
}
