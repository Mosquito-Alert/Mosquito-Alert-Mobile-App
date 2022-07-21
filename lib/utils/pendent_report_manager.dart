import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:shared_preferences/shared_preferences.dart';

////////////////////////////////////////////////////////////////
///
///           PENDING GENERAL REPORT MANAGER
///
////////////////////////////////////////////////////////////////

class GeneralPendingReportManager {
  static final GeneralPendingReportManager _singleton =
      GeneralPendingReportManager._internal();

  @protected
  static final String biteReportKey = 'save_bite_repor_key';

  factory GeneralPendingReportManager() {
    return _singleton;
  }

  GeneralPendingReportManager._internal();

  static GeneralPendingReportManager getInstance() {
    return GeneralPendingReportManager();
  }

}

////////////////////////////////////////////////////////////////
///
///           PENDING ADULT REPORT MANAGER
///
////////////////////////////////////////////////////////////////
class PendingBiteReportManager {
  static final PendingBiteReportManager _singleton =
      PendingBiteReportManager._internal();

  @protected
  static final String biteReportKey = 'save_bite_repor_key';

  factory PendingBiteReportManager() {
    return _singleton;
  }

  PendingBiteReportManager._internal();

  static PendingBiteReportManager getInstance() {
    return PendingBiteReportManager();
  }

  static Future<bool> saveData(Report safeReport) async {
    try {
      removeStoredData();
      var prefs = await SharedPreferences.getInstance();

      return await prefs.setString(biteReportKey, jsonEncode(safeReport));
    } catch (ex) {
      print(ex);
      return false;
    }
  }

  static void removeStoredData() async {
    try {
      var prefs = await SharedPreferences.getInstance();

      await prefs.remove(biteReportKey);
    } catch (ex) {
      print(ex);
    }
  }

  static Future<Report> loadData() async {
    var prefs = await SharedPreferences.getInstance();
    Report reportSaved;
    try {
      final reportEncoded = prefs.getString(biteReportKey);

      dynamic x = jsonDecode(reportEncoded);

      reportSaved = Report.fromJson(x);

      if (reportSaved.note == 'null') {
        reportSaved.note = '';
      }
      if (reportSaved.phone_upload_time == null ||
          reportSaved.phone_upload_time == 'null') {
        reportSaved.phone_upload_time = DateTime.now().toString();
      }
      if (reportSaved.creation_time == null ||
          reportSaved.creation_time == 'null') {
        reportSaved.creation_time = DateTime.now().toString();
      }
    } catch (ex) {
      print(ex);
      removeStoredData();
    } finally {
      return reportSaved;
    }
  }
}

////////////////////////////////////////////////////////////////
///
///           PENDING ADULT REPORT MANAGER
///
////////////////////////////////////////////////////////////////

class PendingAdultReportManager {
  static final PendingAdultReportManager _singleton =
      PendingAdultReportManager._internal();

  @protected
  static final String adultReportKey = 'save_pending_adult_report_key';

  factory PendingAdultReportManager() {
    return _singleton;
  }

  PendingAdultReportManager._internal();

  static PendingAdultReportManager getInstance() {
    return PendingAdultReportManager();
  }

  static Future<bool> saveData(Report safeReport) async {
    try {
      removeStoredData();
      var prefs = await SharedPreferences.getInstance();

      return await prefs.setString(adultReportKey, jsonEncode(safeReport));
    } catch (ex) {
      print(ex);
      return false;
    }
  }

  static void removeStoredData() async {
    try {
      var prefs = await SharedPreferences.getInstance();

      await prefs.remove(adultReportKey);
    } catch (ex) {
      print(ex);
    }
  }

  static Future<Report> loadData() async {
    var prefs = await SharedPreferences.getInstance();
    Report reportSaved;
    try {
      final reportEncoded = prefs.getString(adultReportKey);

      dynamic x = jsonDecode(reportEncoded);

      reportSaved = Report.fromJson(x);

      if (reportSaved.note == 'null') {
        reportSaved.note = '';
      }
      if (reportSaved.phone_upload_time == null ||
          reportSaved.phone_upload_time == 'null') {
        reportSaved.phone_upload_time = DateTime.now().toString();
      }
      if (reportSaved.creation_time == null ||
          reportSaved.creation_time == 'null') {
        reportSaved.creation_time = DateTime.now().toString();
      }
    } catch (ex) {
      print(ex);
      removeStoredData();
    } finally {
      return reportSaved;
    }
  }
}

////////////////////////////////////////////////////////////////
///
///           PENDING BREEDING REPORT MANAGER
///
////////////////////////////////////////////////////////////////

class PendentBreedingReportManager {
  static final PendentBreedingReportManager _singleton =
      PendentBreedingReportManager._internal();

  @protected
  static final String breadingReportKey = 'save_breading_adult_report_key';

  factory PendentBreedingReportManager() {
    return _singleton;
  }

  PendentBreedingReportManager._internal();

  static PendentBreedingReportManager getInstance() {
    return PendentBreedingReportManager();
  }

  static Future<bool> saveData(Report safeReport) async {
    try {
      removeStoredData();
      var prefs = await SharedPreferences.getInstance();

      return await prefs.setString(breadingReportKey, jsonEncode(safeReport));
    } catch (ex) {
      print(ex);
      return false;
    }
  }

  static void removeStoredData() async {
    try {
      var prefs = await SharedPreferences.getInstance();

      await prefs.remove(breadingReportKey);
    } catch (ex) {
      print(ex);
    }
  }

  static Future<Report> loadData() async {
    var prefs = await SharedPreferences.getInstance();
    Report reportSaved;
    try {
      final reportEncoded = prefs.getString(breadingReportKey);

      dynamic x = jsonDecode(reportEncoded);

      reportSaved = Report.fromJson(x);

      if (reportSaved.note == 'null') {
        reportSaved.note = '';
      }
      if (reportSaved.phone_upload_time == null ||
          reportSaved.phone_upload_time == 'null') {
        reportSaved.phone_upload_time = DateTime.now().toString();
      }
      if (reportSaved.creation_time == null ||
          reportSaved.creation_time == 'null') {
        reportSaved.creation_time = DateTime.now().toString();
      }
    } catch (ex) {
      print(ex);
      removeStoredData();
    } finally {
      return reportSaved;
    }
  }
}
