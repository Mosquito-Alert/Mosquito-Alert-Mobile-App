import 'dart:io';

import 'package:camera/camera.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/models/question.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/models/session.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:package_info/package_info.dart';
import 'package:random_string/random_string.dart';
import 'package:uuid/uuid.dart';

import 'MyLocalizations.dart';

class Utils {
  static List<CameraDescription> cameras;

  //images
  static List<Map> imagePath;

  static void saveImgPath(File path) {
    if (imagePath == null) {
      imagePath = [];
    }
    imagePath.add({'image': path, 'id': report.version_UUID});
  }

  static void deleteImage(File image) {
    imagePath.removeWhere((element) => element['image'] == image);
    // print(imagePath);
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

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    report.package_name = packageInfo.packageName;
    report.package_version = 1; //TODO: fix this

    if (Platform.isAndroid) {
      var buildData = await DeviceInfoPlugin().androidInfo;
      report.device_manufacturer = buildData.manufacturer;
      report.device_model = buildData.model;
      report.os = 'Android';
      report.os_language = getLanguage();
      report.os_version = buildData.version.sdkInt.toString();
      report.app_language = getLanguage(); //TODO: fix get app language
    } else if (Platform.isIOS) {
      var buildData = await DeviceInfoPlugin().iosInfo;
      report.device_manufacturer = 'Apple';
      report.device_model = buildData.model;
      report.os = buildData.systemName;
      report.os_language = getLanguage();
      report.os_version = buildData.systemVersion;
      report.app_language = getLanguage();
    }
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
    report.version_time = DateTime.now().toIso8601String();
    report.creation_time = DateTime.now().toIso8601String();
    report.phone_upload_time = DateTime.now().toIso8601String();
    reportsList.add(report);
    report = null;
    createNewReport(type);
  }

  static deleteLastReport() {
    report = reportsList.last;
    reportsList.removeLast();
    print(reportsList);
  }

  static setCurrentLocation(double latitude, double longitude) {
    report.location_choice = 'current';
    // report.selected_location_lat = null;
    // report.selected_location_lon = null;
    report.current_location_lat = latitude;
    report.current_location_lon = longitude;
  }

  static setSelectedLocation(double lat, lon) {
    report.location_choice = "selected";
    // report.current_location_lat = null;
    // report.current_location_lon = null;
    report.selected_location_lat = lat;
    report.selected_location_lon = lon;
  }

  static void addLocationResponse(double lat, lon) {
    var newQuestion = new Question(
        question: "¿Donde estabas cuando te picaron?",
        answer: " ",
        question_id: 5,
        answer_id: 51,
        answer_value: "POINT( $lat, $lon)");

    report.responses.add(newQuestion);
  }

  static void addBiteResponse(String question, String answer,
      {question_id, answer_id}) {

    if (report == null) {
      return;
    }

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

  static Future<bool> saveReports() async {
    bool res;
    if (reportsList != null && reportsList.isNotEmpty) {
      for (int i = 0; i < reportsList.length; i++) {
        res = await ApiSingleton().createReport(reportsList[i]);
      }
    }
    return true;
    // return res;
  }

  static Future<bool> createReport() async {
    if (report.version_number > 0) {
      report.version_time = DateTime.now().toIso8601String();
      bool res = await ApiSingleton().createReport(report);
      return res;
    } else {
      report.version_time = DateTime.now().toIso8601String();
      report.creation_time = DateTime.now().toIso8601String();
      report.phone_upload_time = DateTime.now().toIso8601String();
      reportsList.add(report);
      bool isCreated;
      for (int i = 0; i < reportsList.length; i++) {
        isCreated = await ApiSingleton().createReport(reportsList[i]);
      }

      closeSession();
      resetReport();
      return isCreated;
    }
  }

  static Future<bool> deleteReport(r) async {
    Report deleteReport = r;
    deleteReport.version_time = DateTime.now().toIso8601String();
    deleteReport.version_number = -1;
    deleteReport.version_UUID = Uuid().v4();

    bool res = await ApiSingleton().createReport(deleteReport);
    return res;
  }

  static getLocation() async {
    location = await Geolocator().getLastKnownPosition();
  }

  static final RegExp mailRegExp = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

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

  static Future modalDetailTrackingforPlatform(List<Widget> list,
      TargetPlatform platform, BuildContext context, Function close,
      {title, cancelButton}) {
    if (platform == TargetPlatform.iOS) {
      return showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return CupertinoActionSheet(
                title: title != null ? Text(title) : null,
                cancelButton: cancelButton != null
                    ? cancelButton
                    : CupertinoActionSheetAction(
                        onPressed: close,
                        child: Text(
                          MyLocalizations.of(context, 'cancel'),
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                actions: list);
          });
    } else if (platform == TargetPlatform.android) {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return BottomSheet(
              builder: (BuildContext context) {
                return SafeArea(
                    child: Container(
                  child: Wrap(children: list),
                ));
              },
              onClosing: close,
            );
          });
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
  static Position location;
  static LatLng defaultLocation = LatLng(41.3874, 2.1688);

  static String getLanguage() {
    return 'es';
  }
}
