import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ergo_life_app/core/utils/logger.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase for background isolate
  await Firebase.initializeApp();

  AppLogger.info(
    'Background message received: ${message.notification?.title}',
    'BackgroundMessageHandler',
  );

  // Could store notification in local database for offline access
  // For now, just log it
}
