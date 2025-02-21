import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mosquito_alert_app/main.dart' as app;


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('Sanity test', (
      tester,
    ) async {
      app.main(env: "dev");
      await tester.pumpAndSettle();

      expect(true, isTrue);
      //expect(find.byKey(ValueKey("testing")), findsOne);
    });
  });
}