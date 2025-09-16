import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../mocks/mocks.dart';

void main() {
  group('TestMyLocalizations', () {
    test('should return translation keys to eliminate duplication', () {
      // Given
      final localizations = TestMyLocalizations();

      // When & Then - Translation keys are returned as-is
      expect(localizations.translate('notifications_title'), equals('notifications_title'));
      expect(localizations.translate('no_notifications_yet_txt'), equals('no_notifications_yet_txt'));
      expect(localizations.translate('single_bite'), equals('single_bite'));
      expect(localizations.translate('continue_txt'), equals('continue_txt'));
      
      // This approach eliminates duplication because:
      // - No need to maintain hardcoded translations in test mocks
      // - Tests can assert against keys instead of translated text
      // - Changes to translation files won't break tests
    });

    test('should handle null and empty keys gracefully', () {
      // Given
      final localizations = TestMyLocalizations();

      // When & Then
      expect(localizations.translate(null), equals(''));
      expect(localizations.translate(''), equals(''));
    });

    test('should return any key as-is without modification', () {
      // Given
      final localizations = TestMyLocalizations();

      // When & Then - Any key is returned unchanged
      expect(localizations.translate('unknown_key'), equals('unknown_key'));
      expect(localizations.translate('any.key.format'), equals('any.key.format'));
    });

    testWidgets('should work with TestMyLocalizationsDelegate in widget tests', 
        (WidgetTester tester) async {
      // Given - A widget that uses localization
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            TestMyLocalizationsDelegate(),
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) {
              // When - Using localization in widget
              final localizedText = Localizations.of<TestMyLocalizations>(
                context, 
                TestMyLocalizations
              )!.translate('test_key');
              
              return Text(localizedText);
            },
          ),
        ),
      );

      // Then - The key itself should be displayed
      expect(find.text('test_key'), findsOneWidget);
    });
  });

  group('Benefits of this approach', () {
    test('demonstrates elimination of duplication', () {
      // Before: MockMyLocalizations had hardcoded translations like:
      // case 'notifications_title': return 'Notifications';
      // case 'single_bite': return 'Report Bite';
      // 
      // This created duplication with assets/language/en_US.json
      
      // After: TestMyLocalizations returns keys directly
      final localizations = TestMyLocalizations();
      
      // Tests can now assert against keys instead of translated text
      expect(localizations.translate('any_key'), equals('any_key'));
      
      // This means:
      // - No duplicate translation maintenance
      // - Tests won't break when translations change
      // - More maintainable test code
    });
  });
}