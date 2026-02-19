import 'dart:io' show Platform;

import 'package:health/health.dart';
import 'package:ergo_life_app/core/utils/logger.dart';

/// Abstraction layer for the `health` package.
///
/// Wraps HealthKit (iOS) and Health Connect (Android) APIs
/// to provide a simple interface for reading health data and
/// writing workouts.
class HealthService {
  final Health _health = Health();
  bool _isConfigured = false;

  /// Platform-aware data source identifier.
  ///
  /// Returns `'healthkit'` on iOS, `'health_connect'` on
  /// Android, or `'estimate'` on unsupported platforms.
  String get dataSourceName {
    if (Platform.isIOS) return 'healthkit';
    if (Platform.isAndroid) return 'health_connect';
    return 'estimate';
  }

  /// Data types the app reads from HealthKit.
  static const readTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.STEPS,
    HealthDataType.WEIGHT,
  ];

  /// Data types the app writes to HealthKit.
  static const writeTypes = [HealthDataType.WORKOUT];

  /// Configures the underlying Health instance.
  ///
  /// Must be called once at app startup before any other
  /// health operations.
  Future<void> configure() async {
    try {
      await _health.configure();
      _isConfigured = true;
      AppLogger.info('HealthService configured', 'HealthService');
    } on Exception catch (e) {
      AppLogger.error('Failed to configure HealthService: $e', 'HealthService');
    }
  }

  /// Whether the service has been configured.
  bool get isConfigured => _isConfigured;

  /// Checks if HealthKit/Health Connect is available on
  /// the device.
  Future<bool> isAvailable() async {
    if (!_isConfigured) {
      await configure();
    }
    return _isConfigured;
  }

  /// Requests authorization for the configured data types.
  ///
  /// Returns `true` if the user granted access.
  /// On iOS, HealthKit permission dialogs are shown only
  /// once — subsequent calls return immediately.
  Future<bool> requestAuthorization() async {
    if (!_isConfigured) await configure();

    try {
      final allTypes = [...readTypes, ...writeTypes];
      final permissions = [
        ...List.filled(readTypes.length, HealthDataAccess.READ),
        ...List.filled(writeTypes.length, HealthDataAccess.WRITE),
      ];

      final granted = await _health.requestAuthorization(
        allTypes,
        permissions: permissions,
      );

      AppLogger.info('Health authorization result: $granted', 'HealthService');
      return granted;
    } on Exception catch (e) {
      AppLogger.error('Health authorization failed: $e', 'HealthService');
      return false;
    }
  }

  /// Checks if the app has been granted permissions.
  ///
  /// On iOS, this may return `null` due to Apple's privacy
  /// model — the app cannot know whether the user denied
  /// permissions.
  Future<bool?> hasPermissions() async {
    if (!_isConfigured) return false;

    try {
      return await _health.hasPermissions(
        readTypes,
        permissions: List.filled(readTypes.length, HealthDataAccess.READ),
      );
    } on Exception {
      return null;
    }
  }

  /// Fetches heart rate data points in the given range.
  Future<List<HealthDataPoint>> getHeartRate({
    required DateTime start,
    required DateTime end,
  }) async {
    if (!_isConfigured) return [];

    try {
      return await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: start,
        endTime: end,
      );
    } on Exception catch (e) {
      AppLogger.error('Failed to get heart rate: $e', 'HealthService');
      return [];
    }
  }

  /// Fetches active energy burned data points in the
  /// given range.
  Future<List<HealthDataPoint>> getActiveCalories({
    required DateTime start,
    required DateTime end,
  }) async {
    if (!_isConfigured) return [];

    try {
      return await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: start,
        endTime: end,
      );
    } on Exception catch (e) {
      AppLogger.error('Failed to get active calories: $e', 'HealthService');
      return [];
    }
  }

  /// Fetches step count data points in the given range.
  Future<List<HealthDataPoint>> getSteps({
    required DateTime start,
    required DateTime end,
  }) async {
    if (!_isConfigured) return [];

    try {
      return await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: start,
        endTime: end,
      );
    } on Exception catch (e) {
      AppLogger.error('Failed to get steps: $e', 'HealthService');
      return [];
    }
  }

  /// Fetches the most recent body weight entry.
  Future<List<HealthDataPoint>> getBodyWeight({
    required DateTime start,
    required DateTime end,
  }) async {
    if (!_isConfigured) return [];

    try {
      return await _health.getHealthDataFromTypes(
        types: [HealthDataType.WEIGHT],
        startTime: start,
        endTime: end,
      );
    } on Exception catch (e) {
      AppLogger.error('Failed to get body weight: $e', 'HealthService');
      return [];
    }
  }

  /// Writes a workout to HealthKit.
  ///
  /// Maps ErgoLife activity sessions to HealthKit workouts
  /// so users can see them in the Apple Health app.
  Future<bool> writeWorkout({
    required HealthWorkoutActivityType activityType,
    required DateTime start,
    required DateTime end,
    required double totalCalories,
  }) async {
    if (!_isConfigured) return false;

    try {
      final success = await _health.writeWorkoutData(
        activityType: activityType,
        start: start,
        end: end,
        totalEnergyBurned: totalCalories.round(),
        totalEnergyBurnedUnit: HealthDataUnit.KILOCALORIE,
      );

      AppLogger.info('Wrote workout to HealthKit: $success', 'HealthService');
      return success;
    } on Exception catch (e) {
      AppLogger.error('Failed to write workout: $e', 'HealthService');
      return false;
    }
  }
}
