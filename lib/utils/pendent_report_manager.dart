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

  Future<bool> saveData(Report safeReport) async {
    try {
      var prefs = await SharedPreferences.getInstance();
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
      removeStoredData();
      return [];
    }
  }

  void removeStoredData() async {
    // try {
    //   var prefs = await SharedPreferences.getInstance();
    //   await prefs.remove(saveKey);
    // } catch (ex) {
    //   print(ex);
    // }
  }

  void removeSpecificData(List<String> reportUUID) async {
    try {
      var prefs = await SharedPreferences.getInstance();
      var storedData = await loadData();
      for (var repUUID in reportUUID) {
        storedData.removeWhere((report) => report.version_UUID == repUUID);
      }
      await prefs.setString(saveKey, jsonEncode(storedData));
    } catch (ex) {
      print(ex);
    }
  }
}

////////////////////////////////////////////////////////////////
///
///           PENDING ADULT REPORT MANAGER
///
////////////////////////////////////////////////////////////////

class PendingPhotosManager {
  static final PendingPhotosManager _singleton =
      PendingPhotosManager._internal();

  @protected
  static final String saveKey = 'save_pending_photos_key';

  factory PendingPhotosManager() {
    return _singleton;
  }

  PendingPhotosManager._internal();

  static PendingPhotosManager getInstance() {
    return PendingPhotosManager();
  }

  static Future<bool> saveData(List<Map> photos) async {
    try {
      removeStoredData();
      var prefs = await SharedPreferences.getInstance();

      photos.forEach((element) {
        //element['imageFile']
        element['imageFile'] = null;
      });

      return await prefs.setString(saveKey, jsonEncode(photos));
    } catch (ex) {
      print(ex);
      return false;
    }
  }

  static void removeStoredData() async {
    try {
      var prefs = await SharedPreferences.getInstance();

      await prefs.remove(saveKey);
    } catch (ex) {
      print(ex);
    }
  }

  static Future<List<Map>> loadData() async {
    var prefs = await SharedPreferences.getInstance();
    List<Map> mapPhotos = [];
    var photos;

    try {
      final reportEncoded = prefs.getString(saveKey);

      photos = jsonDecode(reportEncoded);

      for (var photo in photos) {
        mapPhotos.add({
          'image': photo['image'],
          'id': photo['id'],
          'imageFile': File(photo['image'])
        });
      }

      print(photos);
    } catch (ex) {
      print(ex);
      //removeStoredData();
    } finally {
      return mapPhotos ?? [];
    }
  }
}
