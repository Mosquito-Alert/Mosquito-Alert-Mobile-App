import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mosquito_alert_app/pages/forms_pages/biting_report_page.dart';
import 'package:mosquito_alert_app/pages/main/components/custom_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:mosquito_alert/mosquito_alert.dart';

// Test helpers
import '../test/mocks/mocks.dart';

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
  final acceptConditionsCheckbox =
      find.byKey(ValueKey("acceptConditionsCheckbox"));
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

/// Helper to fill out bite report questions with error handling
Future<void> fillBiteReportQuestions(WidgetTester tester) async {
  try {
    final addBiteButton = find.text('+');
    await waitForWidget(tester, addBiteButton);
    await tester.tap(addBiteButton);
    await tester.pumpAndSettle(Duration(milliseconds: 500));

    // Step 2: Select body part by tapping on body diagram
    final bodyImages = find.byType(Image);
    if (bodyImages.evaluate().isNotEmpty) {
      await tester.tap(bodyImages.first);
      await tester.pumpAndSettle(Duration(milliseconds: 500));
    }

    // Continue to location step
    final continueBtn1 = find.text('Continue');
    await waitForWidget(tester, continueBtn1);
    await tester.tap(continueBtn1);
    await tester.pumpAndSettle(Duration(seconds: 2));
  } catch (e) {
    print('Error in fillBiteReportQuestions: $e');
    rethrow;
  }
}

/// Helper to handle location form with better error handling
Future<void> handleLocationForm(WidgetTester tester) async {
  try {
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
  } catch (e) {
    print('Error in handleLocationForm: $e');
    rethrow;
  }
}

/// Helper to scroll and find the Send Report button
Future<void> scrollToAndTapSendReport(WidgetTester tester) async {
  final sendReportButton = find.text('Send Report');
  
  // First try to find without scrolling
  if (sendReportButton.evaluate().isNotEmpty) {
    await tester.tap(sendReportButton);
    return;
  }
  
  // If not found, scroll down to find it
  final scrollableFinder = find.byType(Scrollable);
  if (scrollableFinder.evaluate().isNotEmpty) {
    // Scroll down in small increments to find the button
    for (int i = 0; i < 5; i++) {
      await tester.drag(scrollableFinder.first, Offset(0, -200));
      await tester.pumpAndSettle(Duration(milliseconds: 500));
      
      if (sendReportButton.evaluate().isNotEmpty) {
        await tester.ensureVisible(sendReportButton);
        await tester.tap(sendReportButton);
        return;
      }
    }
  }
  
  // If still not found, try scrolling the entire page
  await tester.drag(find.byType(BitingReportPage), Offset(0, -300));
  await tester.pumpAndSettle(Duration(seconds: 1));
  
  await waitForWidget(tester, sendReportButton, timeout: Duration(seconds: 5));
  await tester.ensureVisible(sendReportButton);
  await tester.tap(sendReportButton);
}

/// Helper to answer additional questions with better debugging
Future<void> answerAdditionalQuestions(WidgetTester tester) async {
  try {
    var attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      final questionOptions = find.byType(GestureDetector);
      if (questionOptions.evaluate().isNotEmpty) {
        await tester.tap(questionOptions.first);
        await tester.pumpAndSettle(Duration(milliseconds: 500));

        final continueBtn = find.text('Continue');
        if (continueBtn.evaluate().isNotEmpty) {
          await tester.tap(continueBtn);
          await tester.pumpAndSettle(Duration(seconds: 1));
          attempts++;
        } else {
          break;
        }
      } else {
        break;
      }
    }
  } catch (e) {
    print('Error in answerAdditionalQuestions: $e');
    // Don't rethrow here, as additional questions might be optional
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

    // Mock Firebase Analytics to prevent any analytics calls
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/firebase_analytics'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'logEvent') {
          return null; // Successfully logged (mocked)
        }
        return null;
      },
    );

    // Mock Firebase Core initialization
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/firebase_core'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'Firebase#initializeCore') {
          return null; // Successfully initialized (mocked)
        }
        if (methodCall.method == 'Firebase#initializeApp') {
          return null; // Successfully initialized (mocked)
        }
        return null;
      },
    );

    // Mock connectivity to prevent network status checks
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'check') {
          return 'wifi'; // Return wifi connectivity
        }
        return null;
      },
    );
  });

  group('Bite Report Integration Test', () {
    testWidgets(
        'User can create a bite report successfully and reach the API submission point',
        (tester) async {
      
      // Initialize the test app with mocks to prevent real API calls
      final testApp = await initializeTestApp();
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Get reference to the mock API for later verification
      final context = tester.element(find.byType(MaterialApp));
      final mockMosquitoAlert = Provider.of<MosquitoAlert>(context, listen: false) as MockMosquitoAlert;

      // Handle consent form if present
      await handleConsentFlow(tester);

      // Home page - find bite report card
      final homePageButtons = find.byType(CustomCard);
      await waitForWidget(tester, homePageButtons);
      expect(homePageButtons, findsAtLeastNWidgets(1));

      // Find the bite report card - try different approaches to locate it
      final biteReportCard = homePageButtons.at(1); // Second card should be bite report
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

      // Final step - Submit the report with scrolling support
      await scrollToAndTapSendReport(tester);
      await tester.pumpAndSettle(Duration(seconds: 5));

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

      // Verify that the flow completed successfully by:
      // 1. Looking for success message, OR
      // 2. Confirming we've returned to home page (indicating successful submission)
      
      // Try to find success/saved message first
      try {
        final successMessage = find.textContaining('success');
        await waitForWidget(tester, successMessage, timeout: Duration(seconds: 3));
        print('Success message found - bite report flow completed successfully');
      } catch (_) {
        try {
          final savedMessage = find.textContaining('saved');
          await waitForWidget(tester, savedMessage, timeout: Duration(seconds: 2));
          print('Saved message found - bite report flow completed successfully');
        } catch (_) {
          // If no success/saved message, check if we're back at home
          final homeCards = find.byType(CustomCard);
          await waitForWidget(tester, homeCards, timeout: Duration(seconds: 5));
          expect(homeCards, findsAtLeastNWidgets(1));
          print('Returned to home page - bite report flow completed successfully');
        }
      }

      // Test passed - we successfully navigated through the entire bite report flow
      print('Integration test completed successfully');
      print('GPS coordinates (0, 0) were used via location mocking');
      print('User completed entire bite report form flow');
      print('API call was successfully mocked and verified');
    });
  });
}
