import 'package:equatable/equatable.dart';

/// Model representing a user's daily goal progress.
///
/// Contains target values and current progress for three metrics:
/// EP (points), Duration (minutes), and Activities (count).
class DailyGoalModel extends Equatable {
  final String id;
  final String date;
  final int targetEp;
  final int targetDuration;
  final int targetActivities;
  final int currentEp;
  final int currentDuration;
  final int currentActivities;
  final bool isPerfectDay;
  final String? completedAt;
  final double epProgress;
  final double durationProgress;
  final double activitiesProgress;

  const DailyGoalModel({
    required this.id,
    required this.date,
    required this.targetEp,
    required this.targetDuration,
    required this.targetActivities,
    required this.currentEp,
    required this.currentDuration,
    required this.currentActivities,
    required this.isPerfectDay,
    this.completedAt,
    required this.epProgress,
    required this.durationProgress,
    required this.activitiesProgress,
  });

  /// Whether the EP ring is fully closed.
  bool get isEpClosed => currentEp >= targetEp;

  /// Whether the Duration ring is fully closed.
  bool get isDurationClosed => currentDuration >= targetDuration;

  /// Whether the Activities ring is fully closed.
  bool get isActivitiesClosed => currentActivities >= targetActivities;

  factory DailyGoalModel.fromJson(Map<String, dynamic> json) {
    return DailyGoalModel(
      id: json['id'] as String,
      date: json['date'] as String,
      targetEp: json['targetEp'] as int,
      targetDuration: json['targetDuration'] as int,
      targetActivities: json['targetActivities'] as int,
      currentEp: json['currentEp'] as int,
      currentDuration: json['currentDuration'] as int,
      currentActivities: json['currentActivities'] as int,
      isPerfectDay: json['isPerfectDay'] as bool,
      completedAt: json['completedAt'] as String?,
      epProgress: (json['epProgress'] as num).toDouble(),
      durationProgress: (json['durationProgress'] as num).toDouble(),
      activitiesProgress: (json['activitiesProgress'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'targetEp': targetEp,
    'targetDuration': targetDuration,
    'targetActivities': targetActivities,
    'currentEp': currentEp,
    'currentDuration': currentDuration,
    'currentActivities': currentActivities,
    'isPerfectDay': isPerfectDay,
    'completedAt': completedAt,
    'epProgress': epProgress,
    'durationProgress': durationProgress,
    'activitiesProgress': activitiesProgress,
  };

  DailyGoalModel copyWith({
    String? id,
    String? date,
    int? targetEp,
    int? targetDuration,
    int? targetActivities,
    int? currentEp,
    int? currentDuration,
    int? currentActivities,
    bool? isPerfectDay,
    String? completedAt,
    double? epProgress,
    double? durationProgress,
    double? activitiesProgress,
  }) {
    return DailyGoalModel(
      id: id ?? this.id,
      date: date ?? this.date,
      targetEp: targetEp ?? this.targetEp,
      targetDuration: targetDuration ?? this.targetDuration,
      targetActivities: targetActivities ?? this.targetActivities,
      currentEp: currentEp ?? this.currentEp,
      currentDuration: currentDuration ?? this.currentDuration,
      currentActivities: currentActivities ?? this.currentActivities,
      isPerfectDay: isPerfectDay ?? this.isPerfectDay,
      completedAt: completedAt ?? this.completedAt,
      epProgress: epProgress ?? this.epProgress,
      durationProgress: durationProgress ?? this.durationProgress,
      activitiesProgress: activitiesProgress ?? this.activitiesProgress,
    );
  }

  @override
  List<Object?> get props => [
    id,
    date,
    targetEp,
    targetDuration,
    targetActivities,
    currentEp,
    currentDuration,
    currentActivities,
    isPerfectDay,
    completedAt,
    epProgress,
    durationProgress,
    activitiesProgress,
  ];
}

/// Model representing a user's default daily goal targets.
class GoalSettingsModel extends Equatable {
  final int targetEp;
  final int targetDuration;
  final int targetActivities;

  const GoalSettingsModel({
    required this.targetEp,
    required this.targetDuration,
    required this.targetActivities,
  });

  factory GoalSettingsModel.fromJson(Map<String, dynamic> json) {
    return GoalSettingsModel(
      targetEp: json['targetEp'] as int,
      targetDuration: json['targetDuration'] as int,
      targetActivities: json['targetActivities'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'targetEp': targetEp,
    'targetDuration': targetDuration,
    'targetActivities': targetActivities,
  };

  GoalSettingsModel copyWith({
    int? targetEp,
    int? targetDuration,
    int? targetActivities,
  }) {
    return GoalSettingsModel(
      targetEp: targetEp ?? this.targetEp,
      targetDuration: targetDuration ?? this.targetDuration,
      targetActivities: targetActivities ?? this.targetActivities,
    );
  }

  @override
  List<Object?> get props => [targetEp, targetDuration, targetActivities];
}
