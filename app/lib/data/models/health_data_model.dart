import 'package:equatable/equatable.dart';

/// Health data captured during an activity session.
///
/// Contains real-time metrics from HealthKit if available,
/// with a [dataSource] field to distinguish between
/// estimated values and actual health data.
class SessionHealthData extends Equatable {
  /// Average heart rate during the session in bpm.
  final double? avgHeartRate;

  /// Maximum heart rate during the session in bpm.
  final double? maxHeartRate;

  /// Actual calories burned as reported by HealthKit.
  final double? realCaloriesBurned;

  /// Total steps recorded during the session.
  final int? steps;

  /// Source of the data: "healthkit" (iOS),
  /// "health_connect" (Android), or "estimate".
  final String dataSource;

  const SessionHealthData({
    this.avgHeartRate,
    this.maxHeartRate,
    this.realCaloriesBurned,
    this.steps,
    this.dataSource = 'estimate',
  });

  /// Whether real health data is available (from HealthKit
  /// on iOS or Health Connect on Android).
  bool get hasRealData =>
      dataSource == 'healthkit' || dataSource == 'health_connect';

  /// Creates a copy with updated fields.
  SessionHealthData copyWith({
    double? avgHeartRate,
    double? maxHeartRate,
    double? realCaloriesBurned,
    int? steps,
    String? dataSource,
  }) {
    return SessionHealthData(
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      realCaloriesBurned: realCaloriesBurned ?? this.realCaloriesBurned,
      steps: steps ?? this.steps,
      dataSource: dataSource ?? this.dataSource,
    );
  }

  /// Converts to JSON for API payload.
  Map<String, dynamic> toJson() {
    return {
      if (avgHeartRate != null) 'avgHeartRate': avgHeartRate,
      if (maxHeartRate != null) 'maxHeartRate': maxHeartRate,
      if (realCaloriesBurned != null) 'realCaloriesBurned': realCaloriesBurned,
      if (steps != null) 'steps': steps,
      'dataSource': dataSource,
    };
  }

  @override
  List<Object?> get props => [
    avgHeartRate,
    maxHeartRate,
    realCaloriesBurned,
    steps,
    dataSource,
  ];
}

/// Daily health summary for home screen dashboard.
class DailyHealthSummary extends Equatable {
  /// Total steps today.
  final int? steps;

  /// Total active calories burned today.
  final double? activeCalories;

  /// Average resting heart rate today.
  final double? avgRestingHeartRate;

  /// Minutes of active exercise today.
  final int? activeMinutes;

  const DailyHealthSummary({
    this.steps,
    this.activeCalories,
    this.avgRestingHeartRate,
    this.activeMinutes,
  });

  /// Whether any health data is available.
  bool get hasData =>
      steps != null || activeCalories != null || avgRestingHeartRate != null;

  @override
  List<Object?> get props => [
    steps,
    activeCalories,
    avgRestingHeartRate,
    activeMinutes,
  ];
}
