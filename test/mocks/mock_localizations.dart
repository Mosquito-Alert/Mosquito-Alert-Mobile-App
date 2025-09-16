import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';

/// Test implementation of MyLocalizations that eliminates duplication
/// 
/// This class returns translation keys instead of translated text, which:
/// - Eliminates duplication between mock translations and real translation files
/// - Makes tests more maintainable by avoiding hardcoded translations
/// - Allows tests to assert against keys (e.g., 'single_bite') instead of translated text
/// - Prevents test failures when translations change in the actual JSON files
///
/// Usage in tests:
/// - Widget tests can still verify localization keys are passed correctly
/// - If tests need to verify actual translated text, they should use integration tests
///   with real MyLocalizations that load from actual translation files
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
