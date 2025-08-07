import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mosquito_alert_app/app_config.dart';
import 'package:mosquito_alert_app/providers/user_provider.dart';
import 'package:mosquito_alert_app/utils/MessageNotification.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

import '../api/api.dart';
import '../main.dart';
import '../pages/notification_pages/notifications_page.dart';

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
  static Future<void> init(BuildContext context) async {
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
        await registerFCMToken(token, context);
        Utils.initializedCheckData['firebase'] = true;
        _initialized = true;
      }
    }
  }

  static void launchMessage(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    if (notification == null) {
      print('Notification is null, aborting launch.');
      return;
    }
    String? title = notification.title;
    String? msg = notification.body;
    if (title == null || msg == null) {
      print('Title or message is null, aborting launch.');
      return;
    }

    int? notifId = int.tryParse(message.data['id'].toString());

    showOverlayNotification((context) {
      return MessageNotification(
        title: title,
        message: msg,
        onTap: () {
          OverlaySupportEntry.of(context)!.dismiss();
          if (notifId == null) {
            print('Notification ID is null, not navigating.');
            return;
          }
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

  void _handleBackgroundMessage(RemoteMessage message) {
    if (message.data['id'] != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => NotificationsPage(
                    notificationId: int.tryParse(message.data['id'].toString()),
                  ),
              fullscreenDialog: true));
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    if (notification == null) {
      print('Notification is null, aborting launch.');
      return;
    }
    String? title = notification.title;
    String? msg = notification.body;
    if (title == null && msg == null) {
      print('Title and message are null, aborting launch.');
      return;
    }

    int? notifId = int.tryParse(message.data['id'].toString());

    showOverlayNotification((context) {
      return MessageNotification(
        title: title,
        message: msg,
        onTap: () {
          OverlaySupportEntry.of(context)!.dismiss();
          if (notifId == null) {
            print('Notification ID is null, not navigating.');
            return;
          }
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

  static void openMessageScreen(Map<String, dynamic> message) {
    int? notifId;

    try {
      final rawId = message['id'];

      if (Platform.isIOS) {
        notifId = int.tryParse(jsonDecode(rawId).toString());
      } else {
        notifId = int.tryParse(rawId.toString());
      }
    } catch (e) {
      print('Error parsing notification ID: $e');
    }

    // Don't proceed if notifId is null
    if (notifId == null) {
      print('Notification ID is null, aborting navigation.');
      return;
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

  static Future<void> registerFCMToken(
      String fcmToken, BuildContext context) async {
    final userId = Provider.of<UserProvider>(context, listen: false).user?.uuid;
    ApiSingleton().setFirebaseToken(userId, fcmToken);
  }
}
