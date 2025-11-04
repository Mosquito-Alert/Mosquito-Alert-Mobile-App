import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart' as html;
import 'package:mosquito_alert/mosquito_alert.dart' as sdk;
import 'package:provider/provider.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class NotificationDetailPage extends StatefulWidget {
  final sdk.Notification? notification;
  final int? notificationId;
  final void Function(sdk.Notification)? onNotificationUpdated;

  const NotificationDetailPage({
    super.key,
    this.notification,
    this.notificationId,
    this.onNotificationUpdated,
  }) : assert(
          notification != null || notificationId != null,
          'Either notification or notificationId must be provided.',
        );

  @override
  State<NotificationDetailPage> createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  sdk.Notification? _notification; // local mutable copy
  late sdk.NotificationsApi notificationsApi;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();

    sdk.MosquitoAlert apiClient =
        Provider.of<sdk.MosquitoAlert>(context, listen: false);
    notificationsApi = apiClient.getNotificationsApi();

    if (widget.notification != null) {
      _notification = widget.notification!;
      _loading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _markAsRead());
    } else {
      _fetchNotification();
    }
  }

  Future<void> _fetchNotification() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final response =
          await notificationsApi.retrieve(id: widget.notificationId!);
      final fetched = response.data!;
      setState(() {
        _notification = fetched;
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _markAsRead());
    } catch (e) {
      debugPrint("Failed to fetch notification: $e");
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  Future<void> _markAsRead() async {
    final notif = _notification;
    if (notif == null || notif.isRead) return;

    try {
      final request = sdk.PatchedNotificationRequest((b) => b..isRead = true);

      final response = await notificationsApi.partialUpdate(
          id: notif.id, patchedNotificationRequest: request);

      final updatedNotification = response.data!;
      setState(() {
        _notification = updatedNotification; // update local state
      });

      // notify parent
      widget.onNotificationUpdated?.call(updatedNotification);
    } catch (e) {
      debugPrint("Failed to mark notification as read: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error || _notification == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Notification")),
        body: const Center(child: Text("Failed to load notification.")),
      );
    }
    final notification = _notification!;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60.0),
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.message.title,
                      style: TextStyle(
                        color: Style.colorPrimary,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy • h:mm a')
                          .format(notification.createdAt.toLocal()),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12.0,
                      ),
                    )
                  ]),
            ),
          )),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: html.Html(
                data: notification.message.body,
                style: {
                  '*': html.Style(
                    padding: html.HtmlPaddings.zero,
                    margin: html.Margins.zero,
                  ),
                },
              ),
            ),
    );
  }
}
