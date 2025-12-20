import 'package:shared_preferences/shared_preferences.dart';
import 'package:ergo_life_app/core/utils/logger.dart';

class StorageService {
  final SharedPreferences _prefs;

  // Storage keys
  static const String keyAuthToken = 'auth_token';

  StorageService(this._prefs);

  // Save string
  Future<bool> saveString(String key, String value) async {
    try {
      return await _prefs.setString(key, value);
    } catch (e) {
      AppLogger.error('Failed to save string', e, null, 'StorageService');
      return false;
    }
  }

  // Get string
  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      AppLogger.error('Failed to get string', e, null, 'StorageService');
      return null;
    }
  }

  // Save int
  Future<bool> saveInt(String key, int value) async {
    try {
      return await _prefs.setInt(key, value);
    } catch (e) {
      AppLogger.error('Failed to save int', e, null, 'StorageService');
      return false;
    }
  }

  // Get int
  int? getInt(String key) {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      AppLogger.error('Failed to get int', e, null, 'StorageService');
      return null;
    }
  }

  // Save bool
  Future<bool> saveBool(String key, bool value) async {
    try {
      return await _prefs.setBool(key, value);
    } catch (e) {
      AppLogger.error('Failed to save bool', e, null, 'StorageService');
      return false;
    }
  }

  // Get bool
  bool? getBool(String key) {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      AppLogger.error('Failed to get bool', e, null, 'StorageService');
      return null;
    }
  }

  // Remove key
  Future<bool> remove(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e) {
      AppLogger.error('Failed to remove key', e, null, 'StorageService');
      return false;
    }
  }

  // Clear all
  Future<bool> clear() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      AppLogger.error('Failed to clear storage', e, null, 'StorageService');
      return false;
    }
  }

  // Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // ===== Authentication Token Methods =====

  /// Save JWT authentication token
  Future<bool> saveAuthToken(String token) async {
    return await saveString(keyAuthToken, token);
  }

  /// Get stored JWT authentication token
  String? getAuthToken() {
    return getString(keyAuthToken);
  }

  /// Clear JWT authentication token
  Future<bool> clearAuthToken() async {
    return await remove(keyAuthToken);
  }

  /// Check if auth token exists
  bool hasAuthToken() {
    return containsKey(keyAuthToken);
  }
}
