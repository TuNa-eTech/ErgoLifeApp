import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ergo_life_app/core/constants/api_constants.dart';
import 'package:ergo_life_app/core/constants/app_constants.dart';
import 'package:ergo_life_app/core/errors/exceptions.dart';
import 'package:ergo_life_app/core/errors/failures.dart';
import 'package:ergo_life_app/core/network/api_client.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:ergo_life_app/data/models/auth_model.dart';
import 'package:ergo_life_app/data/models/user_model.dart';
import 'package:ergo_life_app/data/services/auth_service.dart'
    hide FirebaseAuthException;
import 'package:ergo_life_app/data/services/storage_service.dart';

/// Repository for authentication operations
class AuthRepository {
  final AuthService _authService;
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthRepository(
    this._authService,
    this._apiClient,
    this._storageService,
  );

  /// Social login with Firebase ID token
  Future<AuthResponse> _socialLogin(String idToken) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.socialLogin,
        data: {'idToken': idToken},
      );

      // Backend wraps response in {success: bool, data: {...}}
      final actualData = _apiClient.unwrapResponse(response.data);
      return AuthResponse.fromJson(actualData as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('Social login failed', e, null, 'AuthRepository');
      rethrow;
    }
  }

  /// Sign in with Google
  Future<Either<Failure, UserModel>> signInWithGoogle() async {
    try {
      AppLogger.info('Starting Google sign-in flow', 'AuthRepository');

      // 1. Sign in with Firebase
      final UserCredential userCredential =
          await _authService.signInWithGoogle();

      // 2. Get Firebase ID token
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        AppLogger.error(
          'Failed to get ID token',
          'No ID token available',
          null,
          'AuthRepository',
        );
        return Left(ServerFailure(message: 'Failed to get authentication token'));
      }

      AppLogger.info('Got Firebase ID token, calling backend', 'AuthRepository');

      // 3. Send ID token to backend
      final authResponse = await _socialLogin(idToken);

      // 4. Store JWT token
      await _storageService.saveAuthToken(authResponse.accessToken);

      // 5. Update API client with token
      _apiClient.setAuthToken(authResponse.accessToken);

      AppLogger.success(
        'Google sign-in successful for user: ${authResponse.user.email}',
        'AuthRepository',
      );

      return Right(authResponse.user);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Firebase auth error', e.message, null, 'AuthRepository');
      return Left(AuthFailure(message: e.message ?? 'Authentication failed'));
    } on ServerException catch (e) {
      AppLogger.error('Backend error', e.message, null, 'AuthRepository');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error', e.message, null, 'AuthRepository');
      return Left(
        NetworkFailure(message: 'Unable to connect. Please check your internet connection.'),
      );
    } catch (e) {
      AppLogger.error('Unexpected error during sign-in', e, null, 'AuthRepository');
      return Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  /// Sign in with Apple
  Future<Either<Failure, UserModel>> signInWithApple() async {
    try {
      AppLogger.info('Starting Apple sign-in flow', 'AuthRepository');

      // 1. Sign in with Firebase
      final UserCredential userCredential =
          await _authService.signInWithApple();

      // 2. Get Firebase ID token
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        AppLogger.error(
          'Failed to get ID token',
          'No ID token available',
          null,
          'AuthRepository',
        );
        return Left(ServerFailure(message: 'Failed to get authentication token'));
      }

      AppLogger.info('Got Firebase ID token, calling backend', 'AuthRepository');

      // 3. Send ID token to backend
      final authResponse = await _socialLogin(idToken);

      // 4. Store JWT token
      await _storageService.saveAuthToken(authResponse.accessToken);

      // 5. Update API client with token
      _apiClient.setAuthToken(authResponse.accessToken);

      AppLogger.success(
        'Apple sign-in successful for user: ${authResponse.user.email}',
        'AuthRepository',
      );

      return Right(authResponse.user);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Firebase auth error', e.message, null, 'AuthRepository');
      return Left(AuthFailure(message: e.message ?? 'Authentication failed'));
    } on ServerException catch (e) {
      AppLogger.error('Backend error', e.message, null, 'AuthRepository');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error', e.message, null, 'AuthRepository');
      return Left(
        NetworkFailure(message: 'Unable to connect. Please check your internet connection.'),
      );
    } catch (e) {
      AppLogger.error('Unexpected error during sign-in', e, null, 'AuthRepository');
      return Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      AppLogger.info('Signing out', 'AuthRepository');

      // Call backend logout API to invalidate FCM token
      try {
        await _apiClient.post(ApiConstants.logout);
        AppLogger.info('Backend logout successful', 'AuthRepository');
      } catch (e) {
        // Log but continue - we still want to sign out locally
        AppLogger.warning(
          'Backend logout failed, continuing with local sign out: $e',
          'AuthRepository',
        );
      }

      // Sign out from Firebase
      await _authService.signOut();

      // Clear JWT token
      await _storageService.clearAuthToken();

      // Clear user profile cache
      await _storageService.remove(AppConstants.keyUserProfile);

      // Clear API client token
      _apiClient.clearAuthToken();

      AppLogger.success('Sign out successful', 'AuthRepository');
    } catch (e) {
      AppLogger.error('Error during sign out', e, null, 'AuthRepository');
      // Don't throw - always allow sign out to complete
    }
  }

  /// Get stored JWT token
  String? getStoredToken() {
    return _storageService.getAuthToken();
  }

  /// Check if user has a stored token
  bool hasStoredToken() {
    return _storageService.hasAuthToken();
  }

  /// Get current authenticated user
  Future<UserModel> _getCurrentUserFromApi() async {
    try {
      final response = await _apiClient.get(ApiConstants.authMe);
      final userData = _apiClient.unwrapResponse(response.data);
      return UserModel.fromJson(userData as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('Get current user failed', e, null, 'AuthRepository');
      rethrow;
    }
  }

  /// Attempt to get current user with stored token
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    try {
      final token = getStoredToken();
      if (token == null) {
        return Left(AuthFailure(message: 'No authentication token found'));
      }

      AppLogger.info('Attempting auto sign-in with stored token', 'AuthRepository');

      // Set token in API client
      _apiClient.setAuthToken(token);

      // Fetch current user from backend
      final user = await _getCurrentUserFromApi();

      AppLogger.success('Auto sign-in successful', 'AuthRepository');
      return Right(user);
    } on UnauthorizedException catch (e) {
      AppLogger.warning('Token is invalid or expired', 'AuthRepository');
      // Clear invalid token
      await _storageService.clearAuthToken();
      _apiClient.clearAuthToken();
      return Left(AuthFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error', e.message, null, 'AuthRepository');
      return Left(NetworkFailure(message: 'Unable to connect'));
    } catch (e) {
      AppLogger.error('Error getting current user', e, null, 'AuthRepository');
      return Left(ServerFailure(message: 'Failed to get user information'));
    }
  }
}
