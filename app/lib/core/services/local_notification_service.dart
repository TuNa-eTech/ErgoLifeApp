import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ergo_life_app/core/utils/logger.dart';

/// Service to handle local notifications display (foreground)
class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize local notifications with platform-specific settings
  Future<void> initialize() async {
    if (_isInitialized) {
      AppLogger.debug(
        'Local notifications already initialized',
        'LocalNotificationService',
      );
      return;
    }

    try {
      // Android setup
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/launcher_icon',
      );

      // iOS setup
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false, // Will request via FCM
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      // Combined initialization settings
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize plugin
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Create Android notification channel
      await _createAndroidNotificationChannel();

      _isInitialized = true;
      AppLogger.success(
        'Local notifications initialized',
        'LocalNotificationService',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to initialize local notifications: $e',
        'LocalNotificationService',
      );
      rethrow;
    }
  }

  /// Create high-priority notification channel for Android 8.0+
  Future<void> _createAndroidNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'ergolife_notifications',
      'ErgoLife Notifications',
      description:
          'Important notifications about your streaks, houses, and rewards',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    AppLogger.debug(
      'Android notification channel created',
      'LocalNotificationService',
    );
  }

  /// Display a local notification
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'ergolife_notifications',
        'ErgoLife Notifications',
        channelDescription:
            'Important notifications about your streaks, houses, and rewards',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id,
        title,
        body,
        notificationDetails,
        payload: data?.toString(),
      );

      AppLogger.debug(
        'Local notification shown: $title',
        'LocalNotificationService',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to show local notification: $e',
        'LocalNotificationService',
      );
    }
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    AppLogger.debug(
      'Notification tapped with payload: $payload',
      'LocalNotificationService',
    );

    // Navigation will be handled by FcmService via deep linking
    // This is just for logging
  }

  /// Cancel a notification by ID
  Future<void> cancel(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _localNotifications.cancelAll();
  }
}
