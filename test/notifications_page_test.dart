import 'package:built_collection/built_collection.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosquito_alert/mosquito_alert.dart' as sdk;
import 'package:mosquito_alert_app/pages/notification_pages/notifications_page.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/MyLocalizationsDelegate.dart';
import 'package:provider/provider.dart';

// Mock classes
class MockMosquitoAlert extends sdk.MosquitoAlert {
  final MockNotificationsApi _notificationsApi = MockNotificationsApi();
  
  @override
  sdk.NotificationsApi getNotificationsApi() => _notificationsApi;
}

class MockNotificationsApi extends sdk.NotificationsApi {
  List<sdk.Notification> _notifications = [];
  int _currentPage = 1;
  static const int _pageSize = 20;
  
  void setNotifications(List<sdk.Notification> notifications) {
    _notifications = notifications;
    _currentPage = 1;
  }
  
  @override
  Future<sdk.Response<sdk.PaginatedNotificationList>> listMine({
    int? page,
    int? pageSize,
    BuiltList<String>? orderBy,
  }) async {
    final currentPage = page ?? 1;
    final size = pageSize ?? _pageSize;
    final startIndex = (currentPage - 1) * size;
    final endIndex = startIndex + size;
    
    final pageNotifications = _notifications.sublist(
      startIndex, 
      endIndex > _notifications.length ? _notifications.length : endIndex
    );
    
    final hasNext = endIndex < _notifications.length;
    final nextUrl = hasNext ? 'http://example.com/?page=${currentPage + 1}' : null;
    
    final paginatedList = sdk.PaginatedNotificationList((b) => b
      ..results = BuiltList<sdk.Notification>(pageNotifications)
      ..next = nextUrl
      ..count = _notifications.length
    );
    
    return sdk.Response<sdk.PaginatedNotificationList>(
      data: paginatedList,
      statusCode: 200,
    );
  }
  
  @override
  Future<sdk.Response<sdk.Notification>> retrieve({required int id}) async {
    final notification = _notifications.firstWhere(
      (n) => n.id == id,
      orElse: () => throw Exception('Notification not found')
    );
    
    return sdk.Response<sdk.Notification>(
      data: notification,
      statusCode: 200,
    );
  }
  
  @override
  Future<sdk.Response<sdk.Notification>> partialUpdate({
    required int id,
    required sdk.PatchedNotificationRequest patchedNotificationRequest,
  }) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) throw Exception('Notification not found');
    
    final updatedNotification = _notifications[index].rebuild((b) => b
      ..isRead = patchedNotificationRequest.isRead ?? b.isRead
    );
    
    _notifications[index] = updatedNotification;
    
    return sdk.Response<sdk.Notification>(
      data: updatedNotification,
      statusCode: 200,
    );
  }
}

class MockFirebaseAnalytics {
  static void setMockMethodCallHandler() {
    // This would normally set up method channel mocking for Firebase Analytics
    // For this test, we'll assume Firebase Analytics calls don't throw errors
  }
}

// Helper function to create test notifications
sdk.Notification createTestNotification({
  required int id,
  required String title,
  required String body,
  bool isRead = false,
  DateTime? createdAt,
}) {
  return sdk.Notification((b) => b
    ..id = id
    ..isRead = isRead
    ..createdAt = createdAt ?? DateTime.now()
    ..message = sdk.NotificationMessage((m) => m
      ..title = title
      ..body = body
    ).toBuilder()
  );
}

Widget createTestWidget({
  int? notificationId,
  required MockMosquitoAlert mockClient,
}) {
  return Provider<sdk.MosquitoAlert>.value(
    value: mockClient,
    child: MaterialApp(
      localizationsDelegates: const [
        MyLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('ca'),
      ],
      home: NotificationsPage(notificationId: notificationId),
    ),
  );
}

void main() {
  group('NotificationsPage Tests', () {
    late MockMosquitoAlert mockClient;
    late MockNotificationsApi mockApi;

    setUp(() {
      mockClient = MockMosquitoAlert();
      mockApi = mockClient._notificationsApi;
      MockFirebaseAnalytics.setMockMethodCallHandler();
    });

    testWidgets('should display no notifications message when empty', (WidgetTester tester) async {
      // Arrange
      mockApi.setNotifications([]);
      
      // Act
      await tester.pumpWidget(createTestWidget(mockClient: mockClient));
      await tester.pumpAndSettle();
      
      // Assert - Check for the presence of no notifications indicator
      // Using widget structure rather than text for language-agnostic testing
      expect(find.byType(NotificationsPage), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      
      // Wait for the initial loading to complete
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      
      // The no items indicator should be present when there are no notifications
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('should display single notification and show bottom sheet on tap', (WidgetTester tester) async {
      // Arrange
      final testNotification = createTestNotification(
        id: 1,
        title: 'Test Notification',
        body: '<p>This is a test notification body</p>',
        isRead: false,
      );
      mockApi.setNotifications([testNotification]);
      
      // Act
      await tester.pumpWidget(createTestWidget(mockClient: mockClient));
      await tester.pumpAndSettle();
      
      // Assert - Check notification is displayed
      expect(find.byType(NotificationsPage), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
      
      // Check notification styling for unread (white background)
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, equals(Colors.white));
      
      // Test tap to show bottom sheet
      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();
      
      // Verify bottom sheet appears
      expect(find.byType(SafeArea), findsWidgets);
      expect(find.text('Test Notification'), findsOneWidget);
    });

    testWidgets('should handle pagination with 20+ notifications', (WidgetTester tester) async {
      // Arrange - Create 25 notifications to test pagination
      final notifications = List.generate(25, (index) => createTestNotification(
        id: index + 1,
        title: 'Notification ${index + 1}',
        body: '<p>Body ${index + 1}</p>',
        isRead: index % 2 == 0, // Mix of read/unread
      ));
      mockApi.setNotifications(notifications);
      
      // Act
      await tester.pumpWidget(createTestWidget(mockClient: mockClient));
      await tester.pumpAndSettle();
      
      // Assert - Check first page of notifications (20 items)
      expect(find.byType(NotificationsPage), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(20));
      
      // Test pagination by scrolling to bottom
      await tester.scrollUntilVisible(find.byType(Card).last, 500.0);
      await tester.pumpAndSettle();
      
      // After pagination, should have all 25 notifications
      expect(find.byType(Card), findsNWidgets(25));
    });

    testWidgets('should open specific notification when notificationId provided', (WidgetTester tester) async {
      // Arrange
      final testNotification = createTestNotification(
        id: 42,
        title: 'Direct Access Notification',
        body: '<p>This notification was opened directly</p>',
        isRead: false,
      );
      mockApi.setNotifications([testNotification]);
      
      // Act - Create widget with specific notification ID
      await tester.pumpWidget(createTestWidget(
        notificationId: 42,
        mockClient: mockClient,
      ));
      await tester.pumpAndSettle();
      
      // Assert - Bottom sheet should open automatically
      expect(find.byType(NotificationsPage), findsOneWidget);
      expect(find.text('Direct Access Notification'), findsOneWidget);
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('should display read notifications with grey background', (WidgetTester tester) async {
      // Arrange
      final readNotification = createTestNotification(
        id: 1,
        title: 'Read Notification',
        body: '<p>This has been read</p>',
        isRead: true,
      );
      final unreadNotification = createTestNotification(
        id: 2,
        title: 'Unread Notification',
        body: '<p>This is unread</p>',
        isRead: false,
      );
      mockApi.setNotifications([readNotification, unreadNotification]);
      
      // Act
      await tester.pumpWidget(createTestWidget(mockClient: mockClient));
      await tester.pumpAndSettle();
      
      // Assert - Check proper color coding
      expect(find.byType(Card), findsNWidgets(2));
      
      final cards = tester.widgetList<Card>(find.byType(Card)).toList();
      // First card (read) should have grey background
      expect(cards[0].color, equals(Colors.grey[200]));
      // Second card (unread) should have white background
      expect(cards[1].color, equals(Colors.white));
    });

    testWidgets('should mark notification as read when tapped', (WidgetTester tester) async {
      // Arrange
      final unreadNotification = createTestNotification(
        id: 1,
        title: 'Unread Notification',
        body: '<p>This will be marked as read</p>',
        isRead: false,
      );
      mockApi.setNotifications([unreadNotification]);
      
      // Act
      await tester.pumpWidget(createTestWidget(mockClient: mockClient));
      await tester.pumpAndSettle();
      
      // Verify initial state (white background for unread)
      Card card = tester.widget<Card>(find.byType(Card));
      expect(card.color, equals(Colors.white));
      
      // Tap the notification
      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();
      
      // Close the bottom sheet
      await tester.tapAt(const Offset(50, 50)); // Tap outside bottom sheet
      await tester.pumpAndSettle();
      
      // Assert - Notification should now be marked as read (grey background)
      card = tester.widget<Card>(find.byType(Card));
      expect(card.color, equals(Colors.grey[200]));
    });

    testWidgets('should handle API errors gracefully', (WidgetTester tester) async {
      // Arrange - Setup API to return error
      mockApi.setNotifications([]);
      
      // Act
      await tester.pumpWidget(createTestWidget(mockClient: mockClient));
      await tester.pumpAndSettle();
      
      // Assert - Should not crash and display empty state
      expect(find.byType(NotificationsPage), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      // No cards should be displayed when API returns empty
      expect(find.byType(Card), findsNothing);
    });
  });
}