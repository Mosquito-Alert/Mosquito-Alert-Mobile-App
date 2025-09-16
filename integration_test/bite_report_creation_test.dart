import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mosquito_alert_app/main.dart' as app;
import 'package:mosquito_alert_app/pages/main/components/custom_card_widget.dart';
import 'package:mosquito_alert_app/pages/forms_pages/biting_report_page.dart';
import 'package:provider/provider.dart';
import 'package:mosquito_alert/mosquito_alert.dart';

// Test helpers
import '../test/mocks/mocks.dart';
import '../test/mocks/test_app.dart';

Future<void> waitForWidget(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump();
    if (finder.evaluate().isNotEmpty) return;
    await Future.delayed(const Duration(milliseconds: 100));
  }
  throw Exception('Widget not found: $finder');
}

Future<void> waitForWidgetToDisappear(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump();
    if (finder.evaluate().isEmpty) return;
    await Future.delayed(const Duration(milliseconds: 100));
  }
  throw Exception('Widget did not disappear: $finder');
}

/// Helper to handle consent flow if present
Future<void> handleConsentFlow(WidgetTester tester) async {
  final acceptConditionsCheckbox = find.byKey(ValueKey("acceptConditionsCheckbox"));
  if (acceptConditionsCheckbox.evaluate().isNotEmpty) {
    await waitForWidget(tester, acceptConditionsCheckbox);
    await tester.ensureVisible(acceptConditionsCheckbox);
    await tester.tap(acceptConditionsCheckbox);

    final acceptPrivacyPolicy = find.byKey(ValueKey("acceptPrivacyPolicy"));
    await waitForWidget(tester, acceptPrivacyPolicy);
    await tester.ensureVisible(acceptPrivacyPolicy);
    await tester.tap(acceptPrivacyPolicy);

    final continueButton = find.byKey(ValueKey("style.button"));
    await waitForWidget(tester, continueButton);
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);

    // Handle background tracking dialog
    await tester.pumpAndSettle(Duration(seconds: 1));
    final rejectBtn = find.byKey(Key("rejectBackgroundTrackingBtn"));
    if (rejectBtn.evaluate().isNotEmpty) {
      await tester.ensureVisible(rejectBtn);
      await tester.tap(rejectBtn);
    }
  }
}

/// Helper to navigate through bite report questions
Future<void> fillBiteReportQuestions(WidgetTester tester) async {
  // Step 1: Add number of bites
  final addBiteButton = find.text('+');
  await waitForWidget(tester, addBiteButton);
  await tester.tap(addBiteButton);
  await tester.pumpAndSettle(Duration(milliseconds: 500));

  // Step 2: Select body part by tapping on body diagram
  final bodyImage = find.byType(Image).first;
  await waitForWidget(tester, bodyImage);
  await tester.tap(bodyImage);
  await tester.pumpAndSettle(Duration(milliseconds: 500));

  // Continue to location step
  final continueBtn1 = find.text('Continue');
  await waitForWidget(tester, continueBtn1);
  await tester.tap(continueBtn1);
  await tester.pumpAndSettle(Duration(seconds: 2));
}

/// Helper to handle location form
Future<void> handleLocationForm(WidgetTester tester) async {
  // Wait for location to be processed automatically with our GPS mock
  await tester.pumpAndSettle(Duration(seconds: 3));

  // Look for current location option and tap it if available
  final currentLocationOption = find.textContaining('Current');
  if (currentLocationOption.evaluate().isNotEmpty) {
    await tester.tap(currentLocationOption.first);
    await tester.pumpAndSettle(Duration(seconds: 1));
  }

  // Continue to next step
  final continueBtn = find.text('Continue');
  await waitForWidget(tester, continueBtn);
  await tester.tap(continueBtn);
  await tester.pumpAndSettle(Duration(seconds: 1));
}

/// Helper to answer additional questions in the bite report flow
Future<void> answerAdditionalQuestions(WidgetTester tester) async {
  // Look for question options and select the first available one
  var attempts = 0;
  const maxAttempts = 3; // Limit attempts to avoid infinite loops

  while (attempts < maxAttempts) {
    final questionOptions = find.byType(GestureDetector);
    if (questionOptions.evaluate().isNotEmpty) {
      // Tap the first question option
      await tester.tap(questionOptions.first);
      await tester.pumpAndSettle(Duration(milliseconds: 500));

      // Look for continue button
      final continueBtn = find.text('Continue');
      if (continueBtn.evaluate().isNotEmpty) {
        await tester.tap(continueBtn);
        await tester.pumpAndSettle(Duration(seconds: 1));
        attempts++;
      } else {
        break; // No more continue buttons, we're done
      }
    } else {
      break; // No more question options
    }
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  // Setup location mocking for GPS coordinates (0, 0)
  setUpAll(() async {
    // Mock Geolocator for consistent location
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/geolocator'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getCurrentPosition') {
          return {
            'latitude': 0.0,
            'longitude': 0.0,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'accuracy': 5.0,
            'altitude': 0.0,
            'heading': 0.0,
            'speed': 0.0,
            'speed_accuracy': 0.0,
          };
        }
        if (methodCall.method == 'isLocationServiceEnabled') {
          return true;
        }
        if (methodCall.method == 'checkPermission') {
          return 3; // LocationPermission.whileInUse
        }
        if (methodCall.method == 'requestPermission') {
          return 3; // LocationPermission.whileInUse
        }
        return null;
      },
    );

    // Mock permission handler
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/permission_handler'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'requestPermissions') {
          return {14: 1}; // PermissionStatus.granted for location
        }
        if (methodCall.method == 'checkPermissionStatus') {
          return 1; // PermissionStatus.granted
        }
        return null;
      },
    );
  });

  group('Bite Report Integration Test', () {
    testWidgets(
        'User can create a bite report successfully and bitesApi.create is called',
        (tester) async {
      
      // Initialize the test app with mocks
      final testApp = await initializeTestApp();
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Handle consent form if present
      await handleConsentFlow(tester);

      // Home page - verify we have the custom cards
      final homePageButtons = find.byType(CustomCard);
      await waitForWidget(tester, homePageButtons);
      expect(homePageButtons, findsNWidgets(4));

      // Get reference to the mock API for later verification
      final context = tester.element(find.byType(MaterialApp));
      final mockMosquitoAlert = Provider.of<MosquitoAlert>(context, listen: false) as MockMosquitoAlert;

      // Verify mock API is not called yet
      expect(mockMosquitoAlert.bitesApi.createCalled, isFalse,
          reason: 'bitesApi.create should not be called initially');

      // Find the bite report card (second card - index 1)
      // Based on home_page.dart order: adult, bite, site, public_map
      final biteReportCard = homePageButtons.at(1);
      await waitForWidget(tester, biteReportCard);
      await tester.ensureVisible(biteReportCard);
      await tester.tap(biteReportCard);

      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify we're in the BitingReportPage
      expect(find.byType(BitingReportPage), findsOne);

      // Fill out the bite report questions
      await fillBiteReportQuestions(tester);

      // Handle location form with GPS coordinates (0, 0)
      await handleLocationForm(tester);

      // Answer any additional questions
      await answerAdditionalQuestions(tester);

      // Final step - Submit the report
      final sendReportButton = find.text('Send Report');
      await waitForWidget(tester, sendReportButton, timeout: Duration(seconds: 10));
      await tester.tap(sendReportButton);
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Verify that the mock API was called
      expect(mockMosquitoAlert.bitesApi.createCalled, isTrue,
          reason: 'bitesApi.create should have been called');
      expect(mockMosquitoAlert.bitesApi.lastBiteRequest, isNotNull,
          reason: 'A bite request should have been sent');
      
      // Verify the bite request has expected location (0, 0)
      final request = mockMosquitoAlert.bitesApi.lastBiteRequest!;
      expect(request.location.point.latitude, equals(0.0),
          reason: 'GPS latitude should be 0.0 as mocked');
      expect(request.location.point.longitude, equals(0.0),
          reason: 'GPS longitude should be 0.0 as mocked');

      // Verify success by looking for success message or return to home
      final successMessage = find.textContaining('success').or(find.textContaining('saved'));
      
      // Wait for either success message or return to home
      try {
        await waitForWidget(tester, successMessage, timeout: Duration(seconds: 5));
        print('✅ Success message found');
      } catch (e) {
        // If no success message, check if we're back at home (which indicates successful submission)
        await waitForWidget(tester, find.byType(CustomCard), timeout: Duration(seconds: 5));
        print('✅ Returned to home page after submission');
      }

      // Test passed - verify all expectations
      print('🎯 Test Results:');
      print('   📍 Location sent to API: (${request.location.point.latitude}, ${request.location.point.longitude})');
      print('   📊 Bite count: ${request.counts?.head ?? 0 + request.counts?.leftArm ?? 0 + request.counts?.rightArm ?? 0}');
      print('   📅 Created at: ${request.createdAt}');
      print('   ✅ Bite report creation test completed successfully');
    });
  });
}