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

      // Since we're using the test app, we might start directly at home
      // or need to handle the consent flow depending on how it's set up
      
      // Look for consent form or home page
      final acceptConditionsCheckbox = find.byKey(ValueKey("acceptConditionsCheckbox"));
      if (acceptConditionsCheckbox.evaluate().isNotEmpty) {
        // Handle consent form if present
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

      // Home page - verify we have the custom cards
      final homePageButtons = find.byType(CustomCard);
      await waitForWidget(tester, homePageButtons);
      expect(homePageButtons, findsNWidgets(4));

      // Get reference to the mock API for later verification
      final context = tester.element(find.byType(MaterialApp));
      final mockMosquitoAlert = Provider.of<MosquitoAlert>(context, listen: false) as MockMosquitoAlert;

      // Find the bite report card by looking for the second card (index 1)
      // Based on home_page.dart order: adult, bite, site, public_map
      final biteReportCard = homePageButtons.at(1); // Second card (index 1) is the bite report
      await waitForWidget(tester, biteReportCard);
      await tester.ensureVisible(biteReportCard);
      await tester.tap(biteReportCard);

      await tester.pumpAndSettle(Duration(seconds: 2));

      // Now we should be in the BitingReportPage
      expect(find.byType(BitingReportPage), findsOne);

      // Step 1: Number of bites - Add at least one bite
      final addBiteButton = find.text('+');
      await waitForWidget(tester, addBiteButton);
      await tester.tap(addBiteButton);
      await tester.pumpAndSettle(Duration(milliseconds: 500));

      // Step 2: Body part selection - tap on the body diagram area
      // Since the body diagram is image-based, we'll tap in the general center area
      final bodyImage = find.byType(Image).first;
      await waitForWidget(tester, bodyImage);
      await tester.tap(bodyImage);
      await tester.pumpAndSettle(Duration(milliseconds: 500));

      // Continue to location step
      final continueBtn1 = find.text('Continue');
      await waitForWidget(tester, continueBtn1);
      await tester.tap(continueBtn1);
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Step 3: Location form - automatically uses current location with our mock
      // The location form should automatically get GPS location (0,0) from our mock
      // Wait for location to be processed
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Look for current location option and tap it if available
      final currentLocationOption = find.textContaining('Current');
      if (currentLocationOption.evaluate().isNotEmpty) {
        await tester.tap(currentLocationOption.first);
        await tester.pumpAndSettle(Duration(seconds: 1));
      }

      // Continue to next step
      final continueBtn2 = find.text('Continue');
      await waitForWidget(tester, continueBtn2);
      await tester.tap(continueBtn2);
      await tester.pumpAndSettle(Duration(seconds: 1));

      // Additional question steps - answer them to proceed
      // Look for any question options and select the first available one
      final questionOptions = find.byType(GestureDetector);
      if (questionOptions.evaluate().isNotEmpty) {
        // Tap the first question option
        await tester.tap(questionOptions.first);
        await tester.pumpAndSettle(Duration(milliseconds: 500));

        // Continue if there's a continue button
        final continueBtn3 = find.text('Continue');
        if (continueBtn3.evaluate().isNotEmpty) {
          await tester.tap(continueBtn3);
          await tester.pumpAndSettle(Duration(seconds: 1));
        }
      }

      // Look for more question steps
      final moreQuestionOptions = find.byType(GestureDetector);
      if (moreQuestionOptions.evaluate().isNotEmpty) {
        await tester.tap(moreQuestionOptions.first);
        await tester.pumpAndSettle(Duration(milliseconds: 500));

        final continueBtn4 = find.text('Continue');
        if (continueBtn4.evaluate().isNotEmpty) {
          await tester.tap(continueBtn4);
          await tester.pumpAndSettle(Duration(seconds: 1));
        }
      }

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
      expect(request.location.point.latitude, equals(0.0));
      expect(request.location.point.longitude, equals(0.0));

      // Verify success by looking for success message or return to home
      final successMessage = find.textContaining('success').or(find.textContaining('saved'));
      
      // Wait for either success message or return to home
      try {
        await waitForWidget(tester, successMessage, timeout: Duration(seconds: 5));
      } catch (e) {
        // If no success message, check if we're back at home (which indicates successful submission)
        await waitForWidget(tester, find.byType(CustomCard), timeout: Duration(seconds: 5));
      }

      // Test passed - the API was called with the expected location
      print('✅ Bite report creation test completed successfully');
      print('📍 Location sent to API: (${request.location.point.latitude}, ${request.location.point.longitude})');
    });
  });
}