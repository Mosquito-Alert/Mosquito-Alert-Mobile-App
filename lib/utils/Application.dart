import 'package:flutter/material.dart';

class Application {
  static final Application _application = Application._internal();

  factory Application() {
    return _application;
  }

  Application._internal();

  final List<String> supportedLanguagesCodes = [
    "bg_BG",
    "ca_ES",
    "de_DE",
    "el_GR",
    "en_US",
    "es_ES",
    "fr_FR",
    "hr_HR",
    "hu_HU",
    "it_IT",
    "lb_LU",
    "mk_MK",
    "nl_NL",
    "pt_PT",
    "ro_RO",
    "ru_RU",
    "sl_SI",
    "sq_AL",
    "sr_RS",
    "tr_TR",
    "zh_CH",
    "zh_HK",
  ];

  //returns the list of supported Locales
  Iterable<Locale> supportedLocales() =>
      supportedLanguagesCodes.map<Locale>((language) {
        var languageCodes = language.split('_');
        return Locale(languageCodes[0], languageCodes[1]);
      });

  //function to be invoked when changing the language
  LocaleChangeCallback onLocaleChanged;
}

Application application = Application();

typedef void LocaleChangeCallback(Locale locale);
