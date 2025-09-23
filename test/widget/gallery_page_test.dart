import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:mosquito_alert_app/pages/settings_pages/gallery_page.dart';

// Import shared mocks
import '../mocks/mocks.dart';

/// Creates a test widget wrapping GalleryPage with required dependencies
Widget createTestWidget({
  Function? goBackToHomepage,
}) {
  bool callbackInvoked = false;
  int callbackArgument = -1;

  return MaterialApp(
    home: GalleryPage(
      goBackToHomepage: goBackToHomepage ?? (int index) {
        callbackInvoked = true;
        callbackArgument = index;
      },
    ),
    localizationsDelegates: const [
      MockMyLocalizationsDelegate(),
    ],
    supportedLocales: const [Locale('en')],
  );
}

void main() {
  group('GalleryPage Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      MockFirebaseAnalytics.setMockMethodCallHandler();
    });

    testWidgets('should render GalleryPage with IntroSlider and 9 slides', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Then
      expect(find.byType(GalleryPage), findsOneWidget);
      expect(find.byType(IntroSlider), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      
      // Verify the slider has 9 slides by checking for slide indicator dots
      // IntroSlider creates dots for each slide
      final introSlider = tester.widget<IntroSlider>(find.byType(IntroSlider));
      expect(introSlider.slides.length, equals(9));
    });

    testWidgets('should display first slide content initially', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Then - Check if first slide content is visible
      // Look for the text content of the first slide
      expect(find.textContaining('Welcome to the Mosquito Guide - Slide 1'), findsOneWidget);
    });

    testWidgets('should navigate forward through slides using next button', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially on slide 1
      expect(find.textContaining('Welcome to the Mosquito Guide - Slide 1'), findsOneWidget);

      // When - Tap next button (navigate_next icon)
      final nextButton = find.byIcon(Icons.navigate_next);
      expect(nextButton, findsOneWidget);
      
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Then - Should be on slide 2
      expect(find.textContaining('Mosquito Identification - Slide 2'), findsOneWidget);
      expect(find.textContaining('Welcome to the Mosquito Guide - Slide 1'), findsNothing);
    });

    testWidgets('should navigate through multiple slides sequentially', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final nextButton = find.byIcon(Icons.navigate_next);
      
      // Navigate through slides 1-5
      for (int i = 1; i < 5; i++) {
        // Current slide should be visible
        expect(find.textContaining('Slide $i'), findsOneWidget);
        
        // When - Go to next slide
        await tester.tap(nextButton);
        await tester.pumpAndSettle();
        
        // Then - Next slide should be visible
        expect(find.textContaining('Slide ${i + 1}'), findsOneWidget);
        expect(find.textContaining('Slide $i'), findsNothing);
      }
    });

    testWidgets('should navigate backward using previous button', (WidgetTester tester) async {
      // Given - Navigate to slide 3 first
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final nextButton = find.byIcon(Icons.navigate_next);
      
      // Go to slide 3
      await tester.tap(nextButton); // to slide 2
      await tester.pumpAndSettle();
      await tester.tap(nextButton); // to slide 3
      await tester.pumpAndSettle();
      
      expect(find.textContaining('Breeding Sites - Slide 3'), findsOneWidget);

      // When - Find and tap previous button (should be part of IntroSlider's navigation)
      // IntroSlider should show previous button when not on first slide
      // Look for any button that might be previous - IntroSlider typically shows left arrow or back navigation
      final introSlider = find.byType(IntroSlider);
      expect(introSlider, findsOneWidget);
      
      // Use gesture to simulate swipe back or find prev button
      // IntroSlider typically has navigation via gestures or buttons
      await tester.drag(find.byType(IntroSlider), const Offset(300, 0)); // Swipe right to go back
      await tester.pumpAndSettle();

      // Then - Should be back to slide 2
      expect(find.textContaining('Mosquito Identification - Slide 2'), findsOneWidget);
      expect(find.textContaining('Breeding Sites - Slide 3'), findsNothing);
    });

    testWidgets('should show done button on last slide', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final nextButton = find.byIcon(Icons.navigate_next);
      
      // Navigate to last slide (slide 9)
      for (int i = 0; i < 8; i++) {
        await tester.tap(nextButton);
        await tester.pumpAndSettle();
      }
      
      // Then - Should be on slide 9 and show done button
      expect(find.textContaining('Thank You - Slide 9'), findsOneWidget);
      expect(find.byIcon(Icons.done), findsOneWidget);
    });

    testWidgets('should call goBackToHomepage when done button is pressed', (WidgetTester tester) async {
      // Given
      bool callbackInvoked = false;
      int callbackArgument = -1;
      
      await tester.pumpWidget(createTestWidget(
        goBackToHomepage: (int index) {
          callbackInvoked = true;
          callbackArgument = index;
        },
      ));
      await tester.pumpAndSettle();

      final nextButton = find.byIcon(Icons.navigate_next);
      
      // Navigate to last slide
      for (int i = 0; i < 8; i++) {
        await tester.tap(nextButton);
        await tester.pumpAndSettle();
      }

      // When - Tap done button
      final doneButton = find.byIcon(Icons.done);
      expect(doneButton, findsOneWidget);
      
      await tester.tap(doneButton);
      await tester.pumpAndSettle();

      // Then - Callback should be invoked with argument 0 (homepage index)
      expect(callbackInvoked, isTrue);
      expect(callbackArgument, equals(0));
    });

    testWidgets('should handle navigation limits correctly', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Test backward navigation from first slide (should not crash)
      await tester.drag(find.byType(IntroSlider), const Offset(300, 0)); // Try to swipe back from slide 1
      await tester.pumpAndSettle();
      
      // Should still be on slide 1
      expect(find.textContaining('Welcome to the Mosquito Guide - Slide 1'), findsOneWidget);

      // Navigate to last slide
      final nextButton = find.byIcon(Icons.navigate_next);
      for (int i = 0; i < 8; i++) {
        await tester.tap(nextButton);
        await tester.pumpAndSettle();
      }
      
      // Try to navigate forward from last slide (should show done button, not next)
      expect(find.textContaining('Thank You - Slide 9'), findsOneWidget);
      expect(find.byIcon(Icons.done), findsOneWidget);
      expect(find.byIcon(Icons.navigate_next), findsNothing); // Next button should not be visible on last slide
    });

    testWidgets('should display proper slide indicators', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Then - IntroSlider should show slide indicators (dots)
      // The exact implementation depends on IntroSlider's internal structure
      // but we can verify the slider configuration
      final introSlider = tester.widget<IntroSlider>(find.byType(IntroSlider));
      
      // Verify slider configuration
      expect(introSlider.showSkipBtn, equals(false));
      expect(introSlider.sizeDot, equals(6.0));
      expect(introSlider.backgroundColorAllSlides, equals(Colors.white));
      expect(introSlider.hideStatusBar, equals(false));
    });

    testWidgets('should render custom slide content with images and descriptions', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Then - Should find Image widgets for slide content
      // Note: In test environment, Image.asset might not load actual images
      // but the widget structure should be present
      expect(find.byType(Image), findsAtLeastNWidgets(1));
      
      // Should find HTML content containers for descriptions
      expect(find.textContaining('Welcome to the Mosquito Guide - Slide 1'), findsOneWidget);
    });

    testWidgets('should complete full navigation cycle', (WidgetTester tester) async {
      // Given
      bool callbackInvoked = false;
      int callbackArgument = -1;
      
      await tester.pumpWidget(createTestWidget(
        goBackToHomepage: (int index) {
          callbackInvoked = true;
          callbackArgument = index;
        },
      ));
      await tester.pumpAndSettle();

      // When - Navigate through entire guide
      final nextButton = find.byIcon(Icons.navigate_next);
      
      // Go through all slides
      for (int slideIndex = 1; slideIndex <= 8; slideIndex++) {
        expect(find.textContaining('Slide $slideIndex'), findsOneWidget);
        await tester.tap(nextButton);
        await tester.pumpAndSettle();
      }
      
      // Should be on final slide
      expect(find.textContaining('Thank You - Slide 9'), findsOneWidget);
      expect(find.byIcon(Icons.done), findsOneWidget);
      
      // Complete the guide
      await tester.tap(find.byIcon(Icons.done));
      await tester.pumpAndSettle();

      // Then - Should have called completion callback
      expect(callbackInvoked, isTrue);
      expect(callbackArgument, equals(0));
    });
  });
}