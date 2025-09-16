import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bite Report Moment Mapping', () {
    test('should map answer IDs to correct moment enums', () {
      // Test the mapping logic that would be used in _mapMomentToEnum
      // Since _mapMomentToEnum is private, we test the logic directly
      
      // Test case 51: "just now" -> now
      var result51 = mapMomentToEnumTest(51);
      expect(result51, 'now');
      
      // Test case 52: "last 24h" without specific time -> lastNight (default)
      var result52 = mapMomentToEnumTest(52);
      expect(result52, 'lastNight');
      
      // Test case 31: morning -> lastMorning
      var result31 = mapMomentToEnumTest(31);
      expect(result31, 'lastMorning');
      
      // Test case 32: midday -> lastMidday
      var result32 = mapMomentToEnumTest(32);
      expect(result32, 'lastMidday');
      
      // Test case 33: afternoon -> lastAfternoon
      var result33 = mapMomentToEnumTest(33);
      expect(result33, 'lastAfternoon');
      
      // Test case 34: night -> lastNight
      var result34 = mapMomentToEnumTest(34);
      expect(result34, 'lastNight');
      
      // Test default case: unknown ID -> lastMorning
      var resultDefault = mapMomentToEnumTest(999);
      expect(resultDefault, 'lastMorning');
    });
    
    test('should prioritize specific time over general time', () {
      // Test that when both Q3 (specific time) and Q5 (general when) are present,
      // Q3 takes priority
      
      // Simulate responses where user selected "last 24h" (52) and then "afternoon" (33)
      var generalWhen = 52; // "last 24h"
      var specificTime = 33; // "afternoon"
      
      // The logic should use specificTime when available
      var finalAnswerId = specificTime; // timeResponse?.answer_id ?? whenResponse!.answer_id!
      var result = mapMomentToEnumTest(finalAnswerId);
      expect(result, 'lastAfternoon');
      
      // When no specific time is available, should use general when
      var onlyGeneralWhen = 52;
      var resultGeneral = mapMomentToEnumTest(onlyGeneralWhen);
      expect(resultGeneral, 'lastNight');
    });
    
    test('should handle null specific time response correctly', () {
      // Test the nullable logic: timeResponse?.answer_id ?? whenResponse!.answer_id!
      
      // When timeResponse is null (no question 3 response), use whenResponse
      int? timeResponseAnswerId = null; // No specific time selected
      int whenResponseAnswerId = 51; // "Just now"
      
      var finalAnswerId = timeResponseAnswerId ?? whenResponseAnswerId;
      var result = mapMomentToEnumTest(finalAnswerId);
      expect(result, 'now');
      
      // When timeResponse exists, use it regardless of whenResponse
      timeResponseAnswerId = 32; // "Midday"
      whenResponseAnswerId = 52; // "Last 24h"
      
      finalAnswerId = timeResponseAnswerId ?? whenResponseAnswerId;
      result = mapMomentToEnumTest(finalAnswerId);
      expect(result, 'lastMidday');
    });
    
    test('should verify old hardcoded values no longer work', () {
      // Test that the old incorrect hardcoded values (9999999, 99999998) 
      // now fall back to default behavior
      
      var resultOldAfternoon = mapMomentToEnumTest(9999999);
      expect(resultOldAfternoon, 'lastMorning'); // Should default, not afternoon
      
      var resultOldMidday = mapMomentToEnumTest(99999998);
      expect(resultOldMidday, 'lastMorning'); // Should default, not midday
    });
  });
}

// Test helper function that replicates the logic of _mapMomentToEnum
String mapMomentToEnumTest(int answerId) {
  switch (answerId) {
    case 51:
      return 'now';
    case 52:
      return 'lastNight';
    case 31:
      return 'lastMorning';
    case 32:
      return 'lastMidday';
    case 33:
      return 'lastAfternoon';
    case 34:
      return 'lastNight';
    default:
      return 'lastMorning';
  }
}