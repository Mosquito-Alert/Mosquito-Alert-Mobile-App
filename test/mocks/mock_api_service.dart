import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/providers/auth_provider.dart';
import 'mock_mosquito_alert.dart';

/// Test-specific API service that uses mocks
class MockApiService {
  final AuthProvider authProvider;
  final MockMosquitoAlert _mockClient;

  MockApiService._({required this.authProvider})
      : _mockClient = MockMosquitoAlert();

  static Future<MockApiService> init(
      {required AuthProvider authProvider}) async {
    return MockApiService._(authProvider: authProvider);
  }

  MosquitoAlert get client => _mockClient;

  // Getter to access the mock for testing
  MockMosquitoAlert get mockClient => _mockClient;
}
