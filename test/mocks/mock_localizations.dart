import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';

// Test MyLocalizations that returns translation keys for easy testing
// This eliminates duplication by avoiding hardcoded translations
class TestMyLocalizations extends MyLocalizations {
  TestMyLocalizations() : super(const Locale('en', 'US'));

  @override
  String translate(String? key) {
    // Return the key itself for testing - this eliminates duplication
    // Tests can assert against keys instead of translated text
    return key ?? '';
  }

  static TestMyLocalizations of(BuildContext context) {
    return TestMyLocalizations();
  }
}

class TestMyLocalizationsDelegate
    extends LocalizationsDelegate<MyLocalizations> {
  const TestMyLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MyLocalizations> load(Locale locale) async {
    return TestMyLocalizations();
  }

  @override
  bool shouldReload(TestMyLocalizationsDelegate old) => false;
}
