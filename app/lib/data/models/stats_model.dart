import 'package:equatable/equatable.dart';

/// Statistics for a specific period
class StatsModel extends Equatable {
  final String period; // 'day', 'week', 'month', 'all'
  final int totalPoints;
  final int activityCount;
  final int totalDurationMinutes;
  final int streakDays;
  final double averagePointsPerActivity;

  const StatsModel({
    required this.period,
    required this.totalPoints,
    required this.activityCount,
    required this.totalDurationMinutes,
    required this.streakDays,
    required this.averagePointsPerActivity,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    return StatsModel(
      period: json['period'] as String,
      totalPoints: json['totalPoints'] as int,
      activityCount: json['activityCount'] as int,
      totalDurationMinutes: json['totalDurationMinutes'] as int,
      streakDays: json['streakDays'] as int,
      averagePointsPerActivity:
          (json['averagePointsPerActivity'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'totalPoints': totalPoints,
      'activityCount': activityCount,
      'totalDurationMinutes': totalDurationMinutes,
      'streakDays': streakDays,
      'averagePointsPerActivity': averagePointsPerActivity,
    };
  }

  /// Get formatted points (e.g., 14.2k)
  String get formattedPoints {
    if (totalPoints >= 1000) {
      return '${(totalPoints / 1000).toStringAsFixed(1)}k';
    }
    return totalPoints.toString();
  }

  /// Get total hours from duration
  String get formattedDuration {
    final hours = totalDurationMinutes ~/ 60;
    final minutes = totalDurationMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  List<Object?> get props => [
        period,
        totalPoints,
        activityCount,
        totalDurationMinutes,
        streakDays,
        averagePointsPerActivity,
      ];
}

/// Weekly stats specifically for home screen
class WeeklyStats extends Equatable {
  final int totalPoints;
  final int activityCount;
  final int totalDurationMinutes;
  final int streakDays;
  final int rankPosition;
  final int houseMemberCount;

  const WeeklyStats({
    required this.totalPoints,
    required this.activityCount,
    required this.totalDurationMinutes,
    required this.streakDays,
    required this.rankPosition,
    required this.houseMemberCount,
  });

  factory WeeklyStats.fromJson(Map<String, dynamic> json) {
    return WeeklyStats(
      totalPoints: json['totalPoints'] as int,
      activityCount: json['activityCount'] as int,
      totalDurationMinutes: json['totalDurationMinutes'] as int,
      streakDays: json['streakDays'] as int,
      rankPosition: json['rankPosition'] as int? ?? 0,
      houseMemberCount: json['houseMemberCount'] as int? ?? 1,
    );
  }

  /// For empty/default state
  factory WeeklyStats.empty() {
    return const WeeklyStats(
      totalPoints: 0,
      activityCount: 0,
      totalDurationMinutes: 0,
      streakDays: 0,
      rankPosition: 0,
      houseMemberCount: 1,
    );
  }

  String get formattedPoints {
    if (totalPoints >= 1000) {
      return '${(totalPoints / 1000).toStringAsFixed(1)}k';
    }
    return totalPoints.toString();
  }

  @override
  List<Object?> get props => [
        totalPoints,
        activityCount,
        totalDurationMinutes,
        streakDays,
        rankPosition,
        houseMemberCount,
      ];
}

/// Lifetime stats for profile
class LifetimeStats extends Equatable {
  final int totalPoints;
  final int totalActivities;
  final int totalMinutes;
  final int currentStreak;
  final int longestStreak;
  final int estimatedCalories;

  const LifetimeStats({
    required this.totalPoints,
    required this.totalActivities,
    required this.totalMinutes,
    required this.currentStreak,
    required this.longestStreak,
    required this.estimatedCalories,
  });

  factory LifetimeStats.fromJson(Map<String, dynamic> json) {
    return LifetimeStats(
      totalPoints: json['totalPoints'] as int,
      totalActivities: json['totalActivities'] as int,
      totalMinutes: json['totalMinutes'] as int,
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      estimatedCalories: json['estimatedCalories'] as int? ?? 0,
    );
  }

  factory LifetimeStats.empty() {
    return const LifetimeStats(
      totalPoints: 0,
      totalActivities: 0,
      totalMinutes: 0,
      currentStreak: 0,
      longestStreak: 0,
      estimatedCalories: 0,
    );
  }

  String get formattedPoints {
    if (totalPoints >= 1000) {
      return '${(totalPoints / 1000).toStringAsFixed(1)}k';
    }
    return totalPoints.toString();
  }

  String get formattedHours {
    final hours = totalMinutes ~/ 60;
    return '${hours}h';
  }

  @override
  List<Object?> get props => [
        totalPoints,
        totalActivities,
        totalMinutes,
        currentStreak,
        longestStreak,
        estimatedCalories,
      ];
}
