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
  static const reports = '/report/';

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
      final response = await http.post(
        '$serverUrl$reports',
        headers: headers,
        body: json.encode(report),
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
}
