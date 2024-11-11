import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mosquito_alert_app/models/topic.dart';
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
  static List<Topic> currentTopics = <Topic>[];

  /*
  * Push Notification Manager Init
  */
  static Future<void> init() async {
    if (!_initialized) {
      await _firebaseMessaging.requestPermission();

      FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
        launchMessage(remoteMessage.data);
      });

      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage remoteMessage) {
        openMessageScreen(remoteMessage.data);
      });

      var token = await _firebaseMessaging
          .getToken()
          .timeout(Duration(seconds: 10), onTimeout: () => null);

      if (token != null) {
        await registerFCMToken(token);
        Utils.initializedCheckData['firebase'] = true;
        _initialized = true;
      }
    }
  }

  static void launchMessage(Map<String, dynamic> message) {
    String? title = '';
    String? msg = '';
    var notifId = '';

    if (Platform.isIOS) {
      final jsonData = jsonDecode(message['notification']);

      try {
        title = jsonData['title'];
      } catch (e) {
        print(e);
      }

      try {
        msg = jsonData['body'];
      } catch (e) {
        print(e);
      }
      try {
        notifId = "${jsonDecode(message['notification_id'])}";
      } catch (e) {
        print(e);
      }
    } else {
      final notification_data = jsonDecode(message['notification']);

      try {
        title = notification_data['title'];
      } catch (e) {
        print(e);
      }

      try {
        msg = notification_data['body'];
      } catch (e) {
        print(e);
      }

      try {
        notifId = "${message['notification_id']}";
      } catch (e) {
        print(e);
      }
    }

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
    var result = ApiSingleton().setFirebaseToken(userId, fcmToken);
  }
}
