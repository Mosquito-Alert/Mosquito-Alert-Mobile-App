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
      app.main(env: "dev");
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

      final continueButton = find.byKey(ValueKey(
          "button")); // TODO: Using Style.button prevents adding a Key to only this element
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // TODO: Mock needed to set the location as always allowed?
      // Home page
      final homePageButtons = find.byType(CustomCard);
      expect(homePageButtons, findsNWidgets(4));
      await tester.tap(homePageButtons.at(0));
      await tester.pumpAndSettle();

      expect(true, true);
    });
  });
}
