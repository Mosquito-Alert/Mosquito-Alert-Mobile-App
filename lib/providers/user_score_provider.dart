import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/api/api.dart';

class UserScoreProvider extends ChangeNotifier {
  int _score = 0;
  int get score => _score;

  Future<void> fetchUserScore() async {
    try {
      final response = await ApiSingleton.usersApi.retrieveMine();
      if (response.data?.score.value != null) {
        _score = response.data!.score.value;
        notifyListeners();
      }
    } catch (e) {
      print('Error getting user score: $e');
    }
  }
}
