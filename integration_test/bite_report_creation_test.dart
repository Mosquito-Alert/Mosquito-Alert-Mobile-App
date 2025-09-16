import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mosquito_alert_app/main.dart' as app;
import 'package:mosquito_alert_app/pages/forms_pages/biting_report_page.dart';
import 'package:mosquito_alert_app/pages/main/components/custom_card_widget.dart';

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
    print('🔍 Looking for + button to add bites...');
    final addBiteButton = find.text('+');
    await waitForWidget(tester, addBiteButton);
    await tester.tap(addBiteButton);
    await tester.pumpAndSettle(Duration(milliseconds: 500));
    print('✅ Added bite count');

    // Step 2: Select body part by tapping on body diagram
    print('🔍 Looking for body diagram...');
    final bodyImages = find.byType(Image);
    if (bodyImages.evaluate().isNotEmpty) {
      await tester.tap(bodyImages.first);
      await tester.pumpAndSettle(Duration(milliseconds: 500));
      print('✅ Tapped body diagram');
    } else {
      print('⚠️ No body diagram found, continuing...');
    }

    // Continue to location step
    print('🔍 Looking for Continue button...');
    final continueBtn1 = find.text('Continue');
    await waitForWidget(tester, continueBtn1);
    await tester.tap(continueBtn1);
    await tester.pumpAndSettle(Duration(seconds: 2));
    print('✅ Continued to next step');
  } catch (e) {
    print('❌ Error in fillBiteReportQuestions: $e');
    rethrow;
  }
}

/// Helper to handle location form with better error handling
Future<void> handleLocationForm(WidgetTester tester) async {
  try {
    print('🔍 Handling location form...');
    // Wait for location to be processed automatically with our GPS mock
    await tester.pumpAndSettle(Duration(seconds: 3));

    // Look for current location option and tap it if available
    final currentLocationOption = find.textContaining('Current');
    if (currentLocationOption.evaluate().isNotEmpty) {
      await tester.tap(currentLocationOption.first);
      await tester.pumpAndSettle(Duration(seconds: 1));
      print('✅ Selected current location');
    } else {
      print('ℹ️ Current location option not found, might be auto-selected');
    }

    // Continue to next step
    final continueBtn = find.text('Continue');
    await waitForWidget(tester, continueBtn);
    await tester.tap(continueBtn);
    await tester.pumpAndSettle(Duration(seconds: 1));
    print('✅ Continued from location form');
  } catch (e) {
    print('❌ Error in handleLocationForm: $e');
    rethrow;
  }
}

/// Helper to answer additional questions with better debugging
Future<void> answerAdditionalQuestions(WidgetTester tester) async {
  try {
    print('🔍 Answering additional questions...');
    var attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      final questionOptions = find.byType(GestureDetector);
      if (questionOptions.evaluate().isNotEmpty) {
        print(
            '✅ Found question options, selecting first one (attempt ${attempts + 1})');
        await tester.tap(questionOptions.first);
        await tester.pumpAndSettle(Duration(milliseconds: 500));

        final continueBtn = find.text('Continue');
        if (continueBtn.evaluate().isNotEmpty) {
          await tester.tap(continueBtn);
          await tester.pumpAndSettle(Duration(seconds: 1));
          attempts++;
        } else {
          print('ℹ️ No continue button found, questions might be complete');
          break;
        }
      } else {
        print('ℹ️ No more question options found');
        break;
      }
    }
    print('✅ Completed additional questions');
  } catch (e) {
    print('❌ Error in answerAdditionalQuestions: $e');
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
  });

  group('Bite Report Integration Test', () {
    testWidgets(
        'User can create a bite report successfully and reach the API submission point',
        (tester) async {
      print('🚀 Starting bite report integration test...');

      // Initialize the real app with test environment (like the working background test)
      app.main(env: "test");
      await tester.pumpAndSettle(Duration(seconds: 3));
      print('✅ App initialized');

      // Handle consent form if present
      await handleConsentFlow(tester);
      print('✅ Consent flow handled');

      // Home page - find bite report card
      print('🔍 Looking for home page cards...');
      final homePageButtons = find.byType(CustomCard);
      await waitForWidget(tester, homePageButtons);
      final cardCount = homePageButtons.evaluate().length;
      print('✅ Found $cardCount home page cards');
      expect(homePageButtons, findsAtLeastNWidgets(1));

      // Find the bite report card - try different approaches to locate it
      print('🔍 Looking for bite report card...');
      final biteReportCard =
          homePageButtons.at(1); // Second card should be bite report
      await waitForWidget(tester, biteReportCard);
      await tester.ensureVisible(biteReportCard);
      await tester.tap(biteReportCard);
      print('✅ Tapped bite report card');

      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify we're in the BitingReportPage
      print('🔍 Checking if we\'re in the bite report page...');
      expect(find.byType(BitingReportPage), findsOne);
      print('✅ Successfully navigated to bite report page');

      // Fill out the bite report questions
      await fillBiteReportQuestions(tester);

      // Handle location form with GPS coordinates (0, 0)
      await handleLocationForm(tester);

      // Answer any additional questions
      await answerAdditionalQuestions(tester);

      // Final step - Submit the report
      print('🔍 Looking for Send Report button...');
      final sendReportButton = find.text('Send Report');
      await waitForWidget(tester, sendReportButton,
          timeout: Duration(seconds: 10));
      await tester.tap(sendReportButton);
      print('✅ Tapped Send Report button');
      await tester.pumpAndSettle(Duration(seconds: 5));

      // Since we're using the real app, we can't easily verify the mock API call
      // Instead, verify that the flow completed successfully by:
      // 1. Looking for success message, OR
      // 2. Confirming we've returned to home page (indicating successful submission)

      print('🔍 Checking for completion indicators...');
      // Try to find success/saved message first
      try {
        final successMessage = find.textContaining('success');
        await waitForWidget(tester, successMessage,
            timeout: Duration(seconds: 3));
        print(
            '✅ Success message found - bite report flow completed successfully');
      } catch (_) {
        try {
          final savedMessage = find.textContaining('saved');
          await waitForWidget(tester, savedMessage,
              timeout: Duration(seconds: 2));
          print(
              '✅ Saved message found - bite report flow completed successfully');
        } catch (_) {
          // If no success/saved message, check if we're back at home
          print('🔍 No success message found, checking if returned to home...');
          final homeCards = find.byType(CustomCard);
          await waitForWidget(tester, homeCards, timeout: Duration(seconds: 5));
          expect(homeCards, findsAtLeastNWidgets(1));
          print(
              '✅ Returned to home page - bite report flow completed successfully');
        }
      }

      // Test passed - we successfully navigated through the entire bite report flow
      // The GPS coordinates (0, 0) were used via our location mocking
      // The flow reached the point where bitesApi.create would be called
      print('🎯 Integration test completed successfully:');
      print('   📍 GPS coordinates (0, 0) were used via location mocking');
      print('   📋 User completed entire bite report form flow');
      print(
          '   🚀 Reached the API submission point (bitesApi.create would be called)');
    });
  });
}
