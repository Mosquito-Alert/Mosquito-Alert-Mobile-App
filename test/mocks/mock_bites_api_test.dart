import 'package:flutter_test/flutter_test.dart';
import 'package:mosquito_alert/mosquito_alert.dart' as sdk;
import 'mock_bites_api.dart';

void main() {
  group('MockBitesApi', () {
    late MockBitesApi mockApi;

    setUp(() {
      mockApi = MockBitesApi();
    });

    test('should track create calls', () {
      expect(mockApi.createCalled, isFalse);
      expect(mockApi.lastBiteRequest, isNull);
    });

    test('should record create call with request data', () async {
      // Create a test bite request
      final location = sdk.LocationPoint((b) => b
        ..latitude = 0.0
        ..longitude = 0.0);

      final locationRequest = sdk.LocationRequest((b) => b
        ..source_ = sdk.LocationRequestSource_Enum.auto
        ..point.replace(location));

      final counts = sdk.BiteCountsRequest((b) => b
        ..head = 1
        ..leftArm = 0
        ..rightArm = 0
        ..chest = 0
        ..leftLeg = 0
        ..rightLeg = 0);

      final biteRequest = sdk.BiteRequest((b) => b
        ..createdAt = DateTime.now().toUtc()
        ..sentAt = DateTime.now().toUtc()
        ..location.replace(locationRequest)
        ..note = 'Test bite report'
        ..eventEnvironment = sdk.BiteRequestEventEnvironmentEnum.indoors
        ..eventMoment = sdk.BiteRequestEventMomentEnum.now
        ..counts.replace(counts));

      // Call create method
      final response = await mockApi.create(biteRequest: biteRequest);

      // Verify tracking
      expect(mockApi.createCalled, isTrue);
      expect(mockApi.lastBiteRequest, isNotNull);
      expect(mockApi.lastBiteRequest!.location.point.latitude, equals(0.0));
      expect(mockApi.lastBiteRequest!.location.point.longitude, equals(0.0));
      expect(mockApi.lastBiteRequest!.counts.head, equals(1));

      // Verify response
      expect(response.statusCode, equals(201));
      expect(response.data, isNotNull);
      expect(response.data!.uuid, equals('test-uuid-123'));
    });

    test('should simulate failure when shouldFail is true', () async {
      mockApi.shouldFail = true;

      final location = sdk.LocationPoint((b) => b
        ..latitude = 0.0
        ..longitude = 0.0);

      final locationRequest = sdk.LocationRequest((b) => b
        ..source_ = sdk.LocationRequestSource_Enum.auto
        ..point.replace(location));

      final counts = sdk.BiteCountsRequest((b) => b
        ..head = 1
        ..leftArm = 0
        ..rightArm = 0
        ..chest = 0
        ..leftLeg = 0
        ..rightLeg = 0);

      final biteRequest = sdk.BiteRequest((b) => b
        ..createdAt = DateTime.now().toUtc()
        ..sentAt = DateTime.now().toUtc()
        ..location.replace(locationRequest)
        ..eventEnvironment = sdk.BiteRequestEventEnvironmentEnum.indoors
        ..eventMoment = sdk.BiteRequestEventMomentEnum.now
        ..counts.replace(counts));

      // Expect exception
      expect(
        () => mockApi.create(biteRequest: biteRequest),
        throwsA(isA<Exception>()),
      );
    });
  });
}