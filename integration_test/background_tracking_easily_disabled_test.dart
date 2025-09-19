import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mosquito_alert_app/main.dart' as app;
import 'package:mosquito_alert_app/pages/main/components/custom_card_widget.dart';
import 'package:patrol/patrol.dart';

Future<void> waitForWidget(
  PatrolTester $,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await $.pump();
    if (finder.evaluate().isNotEmpty) return;
    await Future.delayed(const Duration(milliseconds: 100));
  }
  throw Exception('Widget not found: $finder');
}

void main() {
  patrolSetUp(() {
    // Initialize patrol configuration for handling permissions
  });

  group('end-to-end test', () {
    patrolTest(
        'Test background tracking can be easily disabled on first use, to satisfy Google/Apple requirements',
        ($) async {
      // Grant location permissions using patrol before any permission requests
      // This handles the system permission dialogs that would normally require manual interaction
      await $.native.grantPermissionWhenInUse();
      
      // Start the app with dev config instead of test config to enable auth and permissions
      app.main(env: "dev");
      await $.pumpAndSettle(Duration(seconds: 3));

      // New user is created: Show consent form
      final acceptConditionsCheckbox =
          find.byKey(ValueKey("acceptConditionsCheckbox"));
      await waitForWidget($, acceptConditionsCheckbox);
      await $.ensureVisible(acceptConditionsCheckbox);
      await $.tap(acceptConditionsCheckbox);

      final acceptPrivacyPolicy = find.byKey(ValueKey("acceptPrivacyPolicy"));
      await waitForWidget($, acceptPrivacyPolicy);
      await $.ensureVisible(acceptPrivacyPolicy);
      await $.tap(acceptPrivacyPolicy);

      final continueButton = find.byKey(ValueKey("style.button"));
      await waitForWidget($, continueButton);
      await $.ensureVisible(continueButton);
      await $.tap(continueButton);

      // Handle any potential location permission dialog that may appear
      // Patrol's native permission handling should automatically handle system dialogs
      await Future.delayed(Duration(seconds: 2));

      // Reject background tracking
      final rejectBtn = find.byKey(Key("rejectBackgroundTrackingBtn"));
      await waitForWidget($, rejectBtn);
      expect(rejectBtn, findsOne);
      await $.ensureVisible(rejectBtn);
      await $.tap(rejectBtn);

      // Home page should be displayed with the expected cards
      final homePageButtons = find.byType(CustomCard);
      await waitForWidget($, homePageButtons);
      expect(homePageButtons, findsNWidgets(4));
    });
  });
}
