import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';

import 'MyLocalizations.dart';
import 'package:flutter/material.dart';

class MyLocalizationsDelegate extends LocalizationsDelegate<MyLocalizations> {
  final Locale newLocale;

  const MyLocalizationsDelegate({this.newLocale});

  @override
  bool isSupported(Locale locale) => [
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
      ].contains(
          "${Utils.language.languageCode}_${Utils.language.countryCode}");

  @override
  Future<MyLocalizations> load(Locale locale) async {
    String lang = await UserManager.getLanguage();
    String country = await UserManager.getLanguageCountry();
    Locale savedLocale = Utils.getLanguage();
    if (lang != null && country != null) {
      savedLocale = Locale(lang, country);
    }
    return MyLocalizations.loadTranslations(newLocale ?? savedLocale);
  }

  @override
  bool shouldReload(MyLocalizationsDelegate old) => true;
}
