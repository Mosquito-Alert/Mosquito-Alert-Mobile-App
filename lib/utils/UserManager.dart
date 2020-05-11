import 'package:mosquito_alert_app/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserManager {
  static String userName;

  static Future startFirstTime(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstTime = prefs.getBool('firstTime');

    if (firstTime == null || !firstTime) {
      prefs.setBool("firstTime", true);
      var uuid = new Uuid().v4();
      prefs.setString("uuid", uuid);
      ApiSingleton().createUser(uuid);
    }
    userName = await getUserName();
  }

  //set
  static Future<void> setUserName(name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userName", name);
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

  static signOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("userName");
    userName = null;
  }
}
