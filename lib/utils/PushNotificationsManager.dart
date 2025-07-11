import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mosquito_alert_app/app_config.dart';
import 'package:mosquito_alert_app/utils/MessageNotification.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:overlay_support/overlay_support.dart';

import '../api/api.dart';
import '../main.dart';
import '../pages/notification_pages/notifications_page.dart';
import 'UserManager.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;
  static final PushNotificationsManager _instance =
      PushNotificationsManager._();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static bool _initialized = false;

  /*
  * Push Notification Manager Init
  */
  static Future<void> init() async {
    final appConfig = await AppConfig.loadConfig();
    if (!_initialized && appConfig.useAuth) {
      await _firebaseMessaging.requestPermission();

      FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
        launchMessage(remoteMessage);
      });

      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage remoteMessage) {
        openMessageScreen(remoteMessage.data);
      });

      if (Platform.isIOS) {
        await FirebaseMessaging.instance.getAPNSToken();
      }

      var token = await FirebaseMessaging.instance
          .getToken()
          .timeout(Duration(seconds: 10), onTimeout: () => null);

      if (token != null) {
        await registerFCMToken(token);
        Utils.initializedCheckData['firebase'] = true;
        _initialized = true;
      }
    }
  }

  static void launchMessage(RemoteMessage message) {
    String? title = message.notification?.title;
    String? msg = message.notification?.body;
    var notifId = message.data['id'];

    if (title!.isNotEmpty || msg!.isNotEmpty) {
      showOverlayNotification((context) {
        return MessageNotification(
          title: title,
          message: msg,
          onTap: () {
            OverlaySupportEntry.of(context)!.dismiss();
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NotificationsPage(
                        notificationId: notifId,
                      ),
                  fullscreenDialog: true),
            );
          },
        );
      }, duration: Duration(milliseconds: 4000));
    }
  }

  static void openMessageScreen(Map<String, dynamic> message) {
    var notifId = '';

    if (Platform.isIOS) {
      try {
        notifId = "${jsonDecode(message['id'])}";
      } catch (e) {
        print(e);
      }
    } else {
      try {
        notifId = "${message['id']}";
      } catch (e) {
        print(e);
      }
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        navigatorKey.currentContext!,
        MaterialPageRoute(
            builder: (context) => NotificationsPage(
                  notificationId: notifId,
                ),
            fullscreenDialog: true),
      );
      ;
    });
  }

  static Future<void> registerFCMToken(String fcmToken) async {
    var userId = await UserManager.getUUID();
    ApiSingleton().setFirebaseToken(userId, fcmToken);
  }
}
