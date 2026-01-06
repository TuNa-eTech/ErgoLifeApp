import 'package:dartz/dartz.dart';
import 'package:ergo_life_app/core/constants/api_constants.dart';
import 'package:ergo_life_app/core/constants/app_constants.dart';
import 'package:ergo_life_app/core/errors/exceptions.dart';
import 'package:ergo_life_app/core/errors/failures.dart';
import 'package:ergo_life_app/core/network/api_client.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:ergo_life_app/data/models/auth_model.dart';
import 'package:ergo_life_app/data/models/user_model.dart';
import 'package:ergo_life_app/data/services/storage_service.dart';

/// Repository for user-related operations
class UserRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  UserRepository(this._apiClient, this._storageService);

  // ===== API Methods =====

  /// Update user profile
  Future<Either<Failure, UserModel>> updateProfile({
    String? displayName,
    int? avatarId,
  }) async {
    try {
      AppLogger.info('Updating profile...', 'UserRepository');

      final data = <String, dynamic>{};
      if (displayName != null) data['displayName'] = displayName;
      if (avatarId != null) data['avatarId'] = avatarId;

      final response = await _apiClient.put(ApiConstants.usersMe, data: data);
      final userData = _apiClient.unwrapResponse(response.data);
      final user = UserModel.fromJson(userData as Map<String, dynamic>);

      AppLogger.success('Profile updated', 'UserRepository');
      return Right(user);
    } on ServerException catch (e) {
      AppLogger.error('Update profile failed', e.message, null, 'UserRepository');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error', e.message, null, 'UserRepository');
      return Left(NetworkFailure(message: 'Unable to connect'));
    } catch (e) {
      AppLogger.error('Update profile failed', e, null, 'UserRepository');
      return Left(ServerFailure(message: 'Failed to update profile'));
    }
  }

  /// Update FCM token
  Future<Either<Failure, void>> updateFcmToken(String token) async {
    try {
      await _apiClient.put(
        ApiConstants.usersFcmToken,
        data: {'fcmToken': token},
      );
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('Update FCM token failed', e.message, null, 'UserRepository');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Update FCM token failed', e, null, 'UserRepository');
      return Left(ServerFailure(message: 'Failed to update FCM token'));
    }
  }

  // ===== Cache Methods =====

  /// Get user from cache
  UserModel? getCachedUser() {
    final jsonString = _storageService.getString(AppConstants.keyUserProfile);
    if (jsonString != null) {
      return UserModel.fromJsonString(jsonString);
    }
    return null;
  }

  /// Save user to cache
  Future<bool> cacheUser(UserModel user) async {
    return await _storageService.saveString(
      AppConstants.keyUserProfile,
      user.toJsonString(),
    );
  }

  /// Get user from API
  Future<UserModel> fetchUser() async {
    try {
      final response = await _apiClient.get('/auth/me');
      final userData = _apiClient.unwrapResponse(response.data);
      return UserModel.fromJson(userData as Map<String, dynamic>);
    } catch (e) {
      // If API fails, try to get from cache
      final cachedUser = getCachedUser();
      if (cachedUser != null) {
        return cachedUser;
      }
      rethrow;
    }
  }

  /// Update user
  Future<UserModel> updateUser(UserModel user) async {
    try {
      final response = await _apiClient.put(
        '/user/profile',
        data: user.toJson(),
      );
      final userData = _apiClient.unwrapResponse(response.data);
      final updatedUser = UserModel.fromJson(userData as Map<String, dynamic>);

      // Cache the updated user
      await cacheUser(updatedUser);

      return updatedUser;
    } catch (e) {
      rethrow;
    }
  }

  /// Get default user (for demo purposes)
  UserModel getDefaultUser() {
    return UserModel(
      id: '1',
      firebaseUid: 'demo-firebase-uid',
      provider: AuthProvider.google,
      name: 'ErgoLife User',
      email: 'user@ergolife.com',
      createdAt: DateTime.now(),
    );
  }

  /// Clear user cache
  Future<bool> clearUserCache() async {
    return await _storageService.remove(AppConstants.keyUserProfile);
  }
}
