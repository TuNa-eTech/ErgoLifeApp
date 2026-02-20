import 'package:equatable/equatable.dart';

/// Events for [DailyGoalBloc].
abstract class DailyGoalEvent extends Equatable {
  const DailyGoalEvent();

  @override
  List<Object?> get props => [];
}

/// Load today's daily goal progress.
class LoadTodayGoal extends DailyGoalEvent {
  const LoadTodayGoal();
}

/// Refresh today's goal (e.g. after completing an activity).
class RefreshGoal extends DailyGoalEvent {
  const RefreshGoal();
}

/// Update user's default goal settings.
class UpdateGoalSettings extends DailyGoalEvent {
  final int? targetEp;
  final int? targetDuration;
  final int? targetActivities;

  const UpdateGoalSettings({
    this.targetEp,
    this.targetDuration,
    this.targetActivities,
  });

  @override
  List<Object?> get props => [targetEp, targetDuration, targetActivities];
}
