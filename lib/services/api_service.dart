import 'package:dio/dio.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/app_config.dart';
import 'package:mosquito_alert_app/providers/auth_provider.dart';

class ApiService {
  final AuthProvider authProvider;
  late final MosquitoAlert _client;

  ApiService._({required this.authProvider, baseUrl}) {
    final BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(milliseconds: 5000),
      receiveTimeout: const Duration(
        milliseconds: 10000,
      ), // A lower receiveTimeout causes a timeout on the notifications endpoint
    );
    final Dio _dio = Dio(options);

    // Add a simple auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          // Add authorization header if we have an access token
          final accessToken = authProvider.accessToken;
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          handler.next(options);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          // Handle 401 errors by attempting to refresh the token
          if (error.response?.statusCode == 401) {
            try {
              // Try to refresh the token
              final refreshToken = authProvider.refreshToken;
              if (refreshToken != null && refreshToken.isNotEmpty) {
                // TODO: Implement token refresh logic here
                // For now, we'll just pass the error through
                print('401 error detected, token refresh not implemented yet');
              }
            } catch (e) {
              // Token refresh failed, pass through the original error
            }
          }
          handler.next(error);
        },
      ),
    );

    _client = MosquitoAlert(dio: _dio);
  }

  static Future<ApiService> init({required AuthProvider authProvider}) async {
    final config = await AppConfig.loadConfig();
    return ApiService._(authProvider: authProvider, baseUrl: config.baseUrl);
  }

  MosquitoAlert get client => _client;
}
