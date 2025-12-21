import 'package:dio/dio.dart';
import 'package:ergo_life_app/core/config/app_config.dart';
import 'package:ergo_life_app/core/constants/api_constants.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:ergo_life_app/data/models/auth_model.dart';
import 'package:ergo_life_app/data/models/user_model.dart';
import 'package:ergo_life_app/data/models/activity_model.dart';
import 'package:ergo_life_app/data/models/house_model.dart';
import 'package:ergo_life_app/data/models/leaderboard_model.dart';
import 'package:ergo_life_app/data/models/stats_model.dart';

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
      
      // Backend wraps response in {success: bool, data: {...}}
      // Need to unwrap to get actual auth response
      final wrappedData = response.data as Map<String, dynamic>;
      final actualData = wrappedData['data'] as Map<String, dynamic>;
      
      return AuthResponse.fromJson(actualData);
    } catch (e) {
      AppLogger.error('Social login failed', e, null, 'ApiService');
      rethrow;
    }
  }

  /// Get current authenticated user
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await get(ApiConstants.authMe);
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('Get current user failed', e, null, 'ApiService');
      rethrow;
    }
  }

  // ===== User Methods =====

  /// Update user profile
  Future<UserModel> updateProfile({
    String? displayName,
    int? avatarId,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (displayName != null) data['displayName'] = displayName;
      if (avatarId != null) data['avatarId'] = avatarId;

      final response = await put(ApiConstants.usersMe, data: data);
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('Update profile failed', e, null, 'ApiService');
      rethrow;
    }
  }

  /// Update FCM token
  Future<void> updateFcmToken(String token) async {
    try {
      await put(ApiConstants.usersFcmToken, data: {'fcmToken': token});
    } catch (e) {
      AppLogger.error('Update FCM token failed', e, null, 'ApiService');
      rethrow;
    }
  }

  // ===== Activity Methods =====

  /// Create a new activity (after completing a task)
  Future<CreateActivityResponse> createActivity({
    required String taskName,
    required int durationSeconds,
    required double metsValue,
    required int magicWipePercentage,
  }) async {
    try {
      final response = await post(
        ApiConstants.activities,
        data: {
          'taskName': taskName,
          'durationSeconds': durationSeconds,
          'metsValue': metsValue,
          'magicWipePercentage': magicWipePercentage,
        },
      );
      return CreateActivityResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Create activity failed', e, null, 'ApiService');
      rethrow;
    }
  }

  /// Get activity history
  Future<PaginatedActivities> getActivities({
    int page = 1,
    int limit = 20,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (fromDate != null) {
        queryParams['fromDate'] = fromDate.toIso8601String();
      }
      if (toDate != null) {
        queryParams['toDate'] = toDate.toIso8601String();
      }

      final response = await get(
        ApiConstants.activities,
        queryParameters: queryParams,
      );
      return PaginatedActivities.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Get activities failed', e, null, 'ApiService');
      rethrow;
    }
  }

  /// Get leaderboard
  Future<LeaderboardResponse> getLeaderboard({String? week}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (week != null) queryParams['week'] = week;

      final response = await get(
        ApiConstants.activitiesLeaderboard,
        queryParameters: queryParams,
      );
      return LeaderboardResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error('Get leaderboard failed', e, null, 'ApiService');
      rethrow;
    }
  }

  /// Get activity stats
  Future<StatsModel> getStats({String period = 'week'}) async {
    try {
      final response = await get(
        ApiConstants.activitiesStats,
        queryParameters: {'period': period},
      );
      return StatsModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('Get stats failed', e, null, 'ApiService');
      rethrow;
    }
  }

  // ===== House Methods =====

  /// Create a new house
  Future<HouseModel> createHouse(String name) async {
    try {
      final response = await post(
        ApiConstants.houses,
        data: {'name': name},
      );
      return HouseModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('Create house failed', e, null, 'ApiService');
      rethrow;
    }
  }

  /// Get current user's house
  Future<HouseModel?> getMyHouse() async {
    try {
      final response = await get(ApiConstants.housesMe);
      if (response.data == null) return null;
      return HouseModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      // 404 means no house - not an error
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      AppLogger.error('Get my house failed', e, null, 'ApiService');
      rethrow;
    }
  }

  /// Join a house with invite code
  Future<HouseModel> joinHouse(String inviteCode) async {
    try {
      final response = await post(
        ApiConstants.housesJoin,
        data: {'inviteCode': inviteCode},
      );
      return HouseModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('Join house failed', e, null, 'ApiService');
      rethrow;
    }
  }

  /// Leave current house
  Future<void> leaveHouse() async {
    try {
      await post(ApiConstants.housesLeave);
    } catch (e) {
      AppLogger.error('Leave house failed', e, null, 'ApiService');
      rethrow;
    }
  }

  /// Get invite details for current house
  Future<HouseInvite> getHouseInvite() async {
    try {
      final response = await get(ApiConstants.housesInvite);
      return HouseInvite.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('Get house invite failed', e, null, 'ApiService');
      rethrow;
    }
  }

  /// Preview a house before joining
  Future<HousePreview> previewHouse(String code) async {
    try {
      final response = await get('${ApiConstants.housesPreview}/$code/preview');
      return HousePreview.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('Preview house failed', e, null, 'ApiService');
      rethrow;
    }
  }
}

