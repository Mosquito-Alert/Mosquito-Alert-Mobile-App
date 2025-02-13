import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/pages/settings_pages/consent_form.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'Application.dart';

class UserManager {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? user;
  static var profileUUIDs;
  static int? userScore;

  static Future<bool> startFirstTime(context) async {
    var prefs = await SharedPreferences.getInstance();
    var firstTime = prefs.getBool('firstTime');

    if (firstTime == null || !firstTime) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ConsentForm(),
        ),
      );

      await prefs.setBool('firstTime', true);
      var uuid = Uuid().v4();
      var trackingUuid = Uuid().v4();
      await prefs.setString('uuid', uuid);
      await prefs.setString('trackingUUID', trackingUuid);
      await prefs.setBool('trackingEnabled', true);

      Utils.initializedCheckData['userCreated']['required'] = true;

      await ApiSingleton().createUser(uuid);
      await setLanguage(Utils.language.languageCode);
      await setLanguageCountry(Utils.language.countryCode);
    } else {
      var languageCode = await getLanguage();
      var countryCode = await getLanguageCountry();
      if (languageCode != null && countryCode != null) {
        Utils.language = Locale(languageCode, countryCode);
      } else {
        Utils.getLanguage();
      }
    }

    application.onLocaleChanged(Utils.language);
    await fetchUser();
    userScore = await ApiSingleton().getUserScores();
    await setUserScores(userScore);

    return true;
  }

  static Future<User?>? fetchUser() async {
    user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    Utils.initializedCheckData['user'] = true;
    return user;
  }

  //set
  static Future<void> setFrirebaseId(id) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('firebaseId', id);
  }

  static Future<void> setUserScores(scores) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userScores', scores);
  }

  static Future<void> setTracking(bool new_value) async {
    /*var prefs = await SharedPreferences.getInstance();

    if (new_value == true) {
      print('enable bg tracking');
      var status = await Permission.locationAlways.status;
      var request_status = await Permission.locationAlways.request();

      print('request_status: $request_status');

      if (!status.isGranted) {
        status = await Permission.locationAlways.request();
      }

      if (status.isGranted) {
        await prefs.setBool('trackingEnabled', true);
      }
    } else {
      print('disable bg tracking');
      await prefs.setBool('trackingEnabled', false);
    }*/

    var prefs = await SharedPreferences.getInstance();

    if (new_value == true) {
      print('enable bg tracking');

      // Step 1: Check the status of locationWhenInUse permission
      var whenInUseStatus = await Permission.locationWhenInUse.status;
      print('whenInUseStatus 1: $whenInUseStatus');

      // Step 2: If locationWhenInUse is not granted, request it
      if (!whenInUseStatus.isGranted) {
        whenInUseStatus = await Permission.locationWhenInUse.request();
        print('whenInUseStatus 2: $whenInUseStatus');
      }

      // Step 3: If locationWhenInUse is granted, request locationAlways permission
      if (whenInUseStatus.isGranted) {
        print('whenInUseStatus 3: $whenInUseStatus');
        var alwaysStatus = await Permission.locationAlways.status;
        print('alwaysStatus 1: $alwaysStatus');

        // Step 4: If locationAlways is not granted, request it
        if (!alwaysStatus.isGranted) {
          print('alwaysStatus 2: $alwaysStatus');
          alwaysStatus = await Permission.locationAlways.request();
          print('alwaysStatus 3: $alwaysStatus');
        }
        print('alwaysStatus 4: $alwaysStatus');
        print('whenInUseStatus 4: $whenInUseStatus');
        // Step 5: Handle the result of the locationAlways request
        if (alwaysStatus.isGranted) {
          print('Location Always permission granted. Enabling tracking...');
          await prefs.setBool('trackingEnabled', true);
        } else if (alwaysStatus.isPermanentlyDenied) {
          print(
              'Location Always permission permanently denied. Redirecting to app settings...');
          await openAppSettings(); // Open app settings for the user to manually enable the permission
        } else {
          print('Location Always permission denied. Tracking not enabled.');
        }
      } else if (whenInUseStatus.isPermanentlyDenied) {
        print(
            'Location When In Use permission permanently denied. Redirecting to app settings...');
        await openAppSettings(); // Open app settings for the user to manually enable the permission
      } else {
        print('Location When In Use permission denied. Tracking not enabled.');
      }
    } else {
      // Disable tracking
      print('disable bg tracking');
      await prefs.setBool('trackingEnabled', false);
    }
  }

  static Future<void> setSowInfoAdult(show) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setBool('infoCameraAdult', show);
  }

  static Future<void> setSowInfoBreeding(show) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setBool('infoCameraBreeding', show);
  }

  static Future<void> setLanguage(language) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }

  static Future<void> setLanguageCountry(lngCountry) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCountry', lngCountry);
  }

  static Future<void> setReportList(reportList) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('reportsList', reportList);
  }

  static Future<void> setImageList(imageList) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('imagesList', imageList);
  }

  static Future<bool> setHashtags(List<String>? hashtags) async {
    var prefs = await SharedPreferences.getInstance();
    if (hashtags == null || hashtags.isEmpty) {
      return prefs.remove('hashtags');
    }
    return prefs.setStringList('hashtags', hashtags);
  }

  static Future<void> setServerUrl(String serverUrl) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('serverUrl', serverUrl);
  }

  static Future<void> setLastReviewRequest(int lastReviewRequest) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastReviewRequest', lastReviewRequest);
  }

  static Future<void> setLastReportCount(int lastReportCount) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastReportCount', lastReportCount);
  }

  //get
  static Future<String?> getUUID() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.get('uuid') as FutureOr<String?>;
  }

  static Future<String?> getTrackingId() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.get('trackingUUID') as FutureOr<String?>;
  }

  static Future<String?> getFirebaseId() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString('firebaseId');
  }

  static Future<int?> getUserScores() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userScores');
  }

  static Future<bool> getTracking() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getBool('trackingEnabled') ?? false;
  }

  static Future<bool?> getShowInfoAdult() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getBool('infoCameraAdult');
  }

  static Future<bool?> getShowInfoBreeding() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getBool('infoCameraBreeding');
  }

  static Future<String?> getLanguage() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString('language');
  }

  static Future<String?> getLanguageCountry() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString('languageCountry');
  }

  static Future<String?> getUserLocale() async {
    return '${await UserManager.getLanguage()}_${await UserManager.getLanguageCountry()}';
  }

  static Future<List<String>?> getReportList() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('reportsList');
  }

  static Future<List<String>?> getImageList() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('imagesList');
  }

  static Future<void> migrateHashtagToHashtags() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if the old variable exists
    if (!prefs.containsKey('hashtag')) {
      return;
    }

    var oldHashtag = prefs.getString('hashtag');

    if (oldHashtag == null) {
      return;
    }

    // Users were adding the hashtag manually to the strings
    if (oldHashtag.startsWith('#')) {
      oldHashtag = oldHashtag.substring(1);
    }

    await prefs.setStringList('hashtags', [oldHashtag]);
    // Remove the old variable
    await prefs.remove('hashtag');
  }

  static Future<List<String>?> getHashtags() async {
    await UserManager.migrateHashtagToHashtags();
    var prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('hashtags');
  }

  static Future<String> getServerUrl() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString('serverUrl') ?? '';
  }

  static Future<int?> getLastReviewRequest() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getInt('lastReviewRequest');
  }

  static Future<int?> getLastReportCount() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getInt('lastReportCount');
  }

  static signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('firebaseId');
    user = null;
  }
}
