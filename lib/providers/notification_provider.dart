import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:mosquito_alert/mosquito_alert.dart' as sdk;

import 'pagination_provider.dart';

class NotificationProvider extends PaginationProvider<sdk.Notification> {
  late final sdk.NotificationsApi notificationsApi;

  NotificationProvider({required super.apiClient}) {
    notificationsApi = apiClient.getNotificationsApi();
  }

  List<sdk.Notification> get notifications => objects;

  bool _isFetchingUnread = false;

  int _unreadNotificationsCount = 0;
  int get unreadNotificationsCount => _unreadNotificationsCount;

  Future<sdk.Notification?> getById({required int id}) async {
    // Check in the cached list first
    final sdk.Notification? cached =
        notifications.where((n) => n.id == id).firstOrNull;
    if (cached != null) return cached;

    // Otherwise, fetch from API
    try {
      final response = await notificationsApi.retrieve(id: id);
      return response.data!;
    } catch (e) {
      debugPrint('Error fetching notification by id: $e');
      return null;
    }
  }

  Future<void> markAsRead({required sdk.Notification notification}) async {
    if (notification.isRead) return;

    try {
      final request = sdk.PatchedNotificationRequest((b) => b..isRead = true);
      await notificationsApi.partialUpdate(
          id: notification.id, patchedNotificationRequest: request);
      // Update local cache
      final index = notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        final updatedNotification =
            notifications[index].rebuild((b) => b..isRead = true);
        notifications[index] = updatedNotification;
        _unreadNotificationsCount = max(0, (_unreadNotificationsCount - 1));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  @override
  Future<Response<sdk.PaginatedNotificationList>> fetchPage({
    required int page,
    required int pageSize,
  }) {
    return notificationsApi.listMine(
      page: page,
      pageSize: pageSize,
      orderBy: BuiltList<String>([
        "-created_at",
      ]),
    );
  }

  Future<void> fetchUnreadNotificationsCount() async {
    if (_isFetchingUnread) {
      debugPrint("Skipping fetchUnreadNotificationsCount — already loading");
      return;
    }
    try {
      _isFetchingUnread = true;
      final response = await notificationsApi.listMine(
        pageSize: 1,
        isRead: false,
      );
      _unreadNotificationsCount = response.data?.count ?? 0;
    } catch (_) {
      // Optionally handle/log
    } finally {
      _isFetchingUnread = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    super.refresh();
    await fetchUnreadNotificationsCount();
  }
}
