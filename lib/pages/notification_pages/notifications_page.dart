import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart' as html;
import 'package:intl/intl.dart';
import 'package:mosquito_alert/mosquito_alert.dart' as sdk;
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/customModalBottomSheet.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:provider/provider.dart';

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
  List<sdk.Notification> notifications = [];
  StreamController<bool> loadingStream = StreamController<bool>.broadcast();
  late sdk.NotificationsApi notificationsApi;

  @override
  void initState() {
    super.initState();
    sdk.MosquitoAlert apiClient =
        Provider.of<sdk.MosquitoAlert>(context, listen: false);
    notificationsApi = apiClient.getNotificationsApi();
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
    try {
      Response<sdk.PaginatedNotificationList?> response =
          await notificationsApi.listMine();
      setState(() {
        notifications.addAll(response.data?.results ?? []);
        _checkOpenNotification();
      });
      loadingStream.add(false);
    } catch (e) {
      print(e);
    }
  }

  void _checkOpenNotification() {
    try {
      if (widget.notificationId != null && widget.notificationId!.isNotEmpty) {
        var notifId = widget.notificationId;
        for (var notif in notifications) {
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
            body: notifications.isEmpty
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
                        itemCount: notifications.length,
                        itemBuilder: (ctx, index) {
                          final notification = notifications[index];
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
      BuildContext context, sdk.Notification notification) async {
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
    sdk.PatchedNotificationRequest patchedNotificationRequest =
        sdk.PatchedNotificationRequest((b) => b..isRead = true);
    final res = await notificationsApi.partialUpdate(
        id: id, patchedNotificationRequest: patchedNotificationRequest);

    if (res.statusCode == 200) {
      // BuiltValue objects are immutable, so you may need to refetch or rebuild the list
      setState(() {});
      _updateUnreadNotificationCount();
    }
  }

  void _updateUnreadNotificationCount() {
    final notifList = notifications;
    var unacknowledgedCount =
        notifList.where((notification) => !notification.isRead).length;
    if (widget.onNotificationUpdate != null) {
      widget.onNotificationUpdate!(unacknowledgedCount);
    }
  }
}
