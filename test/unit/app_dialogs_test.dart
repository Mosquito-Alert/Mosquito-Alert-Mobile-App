import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosquito_alert_app/utils/app_dialogs.dart';

import '../mocks/mocks.dart';

Widget createAppDialogsTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
    localizationsDelegates: const [
      MockMyLocalizationsDelegate(),
    ],
    supportedLocales: const [Locale('en')],
  );
}

void main() {
  group('AppDialogs Tests', () {
    testWidgets('showAlert displays AlertDialog on Android',
        (WidgetTester tester) async {
      // Given - A test widget with a button that shows an alert
      bool wasPressed = false;
      final testWidget = Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () {
              AppDialogs.showAlert(
                context,
                title: 'Test Title',
                message: 'Test Message',
                onPressed: () => wasPressed = true,
              );
            },
            child: const Text('Show Alert'),
          );
        },
      );

      // When - Render the widget
      await tester.pumpWidget(createAppDialogsTestWidget(testWidget));

      // Tap the button to show the alert
      await tester.tap(find.text('Show Alert'));
      await tester.pumpAndSettle();

      // Then - Verify the dialog is displayed
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Message'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      // Tap OK button
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(wasPressed, isTrue);
    });

    testWidgets('showAlert can be dismissed by tapping OK',
        (WidgetTester tester) async {
      // Given - A test widget with a button that shows an alert
      final testWidget = Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () {
              AppDialogs.showAlert(
                context,
                title: 'Test Title',
                message: 'Test Message',
              );
            },
            child: const Text('Show Alert'),
          );
        },
      );

      // When - Render the widget and show alert
      await tester.pumpWidget(createAppDialogsTestWidget(testWidget));
      await tester.tap(find.text('Show Alert'));
      await tester.pumpAndSettle();

      // Dialog should be visible
      expect(find.text('Test Title'), findsOneWidget);

      // Tap OK button to dismiss
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Then - Dialog should be dismissed
      expect(find.text('Test Title'), findsNothing);
    });

    testWidgets('showConfirmation displays dialog with Yes/No buttons',
        (WidgetTester tester) async {
      // Given - A test widget with a button that shows a confirmation dialog
      bool yesPressed = false;
      bool noPressed = false;
      final testWidget = Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () {
              AppDialogs.showConfirmation(
                context,
                title: 'Confirm Action',
                message: 'Are you sure?',
                onYesPressed: () => yesPressed = true,
                onNoPressed: () => noPressed = true,
              );
            },
            child: const Text('Show Confirmation'),
          );
        },
      );

      // When - Render the widget and show confirmation
      await tester.pumpWidget(createAppDialogsTestWidget(testWidget));
      await tester.tap(find.text('Show Confirmation'));
      await tester.pumpAndSettle();

      // Then - Verify the dialog is displayed
      expect(find.text('Confirm Action'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
    });

    testWidgets('showConfirmation calls onYesPressed when Yes is tapped',
        (WidgetTester tester) async {
      // Given - A test widget with a confirmation dialog
      bool yesPressed = false;
      final testWidget = Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () {
              AppDialogs.showConfirmation(
                context,
                title: 'Confirm Action',
                message: 'Are you sure?',
                onYesPressed: () => yesPressed = true,
              );
            },
            child: const Text('Show Confirmation'),
          );
        },
      );

      // When - Render the widget, show dialog, and tap Yes
      await tester.pumpWidget(createAppDialogsTestWidget(testWidget));
      await tester.tap(find.text('Show Confirmation'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      // Then - Verify callback was called and dialog dismissed
      expect(yesPressed, isTrue);
      expect(find.text('Confirm Action'), findsNothing);
    });

    testWidgets('showConfirmation calls onNoPressed when No is tapped',
        (WidgetTester tester) async {
      // Given - A test widget with a confirmation dialog
      bool noPressed = false;
      final testWidget = Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () {
              AppDialogs.showConfirmation(
                context,
                title: 'Confirm Action',
                message: 'Are you sure?',
                onYesPressed: () {},
                onNoPressed: () => noPressed = true,
              );
            },
            child: const Text('Show Confirmation'),
          );
        },
      );

      // When - Render the widget, show dialog, and tap No
      await tester.pumpWidget(createAppDialogsTestWidget(testWidget));
      await tester.tap(find.text('Show Confirmation'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      // Then - Verify callback was called and dialog dismissed
      expect(noPressed, isTrue);
      expect(find.text('Confirm Action'), findsNothing);
    });

    testWidgets('showConfirmation dismisses dialog when No is tapped without callback',
        (WidgetTester tester) async {
      // Given - A test widget with a confirmation dialog without onNoPressed
      final testWidget = Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () {
              AppDialogs.showConfirmation(
                context,
                title: 'Confirm Action',
                message: 'Are you sure?',
                onYesPressed: () {},
              );
            },
            child: const Text('Show Confirmation'),
          );
        },
      );

      // When - Render the widget, show dialog, and tap No
      await tester.pumpWidget(createAppDialogsTestWidget(testWidget));
      await tester.tap(find.text('Show Confirmation'));
      await tester.pumpAndSettle();

      // Dialog should be visible
      expect(find.text('Confirm Action'), findsOneWidget);

      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      // Then - Dialog should be dismissed
      expect(find.text('Confirm Action'), findsNothing);
    });
  });
}
