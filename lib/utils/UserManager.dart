import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/pages/settings_pages/tutorial_page.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserManager {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static FirebaseUser user;
  static var profileUUIDs;
  static int userScore;

  static Future<bool> startFirstTime(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstTime = prefs.getBool('firstTime');

    if (firstTime == null || !firstTime) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TutorialPage(),
        ),
      );
      
      prefs.setBool("firstTime", true);
      var uuid = new Uuid().v4();
      var trackingUuid = new Uuid().v4();
      String language = Utils.getLanguage();
      prefs.setString("uuid", uuid);
      prefs.setString("trackingUUID", trackingUuid);
      prefs.setBool("trackingDisabled", false);

      await ApiSingleton().createUser(uuid);
      setUserScores(1);
      setLanguage(language);
      
      
      userScore = await ApiSingleton().getUserScores();
    }

    fetchUser();
    setUserScores(userScore);
    Utils.language = await getLanguage();
    return true;
  }

  static fetchUser() async {
    user = await _auth.currentUser();
    return user;
  }

  //set
  static Future<void> setUserName(name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userName", name);
  }

  static Future<void> setFrirebaseId(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("firebaseId", id);
  }

  static Future<void> setUserScores(scores) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("userScores", scores);
  }

  static Future<void> setTracking(enabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("trackingDisabled", enabled);
  }

  static Future<void> setSowInfoAdult(show) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("infoCameraAdult", show);
  }

  static Future<void> setSowInfoBreeding(show) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("infoCameraBreeding", show);
  }

  static Future<void> setLanguage(language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("language", language);
  }

  //get
  static Future<String> getUUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get("uuid");
  }

  static Future<String> getTrackingId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get("trackingUUID");
  }

  static Future<String> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userName");
  }

  static Future<String> getFirebaseId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("firebaseId");
  }

  static Future<int> getUserScores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt("userScores");
  }

  static Future<bool> getTracking() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("trackingDisabled");
  }

  static Future<bool> getShowInfoAdult() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("infoCameraAdult");
  }

  static Future<bool> getShowInfoBreeding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("infoCameraBreeding");
  }

  static Future<String> getLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("language");
  }

  static signOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("userName");
    prefs.remove("firebaseId");
    user = null;
  }
}
