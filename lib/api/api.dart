import 'dart:convert';
import 'dart:io';

import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/models/response.dart';
import 'package:mosquito_alert_app/models/session.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';

class ApiSingleton {
  static String serverUrl = 'http://humboldt.ceab.csic.es/api';
  static String token = "D4w29W49rMKC7L6vYQ3ua3rd6fQ12YZ6n70P";

  //User
  static const users = '/users/';
  static const profile = '/profile/';
  static const newProfile = '/profile/new/';
  static const userScore = '/user_score/';

  //Reports
  static const reports = '/reports/';
  static const nearbyReports = '/nearby_reports_nod/';

  //Session
  static const sessions = '/sessions';
  static const sessionUpdate = '/session_update/';

  //Images
  static const photos = '/photos/';

  //Headders
  var headers = {
    "Content-Type": " application/json",
    "Authorization": "Token " + token
  };

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final facebookLogin = FacebookLogin();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final ApiSingleton _singleton = new ApiSingleton._internal();

  factory ApiSingleton() {
    return _singleton;
  }

  ApiSingleton._internal();

  static ApiSingleton getInstance() {
    return new ApiSingleton();
  }

  //User
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
        return ApiResponse.fromJson(json.decode(response.body));
      }
      return true;
    } catch (c) {
      return null;
    }
  }

  Future<dynamic> checkEmail(String email) async {
    var response = (await _auth.fetchSignInMethodsForEmail(email: email));
    return response;
  }

  Future<dynamic> singUp(
      String email, String password, String firstName, String lastName) async {
    final FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ))
        .user;
    if (user != null) {
      UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
      userUpdateInfo.displayName = '$firstName $lastName';
      user.updateProfile(userUpdateInfo);

      print(user);
      return user;
    } else {
      return false;
    }
  }

  Future<FirebaseUser> loginEmail(String email, String password) async {
    final FirebaseUser user = (await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    ))
        .user;
    if (user != null) {
      return user;
    } else {
      return user;
    }
  }

  Future<FirebaseUser> sigInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;

    _googleSignIn.signOut();
    return user;
  }

  Future<FirebaseUser> singInWithFacebook() async {
    AuthCredential credential;

    final FacebookLoginResult result = await facebookLogin.logIn(['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        credential = FacebookAuthProvider.getCredential(
          accessToken: result.accessToken.token,
        );

        final FirebaseUser user =
            (await _auth.signInWithCredential(credential)).user;
        assert(user.email != null);
        assert(user.displayName != null);
        assert(!user.isAnonymous);
        assert(await user.getIdToken() != null);
        final FirebaseUser currentUser = await _auth.currentUser();
        assert(user.uid == currentUser.uid);
        return currentUser;
        break;
      case FacebookLoginStatus.cancelledByUser:
        // Todo: Show alert
        break;
      case FacebookLoginStatus.error:
        print(result.errorMessage);
        break;
    }
  }

  Future<bool> logout() async {
    _auth.signOut().then((res) {
      return true;
    }).catchError((e) {
      print(e);
      return false;
    });
  }

  Future<dynamic> recoverPassword(String email){
    _auth.sendPasswordResetEmail(email: email);
  }

  Future<dynamic> createProfile(String firebaseId) async {
    String userUUID = await UserManager.getUUID();

    try {
      final response = await http.post(
          '$serverUrl$newProfile?fbt=$firebaseId&usr=$userUUID',
          headers: headers);

      // print(response);

      if (response.statusCode != 200) {
        print(
            "Request: ${response.request.toString()} -> Response: ${response.body}");
        return ApiResponse.fromJson(json.decode(response.body));
      }
      return true;
    } catch (e) {
      print(e.errorMessage);
    }
  }

  Future<dynamic> getUserScores() async {
    try {
      String userUUID = await UserManager.getUUID();

      final response = await http.get(
        '$serverUrl$userScore?user_id=$userUUID',
        headers: headers,
      );

      // print(response);
      if (response.statusCode != 200) {
        print(
            "Request: ${response.request.toString()} -> Response: ${response.body}");
        return ApiResponse.fromJson(json.decode(response.body));
      }
      Map<String, dynamic> jsonAnswer = json.decode(response.body);

      return jsonAnswer['score'];
    } catch (e) {
      return false;
    }
  }

  //Sessions
  Future<dynamic> getLastSession(String userUUID) async {
    try {
      final response = await http.get(
        '$serverUrl$sessions?user=$userUUID',
        headers: headers,
      );

      if (response.statusCode != 200) {
        print(
            "Request: ${response.request.toString()} -> Response: ${response.body}");
        return ApiResponse.fromJson(json.decode(response.body));
      } else {
        List<dynamic> jsonAnswer = json.decode(response.body);
        List<Session> allSessions = List();

        for (var item in jsonAnswer) {
          allSessions.add(Session.fromJson(item));
        }

        if (allSessions.length == 0) {
          return 0;
        }

        return allSessions[0].session_ID;
      }
    } catch (e) {
      print(e.message);
      return false;
    }
  }

  Future<dynamic> createSession(Session session) async {
    try {
      final response = await http.post('$serverUrl$sessions/',
          headers: headers,
          body: json.encode(
            session.toJson(),
          ));

      if (response.statusCode != 201) {
        print(
            "Request: ${response.request.toString()} -> Response: ${response.body}");
        return ApiResponse.fromJson(json.decode(response.body));
      }

      // Todo: Save id
      // Utils.session.id = response.body['id']
      var body = json.decode(response.body);
      print(body);
      return body['id'];
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<dynamic> closeSession(Session session) async {
    try {
      final response = await http.put(
          '$serverUrl$sessionUpdate${session.session_ID}/',
          headers: headers,
          body: json.encode({'session_end_time': session.session_end_time}));

      if (response.statusCode != 200) {
        print(
            "Request: ${response.request.toString()} -> Response: ${response.body}");
        return ApiResponse.fromJson(json.decode(response.body));
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  //Reports
  Future<dynamic> createReport(Report report) async {
    try {
      var body = {};

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
      if (response.statusCode != 201) {
        print(
            "Request: ${response.request.toString()} -> Response: ${response.body}");
        return ApiResponse.fromJson(json.decode(response.body));
      }

      if (Utils.imagePath != null) {
        Utils.imagePath.forEach((img) {
          if (img['id'] == report.version_UUID) {
            saveImage(img['image'].path, report.version_UUID);
          }
        });
      }
      return true; 
    } catch (e) {
      return false;
    }
  }

  Future<dynamic> getReportsList(lat, lon,
      {int page,
      List<Report> allReports,
      bool show_hidden,
      int radius,
      bool show_verions}) async {
    try {
      var userUUID = await UserManager.getUUID();

      final response = await http.get(
        '$serverUrl$nearbyReports?lat=$lat&lon=$lon&radius=8000&page=$page&user=$userUUID' +
            (show_hidden == true ? '&show_hidden=1' : '') +
            (show_verions == true ? '&show_versions=1' : ''),
        headers: headers,
      );
      print(response);
      if (response.statusCode != 200) {
        print(
            "Request: ${response.request.toString()} -> Response: ${response.body}");
        return ApiResponse.fromJson(json.decode(response.body));
      } else {
        Map<String, dynamic> jsonAnswer = json.decode(response.body);
        page = jsonAnswer['next'];

        if (allReports == null) {
          allReports = List();
          UserManager.profileUUIDs = jsonAnswer['user_uuids'];
        }
        for (var item in jsonAnswer['results']) {
          allReports.add(Report.fromJson(item));
        }

        if (jsonAnswer['next'] == null && jsonAnswer['previous'] != null) {
          return allReports;
        }
      }

      return getReportsList(lat, lon, allReports: allReports, page: page);
    } catch (e) {
      print(e);
      return null;
    }
  }

  //Images
  Future<dynamic> saveImage(String image, String versionUUID) async {
    try {
      String fileName = image != null ? image.split('/').last : null;
      var dio = new Dio();

      var img = await MultipartFile.fromFile(image,
          filename: fileName, contentType: MediaType('image', 'jpeg'));

      FormData data = FormData.fromMap({"photo": img, "report": versionUUID});

      var response = await dio.post('$serverUrl$photos',
          data: data,
          options: Options(
            headers: {"Authorization": "Token " + token},
            contentType: 'multipart/form-data',
          ));

      print(response);

      return response.statusCode == 200;
    } catch (c) {
      print(c.message);
      return false;
    }
  }
}
