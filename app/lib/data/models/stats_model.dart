import 'package:equatable/equatable.dart';

/// Statistics for a specific period
class StatsModel extends Equatable {
  final String period; // 'day', 'week', 'month', 'all'
  final int totalPoints;
  final int activityCount;
  final int totalDurationMinutes;
  final int streakDays;
  final double averagePointsPerActivity;

  final int estimatedCalories;
  final List<TopTask> topTasks;

  const StatsModel({
    required this.period,
    required this.totalPoints,
    required this.activityCount,
    required this.totalDurationMinutes,
    required this.streakDays,
    required this.averagePointsPerActivity,
    this.estimatedCalories = 0,
    this.topTasks = const [],
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    return StatsModel(
      period: json['period'] as String? ?? 'week',
      totalPoints: json['totalPoints'] as int? ?? 0,
      activityCount:
          json['activityCount'] as int? ??
          0, // This is 'totalActivities' in API DTO? Key mismatch check
      totalDurationMinutes: ((json['totalDuration'] as int? ?? 0) / 60)
          .round(), // API sends seconds (totalDuration) or minutes? Backend DTO says totalDuration (seconds? no DTO Service calc: agg._sum.durationSeconds. But Service returns totalDuration: agg._sum.durationSeconds).
      // Wait, backend service says: type StatsResponseDto has totalDuration.
      // In service: totalDuration: agg._sum.durationSeconds || 0. So it is SECONDS.
      // Helper getter formattedDuration in StatsModel expects totalDurationMinutes.
      // So I should convert seconds to minutes here.
      streakDays: json['streak'] is Map
          ? (json['streak']['current'] as int? ?? 0)
          : (json['streakDays'] as int? ?? 0),
      averagePointsPerActivity: json['averagePointsPerActivity'] != null
          ? (json['averagePointsPerActivity'] as num).toDouble()
          : (json['totalActivities'] != null && json['totalActivities'] > 0)
          ? (json['totalPoints'] as int) / (json['totalActivities'] as int)
          : 0.0,
      estimatedCalories: json['estimatedCalories'] as int? ?? 0,
      topTasks:
          (json['topTasks'] as List?)
              ?.map((e) => TopTask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'totalPoints': totalPoints,
      'activityCount': activityCount,
      'totalDuration': totalDurationMinutes * 60, // convert back to seconds
      'streak': {'current': streakDays},
      'estimatedCalories': estimatedCalories,
      'topTasks': topTasks.map((e) => e.toJson()).toList(),
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
    estimatedCalories,
    topTasks,
  ];
}

class TopTask extends Equatable {
  final String taskName;
  final int count;
  final int totalPoints;
  final int totalDurationMinutes;

  const TopTask({
    required this.taskName,
    required this.count,
    required this.totalPoints,
    required this.totalDurationMinutes,
  });

  factory TopTask.fromJson(Map<String, dynamic> json) {
    return TopTask(
      taskName: json['taskName'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      totalPoints: json['totalPoints'] as int? ?? 0,
      totalDurationMinutes: ((json['totalDuration'] as int? ?? 0) / 60).round(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskName': taskName,
      'count': count,
      'totalPoints': totalPoints,
      'totalDuration': totalDurationMinutes * 60,
    };
  }

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
    taskName,
    count,
    totalPoints,
    totalDurationMinutes,
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
      totalPoints: json['totalPoints'] as int? ?? 0,
      activityCount: json['activityCount'] as int? ?? 0,
      totalDurationMinutes: json['totalDurationMinutes'] as int? ?? 0,
      streakDays: json['streakDays'] as int? ?? 0,
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
