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

class GeneralPendingReportManager {
  static final GeneralPendingReportManager _singleton =
      GeneralPendingReportManager._internal();

  @protected
  static String saveKey = '';

  factory GeneralPendingReportManager() {
    return _singleton;
  }

  GeneralPendingReportManager._internal();

  static GeneralPendingReportManager getInstance(String targetSaveKey) {
    saveKey = targetSaveKey;
    return GeneralPendingReportManager();
  }

  Future<bool> saveData(Report safeReport, List<Map> photos, String type) async {
    try {
      removeSpecificData([safeReport.version_UUID], type);
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
      print(currentReports);
      currentReports.add(safeReport);

      print('$saveKey -> ${currentReports.length}');
      return prefs.setString(saveKey, jsonEncode(currentReports));
    } catch (e) {
      return false;
    }
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


  void removeSpecificData(List<String> reportUUID, String type) async {
    try {
      var prefs = await SharedPreferences.getInstance();
      var storedData = [];
      if (type == 'adult') {
        storedData =
            await GeneralPendingReportManager.getInstance(mosquitoReportSavekey)
                .loadData();
      }
      if (type == 'site') {
        storedData =
            await GeneralPendingReportManager.getInstance(breedingReportSaveKey)
                .loadData();
      }
      if (type == 'bite') {
        storedData =
            await GeneralPendingReportManager.getInstance(biteReportSaveKey)
                .loadData();
      }
      for (var repUUID in reportUUID) {
        storedData.removeWhere((report) => report.version_UUID == repUUID);
      }
      await prefs.setString(saveKey, jsonEncode(storedData));
    } catch (ex) {
      print(ex);
    }
  }
}
