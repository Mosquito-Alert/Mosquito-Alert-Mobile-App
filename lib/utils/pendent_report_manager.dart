import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:shared_preferences/shared_preferences.dart';

////////////////////////////////////////////////////////////////
///
///           PENDING GENERAL REPORT MANAGER
///
////////////////////////////////////////////////////////////////

String biteReportSaveKey = "bite_report_save_key";
String mosquitoReportSavekey = "mosquito_report_save_key";
String breedingReportSaveKey = "breeding_report_save_key";

class GeneralReportManager {
  static final GeneralReportManager _singleton =
      GeneralReportManager._internal();

  @protected
  static String saveKey = '';

  factory GeneralReportManager() {
    return _singleton;
  }

  GeneralReportManager._internal();

  static GeneralReportManager getInstance(String targetSaveKey) {
    saveKey = targetSaveKey;
    return GeneralReportManager();
  }

  Future<bool> saveData(
      Report safeReport, List<Map> photos, String type, bool isUploaded) async {
    try {
      //removeSpecificData([safeReport.version_UUID], type);
      var prefs = await SharedPreferences.getInstance();

      if (photos != null) {
        safeReport.photos = [];
        photos.forEach((element) {
          //element['imageFile']
          element['imageFile'] = null;
          safeReport.photos
              .add(Photo(id: element['id'], photo: element['image']));
        });
      }

      var currentReports = await loadData();
      if (currentReports
              .where((element) => element.isUploaded == true)
              .any((element) => element.report_id == safeReport.report_id) ||
          currentReports.any(
              (element) => element.version_UUID == safeReport.version_UUID)) {
        return true;
      } else if (currentReports
              .where((element) => element.isUploaded == false)
              .any((element) => element.report_id == safeReport.report_id) ||
          currentReports.any(
              (element) => element.version_UUID == safeReport.version_UUID)) {
        if (isUploaded) {
          currentReports
              .where((element) => (element.isUploaded == false &&
                  (element.report_id == safeReport.report_id ||
                      element.version_UUID == safeReport.version_UUID)))
              .first
              .isUploaded = true;
          return prefs.setString(saveKey, jsonEncode(currentReports));
        } else {
          return false;
        }
      }
      print(currentReports);
      safeReport.isUploaded = isUploaded;
      currentReports.add(safeReport);

      print('$saveKey -> ${currentReports.length}');
      return prefs.setString(saveKey, jsonEncode(currentReports));
    } catch (e) {
      return false;
    }
  }

  Future<bool> setReportToUploaded(String reportId) async {
    var prefs = await SharedPreferences.getInstance();
    var reports = await loadData();
    if (reports.any((element) => element.report_id == reportId)) {
      reports
          .firstWhere((element) => element.report_id == reportId)
          .isUploaded = true;
    }
    return prefs.setString(saveKey, jsonEncode(reports));
  }

  Future<List<Report>> loadData() async {
    try {
      var prefs = await SharedPreferences.getInstance();

      var reports = Report.decode(prefs.getString(saveKey) ?? '[]');

      for (Report rep in reports) {
        rep.version_number = 0;
        if (rep.note == 'null') {
          rep.note = '';
        }
        if (rep.phone_upload_time == null || rep.phone_upload_time == 'null') {
          rep.phone_upload_time = DateTime.now().toString();
        }
        if (rep.creation_time == null || rep.creation_time == 'null') {
          rep.creation_time = DateTime.now().toString();
        }
      }
      return reports;
    } catch (e) {
      return [];
    }
  }

  // void removeSpecificData(List<String> reportUUID, String type) async {
  //   try {
  //     var prefs = await SharedPreferences.getInstance();
  //     List<Report> storedData = [];
  //     if (type == 'adult') {
  //       storedData =
  //           await GeneralReportManager.getInstance(mosquitoReportSavekey)
  //               .loadData();
  //     }
  //     if (type == 'site') {
  //       storedData =
  //           await GeneralReportManager.getInstance(breedingReportSaveKey)
  //               .loadData();
  //     }
  //     if (type == 'bite') {
  //       storedData = await GeneralReportManager.getInstance(biteReportSaveKey)
  //           .loadData();
  //     }
  //     for (var repUUID in reportUUID) {
  //       if (storedData.any((element) =>
  //           element.version_UUID == repUUID && element.isUploaded == false)) {
  //         storedData.removeWhere((report) => report.version_UUID == repUUID);
  //       }
  //     }
  //     await prefs.setString(saveKey, jsonEncode(storedData));
  //   } catch (ex) {
  //     print(ex);
  //   }
  // }
}
