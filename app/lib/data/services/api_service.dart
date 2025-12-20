import 'package:dio/dio.dart';
import 'package:ergo_life_app/core/config/app_config.dart';
import 'package:ergo_life_app/core/constants/api_constants.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:ergo_life_app/data/models/auth_model.dart';
import 'package:ergo_life_app/data/models/user_model.dart';

class ApiService {
  late final Dio _dio;
  String? _authToken;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectionTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
          ApiConstants.headerAccept: ApiConstants.contentTypeJson,
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers[ApiConstants.headerAuth] =
                '${ApiConstants.bearerPrefix}$_authToken';
          }

          if (AppConfig.enableLogging) {
            AppLogger.info(
              '🚀 ${options.method} => ${options.uri}',
              'ApiService',
            );
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (AppConfig.enableLogging) {
            AppLogger.success(
              '✅ ${response.statusCode} => ${response.requestOptions.uri}',
              'ApiService',
            );
          }

          return handler.next(response);
        },
        onError: (error, handler) {
          if (AppConfig.enableLogging) {
            AppLogger.error(
              '❌ ${error.response?.statusCode} => ${error.requestOptions.uri}',
              error.message,
              null,
              'ApiService',
            );
          }

          return handler.next(error);
        },
      ),
    );
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return await _dio.patch(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) async {
    return await _dio.delete(path, data: data);
  }

  // ===== Authentication Methods =====

  /// Social login with Firebase ID token
  Future<AuthResponse> socialLogin(String idToken) async {
    try {
      final response = await post(
        ApiConstants.socialLogin,
        data: {'idToken': idToken},
      );
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error(
        'Social login failed',
        e,
        null,
        'ApiService',
      );
      rethrow;
    }
  }

  /// Get current authenticated user
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await get(ApiConstants.me);
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error(
        'Get current user failed',
        e,
        null,
        'ApiService',
      );
      rethrow;
    }
  }
}
