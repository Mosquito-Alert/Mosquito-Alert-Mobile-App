import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';

class TestMyLocalizations extends MyLocalizations {
  TestMyLocalizations() : super(const Locale('en', 'US'));

  @override
  String translate(String? key) {
    // Return the key itself - this eliminates the need to maintain
    // duplicate translations in test mocks
    return key ?? '';
  }

  static TestMyLocalizations of(BuildContext context) {
    return TestMyLocalizations();
  }
}

/// Localization delegate for tests that provides TestMyLocalizations
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

/// Helper for creating test widgets with proper localization setup
class TestLocalizationHelper {
  /// Creates a MaterialApp with TestMyLocalizations for widget testing
  static Widget createTestApp({required Widget child}) {
    return MaterialApp(
      localizationsDelegates: const [
        TestMyLocalizationsDelegate(),
      ],
      supportedLocales: const [Locale('en', 'US')],
      home: child,
    );
  }
}
