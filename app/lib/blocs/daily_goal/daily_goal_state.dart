import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/daily_goal_model.dart';

/// States for [DailyGoalBloc].
abstract class DailyGoalState extends Equatable {
  const DailyGoalState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading.
class DailyGoalInitial extends DailyGoalState {
  const DailyGoalInitial();
}

/// Loading state.
class DailyGoalLoading extends DailyGoalState {
  const DailyGoalLoading();
}

/// Successfully loaded today's goal.
class DailyGoalLoaded extends DailyGoalState {
  final DailyGoalModel goal;

  const DailyGoalLoaded({required this.goal});

  @override
  List<Object?> get props => [goal];
}

/// Error state.
class DailyGoalError extends DailyGoalState {
  final String message;

  const DailyGoalError({required this.message});

  @override
  List<Object?> get props => [message];
}
