import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mosquito_alert_app/main.dart' as app;
import 'package:mosquito_alert_app/pages/main/components/custom_card_widget.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group('end-to-end test', () {
    testWidgets('Sanity test', (tester) async {
      app.main(env: "test");
      await tester.pumpAndSettle(Duration(seconds: 3));

      // New user is created: Show consent form
      final acceptConditionsCheckbox =
          find.byKey(ValueKey("acceptConditionsCheckbox"));
      await tester.ensureVisible(acceptConditionsCheckbox);
      await tester.tap(acceptConditionsCheckbox);

      final acceptPrivacyPolicy = find.byKey(ValueKey("acceptPrivacyPolicy"));
      await tester.ensureVisible(acceptPrivacyPolicy);
      await tester.tap(acceptPrivacyPolicy);

      await tester.pumpAndSettle();

      final continueButton = find.byKey(ValueKey("style.button"));
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // Reject background traking
      final rejectBtn = find.byKey(Key("reject_background_tracking"));
      await tester.ensureVisible(rejectBtn);
      await tester.tap(rejectBtn);
      await tester.pumpAndSettle();

      // Home page
      final homePageButtons = find.byType(CustomCard);
      expect(homePageButtons, findsNWidgets(4));
    });
  });
}
