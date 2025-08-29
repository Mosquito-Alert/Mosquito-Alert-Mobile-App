# API Integration

## 🌐 API Architecture Overview

The Mosquito Alert app integrates with a custom backend API to synchronize data, authenticate users, and retrieve mosquito-related information. The API client is built using the Dio HTTP client with custom interceptors for robust error handling, authentication, and retry logic.

## 🔧 API Client Configuration

### Base Client Setup

```dart
class ApiClient {
  static ApiClient? _instance;
  static ApiClient get instance => _instance ??= ApiClient._internal();
  
  late Dio _dio;
  final String _baseUrl;
  
  ApiClient._internal() : _baseUrl = AppConfig.apiUrl {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      sendTimeout: Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'MosquitoAlert-Mobile/${AppConfig.version}',
      },
    ));
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
      RetryInterceptor(),
      ErrorInterceptor(),
    ]);
  }
  
  Dio get dio => _dio;
}
```

### Environment Configuration

```dart
class AppConfig {
  static String get apiUrl {
    switch (BuildConfig.environment) {
      case Environment.development:
        return 'https://dev-api.mosquitoalert.com/api/v1';
      case Environment.testing:
        return 'https://test-api.mosquitoalert.com/api/v1';
      case Environment.production:
        return 'https://api.mosquitoalert.com/api/v1';
      default:
        return 'https://dev-api.mosquitoalert.com/api/v1';
    }
  }
  
  static String get version => '2.1.0'; // From package_info_plus
}
```

## 🔐 Authentication System

### JWT Token Management

```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for login/register endpoints
    if (_isAuthEndpoint(options.path)) {
      return handler.next(options);
    }
    
    final token = await SecureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry original request
        final newToken = await SecureStorage.getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        
        try {
          final response = await ApiClient.instance.dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      } else {
        // Refresh failed, redirect to login
        await _handleAuthFailure();
      }
    }
    
    handler.next(err);
  }
  
  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') || 
           path.contains('/auth/register') ||
           path.contains('/auth/refresh');
  }
  
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken == null) return false;
      
      final response = await ApiClient.instance.dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      
      await SecureStorage.storeAuthTokens(
        accessToken: response.data['access_token'],
        refreshToken: response.data['refresh_token'],
      );
      
      return true;
    } catch (e) {
      print('Token refresh failed: $e');
      return false;
    }
  }
  
  Future<void> _handleAuthFailure() async {
    await SecureStorage.clearAuthTokens();
    // Navigate to login screen
    NavigationService.navigateToLogin();
  }
}
```

### Authentication Service

```dart
class AuthService {
  static const String LOGIN_ENDPOINT = '/auth/login';
  static const String REGISTER_ENDPOINT = '/auth/register';
  static const String LOGOUT_ENDPOINT = '/auth/logout';
  
  static Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.instance.dio.post(
        LOGIN_ENDPOINT,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      final data = response.data;
      await SecureStorage.storeAuthTokens(
        accessToken: data['access_token'],
        refreshToken: data['refresh_token'],
      );
      
      return User.fromJson(data['user']);
    } catch (e) {
      if (e is DioException) {
        throw AuthException(_getAuthErrorMessage(e));
      }
      throw AuthException('Login failed: $e');
    }
  }
  
  static Future<User> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await ApiClient.instance.dio.post(
        REGISTER_ENDPOINT,
        data: {
          'email': email,
          'password': password,
          'display_name': displayName,
        },
      );
      
      final data = response.data;
      await SecureStorage.storeAuthTokens(
        accessToken: data['access_token'],
        refreshToken: data['refresh_token'],
      );
      
      return User.fromJson(data['user']);
    } catch (e) {
      if (e is DioException) {
        throw AuthException(_getAuthErrorMessage(e));
      }
      throw AuthException('Registration failed: $e');
    }
  }
  
  static Future<void> logout() async {
    try {
      await ApiClient.instance.dio.post(LOGOUT_ENDPOINT);
    } catch (e) {
      print('Logout API call failed: $e');
    } finally {
      await SecureStorage.clearAuthTokens();
    }
  }
  
  static String _getAuthErrorMessage(DioException error) {
    switch (error.response?.statusCode) {
      case 400:
        return 'Invalid credentials provided';
      case 401:
        return 'Email or password is incorrect';
      case 422:
        return 'Email is already registered';
      case 429:
        return 'Too many attempts. Please try again later';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}
```

## 📊 Report Management API

### Report Submission

```dart
class ReportApiService {
  static const String REPORTS_ENDPOINT = '/reports';
  static const String UPLOAD_ENDPOINT = '/upload';
  
  static Future<String> uploadImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: path.basename(imageFile.path),
          contentType: MediaType('image', 'jpeg'),
        ),
      });
      
      final response = await ApiClient.instance.dio.post(
        UPLOAD_ENDPOINT,
        data: formData,
        onSendProgress: (sent, total) {
          print('Upload progress: ${(sent / total * 100).toStringAsFixed(1)}%');
        },
      );
      
      return response.data['url'] as String;
    } catch (e) {
      throw ApiException('Image upload failed: $e');
    }
  }
  
  static Future<Report> createReport(Report report) async {
    try {
      final response = await ApiClient.instance.dio.post(
        REPORTS_ENDPOINT,
        data: _reportToApiFormat(report),
      );
      
      return Report.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        throw ApiException(_getReportErrorMessage(e));
      }
      throw ApiException('Report creation failed: $e');
    }
  }
  
  static Future<List<Report>> getUserReports({
    int page = 1,
    int limit = 20,
    ReportType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (type != null) {
        queryParams['type'] = type.toString().split('.').last;
      }
      
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      
      final response = await ApiClient.instance.dio.get(
        REPORTS_ENDPOINT,
        queryParameters: queryParams,
      );
      
      final data = response.data['reports'] as List;
      return data.map((json) => Report.fromJson(json)).toList();
    } catch (e) {
      throw ApiException('Failed to fetch reports: $e');
    }
  }
  
  static Map<String, dynamic> _reportToApiFormat(Report report) {
    return {
      'type': report.type.toString().split('.').last,
      'latitude': report.latitude,
      'longitude': report.longitude,
      'location_name': report.locationName,
      'notes': report.notes,
      'created_at': report.createdAt.toIso8601String(),
      'images': report.imagePaths,
      'metadata': report.metadata,
    };
  }
  
  static String _getReportErrorMessage(DioException error) {
    switch (error.response?.statusCode) {
      case 400:
        return 'Invalid report data provided';
      case 413:
        return 'Image file is too large';
      case 422:
        return 'Report validation failed';
      default:
        return 'Failed to submit report. Please try again';
    }
  }
}
```

## 🗺️ Map Data API

### Mosquito Activity Data

```dart
class MapApiService {
  static const String MAP_DATA_ENDPOINT = '/map/reports';
  static const String STATISTICS_ENDPOINT = '/statistics';
  
  static Future<List<MapReport>> getMapReports({
    required double centerLat,
    required double centerLng,
    required double radiusKm,
    DateTime? startDate,
    DateTime? endDate,
    ReportType? type,
  }) async {
    try {
      final response = await ApiClient.instance.dio.get(
        MAP_DATA_ENDPOINT,
        queryParameters: {
          'center_lat': centerLat,
          'center_lng': centerLng,
          'radius_km': radiusKm,
          'start_date': startDate?.toIso8601String(),
          'end_date': endDate?.toIso8601String(),
          'type': type?.toString().split('.').last,
        },
      );
      
      final data = response.data['reports'] as List;
      return data.map((json) => MapReport.fromJson(json)).toList();
    } catch (e) {
      throw ApiException('Failed to fetch map data: $e');
    }
  }
  
  static Future<MosquitoStatistics> getStatistics({
    double? lat,
    double? lng,
    double? radiusKm,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (lat != null && lng != null) {
        queryParams['lat'] = lat;
        queryParams['lng'] = lng;
        queryParams['radius_km'] = radiusKm ?? 10.0;
      }
      
      final response = await ApiClient.instance.dio.get(
        STATISTICS_ENDPOINT,
        queryParameters: queryParams,
      );
      
      return MosquitoStatistics.fromJson(response.data);
    } catch (e) {
      throw ApiException('Failed to fetch statistics: $e');
    }
  }
}

class MapReport {
  final String id;
  final double latitude;
  final double longitude;
  final ReportType type;
  final DateTime createdAt;
  final String? species;
  
  MapReport({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.createdAt,
    this.species,
  });
  
  factory MapReport.fromJson(Map<String, dynamic> json) {
    return MapReport(
      id: json['id'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      type: ReportType.values.firstWhere(
        (t) => t.toString().split('.').last == json['type'],
      ),
      createdAt: DateTime.parse(json['created_at']),
      species: json['species'],
    );
  }
}
```

## 🔄 Retry & Error Handling

### Retry Interceptor

```dart
class RetryInterceptor extends Interceptor {
  static const int MAX_RETRIES = 3;
  static const Duration RETRY_DELAY = Duration(seconds: 2);
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retry_count'] ?? 0;
      
      if (retryCount < MAX_RETRIES) {
        err.requestOptions.extra['retry_count'] = retryCount + 1;
        
        // Wait before retry
        await Future.delayed(RETRY_DELAY * (retryCount + 1));
        
        try {
          final response = await ApiClient.instance.dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          // Continue with original error if retry fails
        }
      }
    }
    
    handler.next(err);
  }
  
  bool _shouldRetry(DioException error) {
    // Retry on network errors and 5xx server errors
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           error.type == DioExceptionType.sendTimeout ||
           (error.response?.statusCode != null && 
            error.response!.statusCode! >= 500);
  }
}
```

### Error Handling

```dart
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiError = ApiError.fromDioException(err);
    
    // Log error for debugging
    print('API Error: ${apiError.message}');
    
    // Report to analytics (if configured)
    FirebaseAnalytics.instance.logEvent(
      name: 'api_error',
      parameters: {
        'endpoint': err.requestOptions.path,
        'status_code': err.response?.statusCode ?? -1,
        'error_type': err.type.toString(),
      },
    );
    
    handler.next(err);
  }
}

class ApiError {
  final int? statusCode;
  final String message;
  final String? errorCode;
  final Map<String, dynamic>? details;
  
  ApiError({
    this.statusCode,
    required this.message,
    this.errorCode,
    this.details,
  });
  
  factory ApiError.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiError(message: 'Connection timeout. Please check your internet connection.');
      case DioExceptionType.receiveTimeout:
        return ApiError(message: 'Server response timeout. Please try again.');
      case DioExceptionType.sendTimeout:
        return ApiError(message: 'Request timeout. Please try again.');
      case DioExceptionType.badResponse:
        return ApiError(
          statusCode: error.response?.statusCode,
          message: _getErrorMessage(error.response?.data),
          errorCode: error.response?.data?['error_code'],
          details: error.response?.data?['details'],
        );
      default:
        return ApiError(message: 'Network error. Please check your connection.');
    }
  }
  
  static String _getErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData['message'] ?? 'An error occurred';
    }
    return 'An error occurred';
  }
}
```

## 📊 API Response Models

### Standard Response Format

```dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? meta;
  
  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.meta,
  });
  
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) dataFromJson,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null ? dataFromJson(json['data']) : null,
      message: json['message'],
      statusCode: json['status_code'],
      meta: json['meta'],
    );
  }
}

// Usage example
Future<ApiResponse<List<Report>>> getReports() async {
  final response = await ApiClient.instance.dio.get('/reports');
  return ApiResponse.fromJson(
    response.data,
    (data) => (data as List).map((json) => Report.fromJson(json)).toList(),
  );
}
```

## 🔍 Logging & Debugging

### Request/Response Logging

```dart
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('🚀 API Request: ${options.method} ${options.path}');
      print('Headers: ${options.headers}');
      if (options.data != null) {
        print('Data: ${options.data}');
      }
    }
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
      print('Data: ${response.data}');
    }
    handler.next(response);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('❌ API Error: ${err.response?.statusCode} ${err.requestOptions.path}');
      print('Error: ${err.message}');
      if (err.response?.data != null) {
        print('Error Data: ${err.response?.data}');
      }
    }
    handler.next(err);
  }
}
```

## 🌐 Network Connectivity Handling

### Connectivity Monitoring

```dart
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();
  
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _subscription;
  
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  
  Stream<bool> get onConnectivityChanged => 
      _connectivity.onConnectivityChanged.map(_mapConnectivityResult);
  
  void initialize() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      (result) {
        _isOnline = _mapConnectivityResult(result);
        _notifyConnectivityChange();
      },
    );
    
    // Check initial connectivity
    _checkInitialConnectivity();
  }
  
  Future<void> _checkInitialConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = _mapConnectivityResult(result);
  }
  
  bool _mapConnectivityResult(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }
  
  void _notifyConnectivityChange() {
    if (_isOnline) {
      // Trigger sync when back online
      SyncService.scheduleImmediateSync();
    }
  }
  
  void dispose() {
    _subscription?.cancel();
  }
}
```
