import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ergo_life_app/core/services/local_notification_service.dart';
import 'package:ergo_life_app/core/network/api_client.dart';
import 'package:ergo_life_app/core/constants/api_constants.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';
import 'package:ergo_life_app/core/utils/logger.dart';

/// Service to handle Firebase Cloud Messaging (FCM)
class FcmService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final LocalNotificationService _localNotificationService;
  final ApiClient _apiClient;

  FcmService({
    required LocalNotificationService localNotificationService,
    required ApiClient apiClient,
  }) : _localNotificationService = localNotificationService,
       _apiClient = apiClient;

  /// Initialize FCM service
  Future<void> initialize() async {
    try {
      AppLogger.info('Initializing FCM service...', 'FcmService');

      // 1. Request notification permissions
      final settings = await _requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        AppLogger.success('Notification permissions granted', 'FcmService');

        // 2. Get and register FCM token
        await _registerToken();

        // 3. Listen for token refresh
        _fcm.onTokenRefresh.listen(_updateBackendToken);

        // 4. Setup message handlers
        _setupMessageHandlers();

        // 5. Check if app was opened from terminated state
        await _handleInitialMessage();

        AppLogger.success('FCM service initialized', 'FcmService');
      } else {
        AppLogger.warning(
          'Notification permissions denied: ${settings.authorizationStatus}',
          'FcmService',
        );
      }
    } catch (e) {
      AppLogger.error('FCM initialization failed: $e', 'FcmService');
      rethrow;
    }
  }

  /// Request notification permissions
  Future<NotificationSettings> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    AppLogger.debug(
      'Notification permission status: ${settings.authorizationStatus}',
      'FcmService',
    );

    return settings;
  }

  /// Get FCM token and register with backend
  Future<void> _registerToken() async {
    try {
      final token = await _fcm.getToken();

      if (token != null) {
        AppLogger.debug(
          'FCM Token obtained: ${token.substring(0, 20)}...',
          'FcmService',
        );
        await _updateBackendToken(token);
      } else {
        AppLogger.warning('FCM token is null', 'FcmService');
      }
    } catch (e) {
      AppLogger.error('Failed to register FCM token: $e', 'FcmService');
    }
  }

  /// Update FCM token in backend
  Future<void> _updateBackendToken(String token) async {
    try {
      await _apiClient.patch(
        ApiConstants.usersFcmToken,
        data: {'fcmToken': token},
      );

      AppLogger.success('FCM token updated in backend', 'FcmService');
    } catch (e) {
      AppLogger.error(
        'Failed to update FCM token in backend: $e',
        'FcmService',
      );
    }
  }

  /// Setup message handlers for different app states
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background/Terminated -> Foreground (notification tap)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  /// Handle foreground message by showing local notification
  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.info(
      'Foreground message received: ${message.notification?.title}',
      'FcmService',
    );

    final notification = message.notification;
    if (notification != null) {
      _localNotificationService.show(
        id: message.hashCode,
        title: notification.title ?? 'ErgoLife',
        body: notification.body ?? '',
        imageUrl:
            notification.android?.imageUrl ?? notification.apple?.imageUrl,
        data: message.data,
      );
    }
  }

  /// Handle notification tap (deep linking)
  void _handleNotificationTap(RemoteMessage message) {
    AppLogger.info('Notification tapped: ${message.data}', 'FcmService');

    final actionUrl = message.data['actionUrl'] as String?;
    if (actionUrl != null && actionUrl.isNotEmpty) {
      // Convert deep link to route path
      // ergolife://tasks -> /tasks
      // ergolife://house/123 -> /house/123
      final path = actionUrl.replaceFirst('ergolife://', '/');

      AppLogger.debug('Navigating to: $path', 'FcmService');
      AppRouter.router.push(path);
    }
  }

  /// Check for initial message when app opened from terminated state
  Future<void> _handleInitialMessage() async {
    final initialMessage = await _fcm.getInitialMessage();

    if (initialMessage != null) {
      AppLogger.info(
        'App opened from terminated state via notification',
        'FcmService',
      );
      _handleNotificationTap(initialMessage);
    }
  }

  /// Clear FCM token (called on logout)
  Future<void> clearToken() async {
    try {
      AppLogger.info('Clearing FCM token...', 'FcmService');

      // 1. Delete token from backend
      await _apiClient.delete(ApiConstants.usersFcmToken);
      AppLogger.debug('FCM token cleared from backend', 'FcmService');

      // 2. Delete FCM token locally (prevents receiving new messages)
      await _fcm.deleteToken();
      AppLogger.debug('FCM token deleted locally', 'FcmService');

      AppLogger.success('FCM token cleared successfully', 'FcmService');
    } catch (e) {
      AppLogger.error('Failed to clear FCM token: $e', 'FcmService');
      // Don't rethrow - logout should proceed even if token clearing fails
    }
  }

  /// Refresh and update token (called on login)
  Future<void> refreshAndUpdateToken() async {
    try {
      AppLogger.info('Refreshing FCM token...', 'FcmService');

      // Force refresh token
      await _fcm.deleteToken();
      final newToken = await _fcm.getToken();

      if (newToken != null) {
        await _updateBackendToken(newToken);
        AppLogger.success('FCM token refreshed for new user', 'FcmService');
      } else {
        AppLogger.warning('Failed to get new FCM token', 'FcmService');
      }
    } catch (e) {
      AppLogger.error('Failed to refresh FCM token: $e', 'FcmService');
    }
  }

  /// Get current FCM token (for debugging)
  Future<String?> getFcmToken() async {
    return await _fcm.getToken();
  }
}
