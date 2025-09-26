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
          milliseconds:
              10000), // A lower receiveTimeout causes a timeout on the notifications endpoint
    );
    final Dio _dio = Dio(options);

    // Add auth interceptor for JWT token authentication
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = authProvider.accessToken;
        if (accessToken != null && accessToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 unauthorized error by attempting token refresh
        if (error.response?.statusCode == 401) {
          final refreshToken = authProvider.refreshToken;
          if (refreshToken != null && refreshToken.isNotEmpty) {
            try {
              handler.next(error);
            } catch (e) {
              handler.next(error);
            }
          } else {
            handler.next(error);
          }
        } else {
          handler.next(error);
        }
      },
    ));

    _client = MosquitoAlert(dio: _dio);
  }

  static Future<ApiService> init({required AuthProvider authProvider}) async {
    final config = await AppConfig.loadConfig();
    return ApiService._(
      authProvider: authProvider,
      baseUrl: config.baseUrl,
    );
  }

  MosquitoAlert get client => _client;
}
