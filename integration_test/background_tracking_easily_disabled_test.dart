import 'package:flutter_test/flutter_test.dart';
import 'package:mosquito_alert_app/main.dart' as app;
import 'package:mosquito_alert_app/pages/main/components/custom_card_widget.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'Test background tracking can be easily disabled on first use, to satisfy Google/Apple requirements',
    framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
    ($) async {
      // Initialize the app for testing
      app.main(env: "test");
      await $.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));

      // New user is created: Show consent form
      await $('acceptConditionsCheckbox').waitUntilVisible();
      await $('acceptConditionsCheckbox').tap();

      await $('acceptPrivacyPolicy').waitUntilVisible();
      await $('acceptPrivacyPolicy').tap();

      await $('style.button').waitUntilVisible();
      await $('style.button').tap();

      // Handle any permission dialogs that might appear
      if (await $.native.isPermissionDialogVisible()) {
        await $.native.denyPermission();
      }

      // Reject background tracking
      await $('rejectBackgroundTrackingBtn').waitUntilVisible();
      expect($('rejectBackgroundTrackingBtn'), findsOne);
      await $('rejectBackgroundTrackingBtn').tap();

      // Handle any additional permission dialogs for location services
      if (await $.native.isPermissionDialogVisible()) {
        await $.native.denyPermission();
      }

      // Home page - wait for the custom cards to appear
      await $.pumpAndSettle();

      // Wait for CustomCard widgets to appear
      await $('CustomCard').waitUntilVisible();

      // Verify we have 4 cards
      final homePageButtons = find.byType(CustomCard);
      expect(homePageButtons, findsNWidgets(4));
    },
  );
}
