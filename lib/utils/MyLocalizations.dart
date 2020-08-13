
import 'package:flutter/material.dart';

import 'Utils.dart';

class MyLocalizations {
  MyLocalizations(this.locale);

  final Locale locale;

  String translate(key) {
    return Utils.localizedValues[key];
  }

  static String of(BuildContext context, String key) {
    
    return Localizations.of<MyLocalizations>(context, MyLocalizations)
        .translate(key);
  }
}
