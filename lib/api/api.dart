import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/models/response.dart';
import 'package:mosquito_alert_app/models/session.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:uuid/uuid.dart';

class ApiSingleton {
  static String serverUrl = 'http://humboldt.ceab.csic.es/api';
  static String token = "D4w29W49rMKC7L6vYQ3ua3rd6fQ12YZ6n70P";

  //User
  static const users = '/users/';

  //Reports
  static const reports = '/reports/';
  static const nearbyReports = '/nearby_reports_nod/';

  //Session
  static const session = '/sessions/';

  //Images
  static const images = '/photos/';

  //Headders
  var headers = {
    "Content-Type": " application/json",
    "Authorization": "Token " + token
  };

  static final ApiSingleton _singleton = new ApiSingleton._internal();

  factory ApiSingleton() {
    return _singleton;
  }

  ApiSingleton._internal();

  static ApiSingleton getInstance() {
    return new ApiSingleton();
  }

  Future<dynamic> createUser(String uuid) async {
    try {
      final response = await http.post('$serverUrl$users',
          headers: headers,
          body: json.encode({
            'user_UUID': uuid,
          }));

      if (response.statusCode != 200) {
        print(
            "Request: ${response.request.toString()} -> Response: ${response.body}");
        return Response.fromJson(json.decode(response.body));
      }
      return true;
    } catch (c) {
      return null;
    }
  }

  // Future<dynamic> createSession() async {
  //   try {
  //     var userUUID = await UserManager.getUUID();
  //     // var session_ID = int.parse(await UserManager.getSessionId());

  //     var session_ID = 4;

  //     final response = await http.post('$serverUrl$session',
  //         headers: headers,
  //         body: json.encode({
  //           'user': userUUID,
  //           'session_ID': session_ID,
  //           'session_start_time': DateTime.now().toUtc().toString(),
  //         }));

  //     if (response.statusCode != 200) {
  //       print(
  //           "Request: ${response.request.toString()} -> Response: ${response.body}");
  //       return Response.fromJson(json.decode(response.body));
  //     }

  //     await UserManager.setSessionId(session_ID.toString());
  //     print(response);
  //     return response;
  //   } catch (e) {
  //     print(e);
  //     return null;
  //   }
  // }

  // Future<dynamic> updateSession(String sessionId) async {
  //   try {
  //     final response = await http.post('$serverUrl$session$sessionId',
  //         headers: headers,
  //         body: json.encode({
  //           'session_end_time': DateTime.now().toUtc().toString(),
  //         }));

  //     if (response.statusCode != 200) {
  //       print(
  //           "Request: ${response.request.toString()} -> Response: ${response.body}");
  //       return Response.fromJson(json.decode(response.body));
  //     }

  //     // await UserManager.setSessionId(session_ID.toString());
  //     print(response);
  //   } catch (e) {}
  // }

  Future<dynamic> createReport(Report report) async {
    try {
      var body = {};
      String image = Utils.getImagePath();

      //TODO: fix this!
      if (report.version_UUID != null && report.version_UUID.isNotEmpty) {
        body.addAll({'version_UUID': report.version_UUID});
      }
      if (report.version_number != null) {
        body.addAll({'version_number': report.version_number});
      }
      if (report.user != null && report.user.isNotEmpty) {
        body.addAll({'user': report.user});
      }
      if (report.report_id != null && report.report_id.isNotEmpty) {
        body.addAll({'report_id': report.report_id});
      }
      if (report.phone_upload_time != null &&
          report.phone_upload_time.isNotEmpty) {
        body.addAll({'phone_upload_time': report.phone_upload_time});
      }
      if (report.creation_time != null && report.creation_time.isNotEmpty) {
        body.addAll({'creation_time': report.creation_time});
      }
      if (report.version_time != null && report.version_time.isNotEmpty) {
        body.addAll({'version_time': report.version_time});
      }
      if (report.type != null && report.type.isNotEmpty) {
        body.addAll({'type': report.type});
      }
      if (report.location_choice != null && report.location_choice.isNotEmpty) {
        body.addAll({'location_choice': report.location_choice});
      }
      if (report.current_location_lat != null) {
        body.addAll({'current_location_lat': report.current_location_lat});
      }
      if (report.current_location_lon != null) {
        body.addAll({'current_location_lon': report.current_location_lon});
      }
      if (report.selected_location_lat != null) {
        body.addAll({'selected_location_lat': report.selected_location_lat});
      }
      if (report.selected_location_lon != null) {
        body.addAll({'selected_location_lon': report.selected_location_lon});
      }
      if (report.package_name != null) {
        body.addAll({'package_name': report.package_name});
      }
      if (report.package_version != null) {
        body.addAll({'package_version': report.package_version});
      }
      if (report.responses != null && report.responses.isNotEmpty) {
        body.addAll(
            {'responses': report.responses.map((r) => r.toJson()).toList()});
      }

      final response = await http.post(
        '$serverUrl$reports',
        headers: headers,
        body: json.encode(body),
      );

      print(response);
      if (response.statusCode != 200) {
        print(
            "Request: ${response.request.toString()} -> Response: ${response.body}");
        return Response.fromJson(json.decode(response.body));
      }

      if (image != null) {
        print(image);
        saveImage(image, report.report_id);
      }
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> deleteReport(Report report) async {
    try {
      var body = {};

      body.addAll({'version_UUID': Uuid().v4()});
      body.addAll({'version_number': -1});
      body.addAll({'version_time': DateTime.now().toIso8601String()});

      //Todo: fix this! 
      if (report.user != null && report.user.isNotEmpty) {
        body.addAll({'user': report.user});
      }
      if (report.report_id != null && report.report_id.isNotEmpty) {
        body.addAll({'report_id': report.report_id});
      }
      if (report.phone_upload_time != null &&
          report.phone_upload_time.isNotEmpty) {
        body.addAll({'phone_upload_time': report.phone_upload_time});
      }
      if (report.creation_time != null && report.creation_time.isNotEmpty) {
        body.addAll({'creation_time': report.creation_time});
      }

      if (report.type != null && report.type.isNotEmpty) {
        body.addAll({'type': report.type});
      }
      if (report.location_choice != null && report.location_choice.isNotEmpty) {
        body.addAll({'location_choice': report.location_choice});
      }
      if (report.current_location_lat != null) {
        body.addAll({'current_location_lat': report.current_location_lat});
      }
      if (report.current_location_lon != null) {
        body.addAll({'current_location_lon': report.current_location_lon});
      }
      if (report.selected_location_lat != null) {
        body.addAll({'selected_location_lat': report.selected_location_lat});
      }
      if (report.selected_location_lon != null) {
        body.addAll({'selected_location_lon': report.selected_location_lon});
      }
      if (report.package_name != null) {
        body.addAll({'package_name': report.package_name});
      }
      if (report.package_version != null) {
        body.addAll({'package_version': report.package_version});
      }
      if (report.responses != null && report.responses.isNotEmpty) {
        body.addAll(
            {'responses': report.responses.map((r) => r.toJson()).toList()});
      } else {
        body.addAll({'responses': {}});
      }
      final response = await http.post('$serverUrl$reports',
          headers: headers, body: json.encode(body));

      print(response);

      if (response.statusCode != 200) {
        print(
            "Request: ${response.request.toString()} -> Response: ${response.body}");
        return Response.fromJson(json.decode(response.body));
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<dynamic> getMyReports() async {
    try {
      var userUUID = await UserManager.getUUID();
      final response = await http.get(
        '$serverUrl$reports?user=$userUUID',
        headers: headers,
      );
      if (response.statusCode != 200) {
        print(
            "Request: ${response.request.toString()} -> Response: ${response.body}");
        return Response.fromJson(json.decode(response.body));
      } else {
        var list = json.decode(response.body) as List;
        List<Report> reportsList = list.map((i) => Report.fromJson(i)).toList();

        return reportsList;
      }
      return false;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getReportsList(lat, lon,
      {page, List<Report> allReports}) async {
    try {
      var userUUID = await UserManager.getUUID();

      final response = await http.get(
        '$serverUrl/nearby_reports_nod/?lat=$lat&lon=$lon&radius=8000&user=$userUUID',
        headers: headers,
      );
      if (response.statusCode != 200) {
        print(
            "Request: ${response.request.toString()} -> Response: ${response.body}");
        return Response.fromJson(json.decode(response.body));
      } else {
        Map<String, dynamic> jsonAnswer = json.decode(response.body);
        // print(body['results']);
        // var list = json.decode(response.body) as List;
        // List<Report> reportsList = list.map((i) => Report.fromJson(i)).toList();

        if (allReports == null) {
          allReports = List();
        }
        for (var item in jsonAnswer['results']) {
          allReports.add(Report.fromJson(item));
        }

        return allReports;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> saveImage(String path, String reportId) async {
    try {
      final response = await http.post(
        '$serverUrl$images',
        headers: headers,
        body: jsonEncode({'photo': path, 'report': reportId}),
      );

      if (response.statusCode != 200) {
        print(
            "Request: ${response.request.toString()} -> Response: ${response.body}");
        return Response.fromJson(json.decode(response.body));
      }
    } catch (e) {}
  }
}
