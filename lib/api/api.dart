import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/models/response.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';

class ApiSingleton {
  static String serverUrl = 'http://humboldt.ceab.csic.es/api';
  static String token = "D4w29W49rMKC7L6vYQ3ua3rd6fQ12YZ6n70P";

  //User
  static const users = '/users/';

  //Reports
  static const reports = '/reports/';

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

  Future<dynamic> createReport(Report report) async {
    try {
      var body = {};

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
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getMyReports() async {
    try {
      var userUUID = await UserManager.getUUID();
      final response = await http.get(
        '$serverUrl$reports?user=$userUUID',
        headers: headers,
      );

      print(response);

      if (response.statusCode != 200) {
        print(
            "Request: ${response.request.toString()} -> Response: ${response.body}");
        return Response.fromJson(json.decode(response.body));
      } else  {
        var list = json.decode(response.body) as List;
        List<Report> reportsList = list.map((i) => Report.fromJson(i)).toList();

        return reportsList;  //TODO: Fix
      }

      return false;
    } catch (e) {}
  }
}
