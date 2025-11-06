import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class Utils {
  static Locale language = Locale('en', 'US');

  static Widget loading(_isLoading, [Color? indicatorColor]) {
    return _isLoading == true
        ? IgnorePointer(
            child: Container(
            color: Colors.transparent,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    indicatorColor ?? Style.colorPrimary),
              ),
            ),
          ))
        : Container();
  }

  static ui.Locale getLanguage() {
    var stringLanguange =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    var stringCountry =
        WidgetsBinding.instance.platformDispatcher.locale.countryCode;

    language = Locale('en', 'US');

    if (stringLanguange == 'es' && stringCountry == 'ES' ||
        stringLanguange == 'ca' && stringCountry == 'ES' ||
        stringLanguange == 'en' && stringCountry == 'US' ||
        stringLanguange == 'sq' ||
        stringLanguange == 'bg' ||
        stringLanguange == 'nl' ||
        stringLanguange == 'de' ||
        stringLanguange == 'it' ||
        stringLanguange == 'pt' ||
        stringLanguange == 'ro') {
      language = WidgetsBinding.instance.platformDispatcher.locale;
    }

    return language;
  }

  static Future<String?> getCityNameFromCoords(double lat, double lon) async {
    var locale = await UserManager.getUserLocale();
    await setLocaleIdentifier(locale!);
    var placemarks = await placemarkFromCoordinates(lat, lon);
    if (placemarks.isEmpty) {
      return null;
    }
    final placemark = placemarks.first;
    final parts = <String>[];

    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      parts.add(placemark.locality!);
    }
    if (placemark.country != null && placemark.country!.isNotEmpty) {
      parts.add(placemark.country!);
    }

    return parts.join(', ');
  }

  static String getRandomPassword(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final rand = Random.secure();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)])
        .join();
  }
}
