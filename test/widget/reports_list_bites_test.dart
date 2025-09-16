import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosquito_alert/mosquito_alert.dart' as sdk;
import 'package:mosquito_alert_app/pages/my_reports_pages/components/reports_list_bites.dart';
import 'package:provider/provider.dart';

// Import shared mocks
import '../mocks/mocks.dart';

Widget createReportsListBitesTestWidget({
  MockMosquitoAlert? mockClient,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Provider<sdk.MosquitoAlert>(
        create: (_) => mockClient ?? MockMosquitoAlert(),
        child: ReportsListBites(),
      ),
    ),
    localizationsDelegates: const [
      MockMyLocalizationsDelegate(),
    ],
    supportedLocales: const [Locale('en')],
  );
}

// Simple test helper without complex nested structures
sdk.Bite createSimpleBite({
  required String uuid,
  DateTime? createdAt,
  int totalBites = 1,
}) {
  // Create the location point with required latitude and longitude
  final locationPoint = sdk.LocationPoint((p) => p
    ..latitude = 41.3874
    ..longitude = 2.1686);

  // Create the location with required source and point
  final location = sdk.Location((l) => l
    ..source_ = sdk.LocationSource_Enum.auto
    ..point.replace(locationPoint));

  return sdk.Bite((b) => b
    ..uuid = uuid
    ..shortId = uuid.length >= 8 ? uuid.substring(0, 8) : uuid
    ..userUuid = 'test-user-uuid'
    ..createdAt = createdAt ?? DateTime.now()
    ..createdAtLocal = createdAt ?? DateTime.now()
    ..sentAt = createdAt ?? DateTime.now()
    ..receivedAt = createdAt ?? DateTime.now()
    ..updatedAt = createdAt ?? DateTime.now()
    ..published = true
    ..location.replace(location)
    ..counts = sdk.BiteCounts((c) => c
      ..head = totalBites
      ..chest = 0
      ..leftArm = 0
      ..rightArm = 0
      ..leftLeg = 0
      ..rightLeg = 0
      ..total = totalBites).toBuilder());
}

void main() {
  group('ReportsListBites Tests', () {
    late MockMosquitoAlert mockClient;
    late MockBitesApi mockBitesApi;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      MockFirebaseAnalytics.setMockMethodCallHandler();
    });

    setUp(() {
      mockClient = MockMosquitoAlert();
      mockBitesApi = mockClient.bitesApi;
    });

    testWidgets('should display bite reports when bites are available',
        (WidgetTester tester) async {
      // Given - Mock bite reports with simple structure
      final testBites = [
        createSimpleBite(
          uuid: 'bite-1',
          createdAt: DateTime(2024, 9, 15, 10, 30),
          totalBites: 3,
        ),
        createSimpleBite(
          uuid: 'bite-2',
          createdAt: DateTime(2024, 9, 14, 15, 45),
          totalBites: 4,
        ),
      ];
      mockBitesApi.setBites(testBites);

      // When - Create widget
      await tester
          .pumpWidget(createReportsListBitesTestWidget(mockClient: mockClient));

      try {
        await tester.pumpAndSettle();
      } catch (e) {
        // Firebase exception is expected in test environment, continue with test
        print(
            "Expected Firebase exception: ${e.toString().substring(0, 100)}...");
      }

      // Then - Verify bite reports are displayed as cards
      expect(find.byType(Card), findsNWidgets(2));

      // Verify specific bite content is displayed
      expect(find.text('3 bites'), findsOneWidget);
      expect(find.text('4 bites'), findsOneWidget);
    });

    testWidgets('should display no reports message when no bites are available',
        (WidgetTester tester) async {
      // Given - Empty bite reports
      mockBitesApi.setBites([]);

      // When - Create widget
      final widget = createReportsListBitesTestWidget(mockClient: mockClient);
      await tester.pumpWidget(widget);

      try {
        await tester.pumpAndSettle();
      } catch (e) {
        // Firebase exception is expected in test environment, continue with test
        print(
            "Expected Firebase exception: ${e.toString().substring(0, 100)}...");
      }

      // Then - Verify empty state is displayed
      expect(find.byType(ReportsListBites), findsOneWidget);

      // No cards should be displayed
      expect(find.byType(Card), findsNothing);

      // Should display localized "no reports yet" message
      // Get the localized text from the mock localizations
      final mockLocalizations = MockMyLocalizations();
      final expectedText = mockLocalizations.translate('no_reports_yet_txt');
      expect(find.text(expectedText), findsOneWidget);
    });

    testWidgets('should display single bite correctly',
        (WidgetTester tester) async {
      // Given - Single bite with one bite count
      final testBites = [
        createSimpleBite(
          uuid: 'bite-single',
          createdAt: DateTime(2024, 9, 15, 10, 30),
          totalBites: 1,
        ),
      ];
      mockBitesApi.setBites(testBites);

      // When - Create widget
      await tester
          .pumpWidget(createReportsListBitesTestWidget(mockClient: mockClient));

      try {
        await tester.pumpAndSettle();
      } catch (e) {
        // Firebase exception is expected in test environment, continue with test
        print(
            "Expected Firebase exception: ${e.toString().substring(0, 100)}...");
      }

      // Then - Verify single bite is displayed correctly
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('1 bite'), findsOneWidget);
    });
  });
}
