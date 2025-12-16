import 'package:ergo_life_app/core/constants/app_constants.dart';
import 'package:ergo_life_app/data/models/user_model.dart';
import 'package:ergo_life_app/data/services/api_service.dart';
import 'package:ergo_life_app/data/services/storage_service.dart';

class UserRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  UserRepository(this._apiService, this._storageService);

  // Get user from cache
  UserModel? getCachedUser() {
    final jsonString = _storageService.getString(AppConstants.keyUserProfile);
    if (jsonString != null) {
      return UserModel.fromJsonString(jsonString);
    }
    return null;
  }

  // Save user to cache
  Future<bool> cacheUser(UserModel user) async {
    return await _storageService.saveString(
      AppConstants.keyUserProfile,
      user.toJsonString(),
    );
  }

  // Get user from API (example)
  Future<UserModel> fetchUser() async {
    try {
      final response = await _apiService.get('/user/profile');
      return UserModel.fromJson(response.data);
    } catch (e) {
      // If API fails, try to get from cache
      final cachedUser = getCachedUser();
      if (cachedUser != null) {
        return cachedUser;
      }
      rethrow;
    }
  }

  // Update user
  Future<UserModel> updateUser(UserModel user) async {
    try {
      final response = await _apiService.put('/user/profile', data: user.toJson());
      final updatedUser = UserModel.fromJson(response.data);
      
      // Cache the updated user
      await cacheUser(updatedUser);
      
      return updatedUser;
    } catch (e) {
      rethrow;
    }
  }

  // Get default user (for demo purposes)
  UserModel getDefaultUser() {
    return UserModel(
      id: '1',
      name: 'ErgoLife User',
      email: 'user@ergolife.com',
      createdAt: DateTime.now(),
    );
  }

  // Clear user cache
  Future<bool> clearUserCache() async {
    return await _storageService.remove(AppConstants.keyUserProfile);
  }
}
