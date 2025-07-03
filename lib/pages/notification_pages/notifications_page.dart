import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart' as html;
import 'package:intl/intl.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert/src/model/notification.dart' as ext;
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/customModalBottomSheet.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class NotificationsPage extends StatefulWidget {
  final String? notificationId;
  final Function(int)? onNotificationUpdate;

  const NotificationsPage(
      {Key? key, this.notificationId, this.onNotificationUpdate})
      : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  PaginatedNotificationList? notifications;
  StreamController<bool> loadingStream = StreamController<bool>.broadcast();

  @override
  void initState() {
    super.initState();
    _logScreenView();
    loadingStream.add(true);
    _getData().then((_) {
      _updateUnreadNotificationCount();
    });
  }

  Future<void> _logScreenView() async {
    await FirebaseAnalytics.instance
        .logScreenView(screenName: '/notifications');
  }

  Future<void> _getData() async {
    NotificationsApi notificationsApi = ApiSingleton.api.getNotificationsApi();
    Response<PaginatedNotificationList?> response =
        await notificationsApi.listMine();
    setState(() {
      notifications = response.data;
      _checkOpenNotification();
    });
    loadingStream.add(false);
  }

  void _checkOpenNotification() {
    try {
      if (widget.notificationId != null && widget.notificationId!.isNotEmpty) {
        var notifId = widget.notificationId;
        for (var notif in notifications?.results?.toList() ?? []) {
          if (notifId == '${notif.id}') {
            _infoBottomSheet(context, notif);
            return;
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsList = notifications?.results?.toList() ?? [];
    return Stack(
      children: <Widget>[
        Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              centerTitle: true,
              title: Style.title(
                  MyLocalizations.of(context, 'notifications_title'),
                  fontSize: 16),
            ),
            body: notificationsList.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        Center(
                          child: Style.body(MyLocalizations.of(
                              context, 'no_notifications_yet_txt')),
                        ),
                      ])
                : Container(
                    margin: EdgeInsets.all(12),
                    child: ListView.builder(
                        // TODO: Replace with PagedListView
                        itemCount: notificationsList.length,
                        itemBuilder: (ctx, index) {
                          final notification = notificationsList[index];
                          return Opacity(
                            opacity: 1,
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              color: notification.isRead
                                  ? Colors.grey[200]
                                  : Colors.white,
                              child: ListTile(
                                tileColor: notification.isRead
                                    ? Colors.grey[200]
                                    : Colors.white,
                                contentPadding: EdgeInsets.all(12),
                                onTap: () {
                                  if (!notification.isRead) {
                                    _updateNotification(notification.id);
                                  }
                                  _infoBottomSheet(context, notification);
                                },
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Style.titleMedium(
                                        notification.message.title,
                                        fontSize: 16),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Style.bodySmall(
                                        MyLocalizations.of(
                                            context, 'see_more_txt'),
                                        color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }))),
        StreamBuilder<bool>(
            stream: loadingStream.stream,
            initialData: true,
            builder: (BuildContext context, AsyncSnapshot<bool> snapLoading) {
              if (snapLoading.data == true) {
                return Container(
                  child: Center(
                    child: Utils.loading(true),
                  ),
                );
              }
              return Container();
            }),
      ],
    );
  }

  void _infoBottomSheet(
      BuildContext context, ext.Notification notification) async {
    await FirebaseAnalytics.instance.logSelectContent(
        contentType: 'notification', itemId: '${notification.id}');
    CustomShowModalBottomSheet.customShowModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            bottom: false,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  )),
              child: Container(
                margin:
                    EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 10),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 15,
                      ),
                      Style.titleMedium(notification.message.title),
                      Style.bodySmall(
                          DateFormat('dd-MM-yyyy HH:mm')
                              .format(notification.createdAt.toLocal()),
                          color: Colors.grey),
                      SizedBox(
                        height: 10,
                      ),
                      html.Html(
                        data: notification.message.body
                            .replaceAll('<p><a', '<a')
                            .replaceAll('</a></p>', '</a>'),
                        style: {
                          '*': html.Style(
                            padding: html.HtmlPaddings.zero,
                            margin: html.Margins.zero,
                          ),
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Future<void> _updateNotification(int id) async {
    NotificationRequest notificationRequest =
        NotificationRequest((b) => b..isRead = true);
    final res = await ApiSingleton.notificationsApi
        .update(id: id, notificationRequest: notificationRequest);

    if (res.statusCode == 200) {
      // BuiltValue objects are immutable, so you may need to refetch or rebuild the list
      setState(() {});
      _updateUnreadNotificationCount();
    }
  }

  void _updateUnreadNotificationCount() {
    final notifList = notifications?.results?.toList() ?? [];
    var unacknowledgedCount =
        notifList.where((notification) => !notification.isRead).length;
    if (widget.onNotificationUpdate != null) {
      widget.onNotificationUpdate!(unacknowledgedCount);
    }
  }
}
