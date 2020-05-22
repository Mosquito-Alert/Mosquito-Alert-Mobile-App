import 'package:firebase_auth/firebase_auth.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserManager {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static FirebaseUser user;
  static var profileUUIDs;

  static Future startFirstTime(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstTime = prefs.getBool('firstTime');

    if (firstTime == null || !firstTime) {
      prefs.setBool("firstTime", true);
      var uuid = new Uuid().v4();
      prefs.setString("uuid", uuid);
      ApiSingleton().createUser(uuid);
    }
    fetchUser();
    int scores = await ApiSingleton().getUserScores();
    setUserScores(scores); 
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

  //get
  static Future<String> getUUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get("uuid");
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

  static signOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("userName");
    prefs.remove("firebaseId");
    user = null;
  }
}
