import 'package:flutter/material.dart';

import 'package:timeago/timeago.dart' as timeago;

class Application {
  static final Application _application = Application._internal();

  factory Application() {
    return _application;
  }

  Application._internal() {
    for (var entry in _localeMessages.entries) {
      timeago.setLocaleMessages(entry.key, entry.value);
    }
  }

  final Map<String, timeago.LookupMessages> _localeMessages = {
    // 'bg',
    'bn': timeago.BnMessages(),
    'bn_short': timeago.BnShortMessages(),
    'ca': timeago.CaMessages(),
    'ca_short': timeago.CaShortMessages(),
    'de': timeago.DeMessages(),
    'de_short': timeago.DeShortMessages(),
    'el': timeago.GrMessages(),
    'el_short': timeago.GrShortMessages(),
    'en': timeago.EnMessages(),
    'en_short': timeago.EnShortMessages(),
    'es': timeago.EsMessages(),
    'es_short': timeago.EsShortMessages(),
    'fr': timeago.FrMessages(),
    'fr_short': timeago.FrShortMessages(),
    'hr': timeago.HrMessages(),
    'hr_short': timeago.HrMessages(),
    'hu': timeago.HuMessages(),
    'hu_short': timeago.HuShortMessages(),
    'it': timeago.ItMessages(),
    'it_short': timeago.ItShortMessages(),
    'lb': timeago.DeMessages(),
    'lb_short': timeago.DeShortMessages(),
    // 'mk': ,
    'nl': timeago.NlMessages(),
    'nl_short': timeago.NlShortMessages(),
    'pt': timeago.PtBrMessages(),
    'pt_short': timeago.PtBrShortMessages(),
    'ro': timeago.RoMessages(),
    'ro_short': timeago.RoShortMessages(),
    'ru': timeago.RuMessages(),
    'ru_short': timeago.RuShortMessages(),
    // 'sl': ,
    // 'sq': ,
    'sr': timeago.SrMessages(),
    'sr_short': timeago.SrShortMessages(),
    'sv': timeago.SvMessages(),
    'sv_short': timeago.SvShortMessages(),
    'tr': timeago.TrMessages(),
    'tr_short': timeago.TrShortMessages(),
    'zh': timeago.ZhCnMessages(),
    'zh_short': timeago.ZhCnMessages(),
  };

  final List<String> supportedLanguagesCodes = [
    'bg',
    'bn',
    'ca',
    'de',
    'el',
    'en',
    'es',
    'fr',
    'hr',
    'hu',
    'it',
    'lb',
    'mk',
    'nl',
    'pt',
    'ro',
    'ru',
    'sl',
    'sq',
    'sr',
    'sv',
    'tr',
    'zh',
  ];

  //returns the list of supported Locales
  Iterable<Locale> supportedLocales() =>
      supportedLanguagesCodes.map<Locale>((language) {
        return Locale(language);
      });

  //function to be invoked when changing the language
  late LocaleChangeCallback onLocaleChanged;
}

Application application = Application();

typedef LocaleChangeCallback = void Function(Locale locale);
