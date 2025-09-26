import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosquito_alert_app/pages/reports/shared/utils/report_dialogs.dart';

void main() {
  group('ReportDialogs showSuccessDialog', () {
    testWidgets('should show success dialog with correct content', (WidgetTester tester) async {
      // Build a test app with MaterialApp wrapper
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  ReportDialogs.showSuccessDialog(context);
                },
                child: Text('Show Dialog'),
              ),
            );
          },
        ),
      ));

      // Tap the button to show dialog
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.byType(AlertDialog), findsOneWidget);
      
      // Verify dialog is not dismissible (barrierDismissible: false)
      await tester.tapAt(const Offset(10, 10)); // Tap outside dialog
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget); // Dialog should still be present
      
      // Verify OK button exists
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should dismiss dialog and navigate when OK pressed', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Navigator(
          onGenerateRoute: (RouteSettings settings) {
            if (settings.name == '/') {
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (BuildContext context) => Scaffold(
                  body: Builder(
                    builder: (BuildContext context) {
                      return ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => Scaffold(
                                body: ElevatedButton(
                                  onPressed: () {
                                    ReportDialogs.showSuccessDialog(context);
                                  },
                                  child: Text('Show Dialog'),
                                ),
                              ),
                            ),
                          );
                        },
                        child: Text('Navigate'),
                      );
                    },
                  ),
                ),
              );
            }
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (context) => Container(),
            );
          },
        ),
      ));

      // Navigate to second page first
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Tap OK button
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // Verify dialog is dismissed and we're back at root
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Navigate'), findsOneWidget); // Should be back at root
    });
  });
}