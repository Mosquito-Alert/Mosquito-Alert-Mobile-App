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
  static final String saveKey = 'save_bite_repor_key';

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

      var allPendingReports = await loadData();
      allPendingReports.add(safeReport);
      final encodedData = Report.encode(allPendingReports);

      return await prefs.setString(saveKey, encodedData);
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

  static Future<List<Report>> loadData() async {
    var prefs = await SharedPreferences.getInstance();
    try {
      final reportsSaved = await prefs.getString(saveKey);

      final reports = Report.decode(reportsSaved);

      for (Report rep in reports) {
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
    } catch (ex) {
      print(ex);
      removeStoredData();
    } finally {
      return [];
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
  static final String saveKey = 'save_pending_adult_report_key';

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

      var allPendingReports = await loadData();
      allPendingReports.add(safeReport);
      final encodedData = Report.encode(allPendingReports);

      return await prefs.setString(saveKey, encodedData);
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

  static Future<List<Report>> loadData() async {
    var prefs = await SharedPreferences.getInstance();
    try {
      final reportsSaved = await prefs.getString(saveKey);

      final reports = Report.decode(reportsSaved);

      for (Report rep in reports) {
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
    } catch (ex) {
      print(ex);
      removeStoredData();
    } finally {
      return [];
    }
  }
}

////////////////////////////////////////////////////////////////
///
///           PENDING BREEDING REPORT MANAGER
///
////////////////////////////////////////////////////////////////

class PendingBreedingReportManager {
  static final PendingBreedingReportManager _singleton =
      PendingBreedingReportManager._internal();

  @protected
  static final String saveKey = 'save_breading_adult_report_key';

  factory PendingBreedingReportManager() {
    return _singleton;
  }

  PendingBreedingReportManager._internal();

  static PendingBreedingReportManager getInstance() {
    return PendingBreedingReportManager();
  }

  static Future<bool> saveData(Report safeReport) async {
    try {
      removeStoredData();
      var prefs = await SharedPreferences.getInstance();

      var allPendingReports = await loadData();
      allPendingReports.add(safeReport);
      final encodedData = Report.encode(allPendingReports);

      return await prefs.setString(saveKey, encodedData);
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

  static Future<List<Report>> loadData() async {
    var prefs = await SharedPreferences.getInstance();
    try {
      final reportsSaved = await prefs.getString(saveKey);

      final reports = Report.decode(reportsSaved);

      for (Report rep in reports) {
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
    } catch (ex) {
      print(ex);
      removeStoredData();
    } finally {
      return [];
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

  static Future<bool> saveData(Report safeReport) async {
    try {
      removeStoredData();
      var prefs = await SharedPreferences.getInstance();

      var allPendingReports = await loadData();
      allPendingReports.add(safeReport);
      final encodedData = Report.encode(allPendingReports);

      return await prefs.setString(saveKey, encodedData);
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

  static Future<List<Report>> loadData() async {
    var prefs = await SharedPreferences.getInstance();
    try {
      final reportsSaved = await prefs.getString(saveKey);

      final reports = Report.decode(reportsSaved);

      for (Report rep in reports) {
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
    } catch (ex) {
      print(ex);
      removeStoredData();
    } finally {
      return [];
    }
  }
}
