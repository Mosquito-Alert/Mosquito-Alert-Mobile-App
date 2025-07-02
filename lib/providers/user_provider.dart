import 'package:flutter/material.dart';
import 'package:mosquito_alert/src/model/user.dart';
import 'package:mosquito_alert_app/api/api.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  int get userScore => _user?.score.value ?? 0;

  Future<void> fetchUser() async {
    try {
      final response = await ApiSingleton.usersApi.retrieveMine();
      if (response.data != null) {
        _user = response.data;
        notifyListeners();
      }
    } catch (e) {
      print('Error getting user: $e');
    }
  }
}
