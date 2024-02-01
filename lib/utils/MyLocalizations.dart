import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyLocalizations {
  Locale locale;
  static Map<dynamic, dynamic>? _localisedValues;
  static Map<dynamic, dynamic>? _englishValues;

  MyLocalizations(this.locale) {
    locale = locale;
    _localisedValues = null;
    loadEnglishTranslations();
  }

  static Future<void> loadEnglishTranslations() async {
    var jsonContent = await rootBundle.loadString('assets/language/en.json');
    _englishValues = json.decode(jsonContent);
  }

  static Future<MyLocalizations> loadTranslations(Locale locale) async {
    MyLocalizations appTranslations = MyLocalizations(locale);
    String jsonContent = await rootBundle.loadString(locale.languageCode == 'zh'
        ? 'assets/language/${locale.languageCode}_${locale.countryCode}.json'
        : 'assets/language/${locale.languageCode}.json');
    _localisedValues = json.decode(jsonContent);
    return appTranslations;
  }

  String translate(key) {
    if (_localisedValues != null && _localisedValues![key] != null){
      return _localisedValues![key];
    }
    if (_englishValues != null && _englishValues![key] != null){
      // Default to English when there is not a translation available in the local language
      return _englishValues![key];
    }
    return '';
  }

  static String? of(BuildContext context, String? key) {
    return Localizations.of<MyLocalizations>(context, MyLocalizations)!
        .translate(key);
  }
}
