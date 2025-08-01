import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart' as html;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:mosquito_alert/mosquito_alert.dart' as sdk;
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
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
  static const _pageSize = 20;
  late final _pagingController = PagingController<int, sdk.Notification>(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) async {
        final response = await notificationsApi.listMine(
          page: pageKey,
          pageSize: _pageSize,
        );

        Iterable<sdk.Notification> notificationsIt =
            response.data?.results ?? [];
        List<sdk.Notification> notifications = notificationsIt.toList();

        if (pageKey == 1) {
          _checkOpenNotification();
        }

        return notifications;
      });

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
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _logScreenView() async {
    await FirebaseAnalytics.instance
        .logScreenView(screenName: '/notifications');
  }

  void _checkOpenNotification() {
    try {
      if (widget.notificationId != null && widget.notificationId!.isNotEmpty) {
        var notifId = widget.notificationId;
        for (var notif in _pagingController.items ?? []) {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Style.title(
          MyLocalizations.of(context, 'notifications_title'),
          fontSize: 16,
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(12),
        child: PagingListener<int, sdk.Notification>(
          controller: _pagingController,
          builder: (context, state, fetchNextPage) {
            return PagedListView<int, sdk.Notification>(
              state: state,
              fetchNextPage: fetchNextPage,
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              builderDelegate: PagedChildBuilderDelegate<sdk.Notification>(
                itemBuilder: (context, notification, index) {
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color:
                        notification.isRead ? Colors.grey[200] : Colors.white,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12),
                      onTap: () {
                        if (!notification.isRead) {
                          _updateNotification(notification.id);
                        }
                        _infoBottomSheet(context, notification);
                      },
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Style.titleMedium(notification.message.title,
                              fontSize: 16),
                          SizedBox(height: 4),
                          Style.bodySmall(
                            MyLocalizations.of(context, 'see_more_txt'),
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                noItemsFoundIndicatorBuilder: (context) => Center(
                  child: Style.body(
                    MyLocalizations.of(context, 'no_notifications_yet_txt'),
                  ),
                ),
                firstPageProgressIndicatorBuilder: (context) =>
                    Center(child: CircularProgressIndicator()),
                newPageProgressIndicatorBuilder: (context) =>
                    Center(child: CircularProgressIndicator()),
              ),
            );
          },
        ),
      ),
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

    if (res.statusCode == 200 && res.data != null) {
      final updatedNotification = res.data!;
      final itemList = _pagingController.items;

      if (itemList != null) {
        final index = itemList.indexWhere((n) => n.id == id);
        if (index != -1) {
          setState(() {
            itemList[index] = updatedNotification;
          });
          _updateUnreadNotificationCount();
        }
      }
    }
  }

  void _updateUnreadNotificationCount() {
    final itemList = _pagingController.items;
    if (itemList == null) return;

    final unacknowledgedCount =
        itemList.where((notification) => !notification.isRead).length;

    widget.onNotificationUpdate?.call(unacknowledgedCount);
  }
}
