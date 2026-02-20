import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/daily_goal/daily_goal_event.dart';
import 'package:ergo_life_app/blocs/daily_goal/daily_goal_state.dart';
import 'package:ergo_life_app/data/models/daily_goal_model.dart';
import 'package:ergo_life_app/data/repositories/daily_goal_repository.dart';

/// BLoC for managing daily goal ring state.
class DailyGoalBloc extends Bloc<DailyGoalEvent, DailyGoalState> {
  final DailyGoalRepository _repository;

  DailyGoalBloc(this._repository) : super(const DailyGoalInitial()) {
    on<LoadTodayGoal>(_onLoadTodayGoal);
    on<RefreshGoal>(_onRefreshGoal);
    on<UpdateGoalSettings>(_onUpdateGoalSettings);
  }

  Future<void> _onLoadTodayGoal(
    LoadTodayGoal event,
    Emitter<DailyGoalState> emit,
  ) async {
    emit(const DailyGoalLoading());
    final result = await _repository.getTodayGoal();
    result.fold(
      (failure) => emit(DailyGoalError(message: failure.message)),
      (goal) => emit(DailyGoalLoaded(goal: goal)),
    );
  }

  Future<void> _onRefreshGoal(
    RefreshGoal event,
    Emitter<DailyGoalState> emit,
  ) async {
    // Don't show loading spinner on refresh —
    // keep current state visible.
    final result = await _repository.getTodayGoal();
    result.fold(
      (_) {}, // Silently ignore errors on refresh
      (goal) => emit(DailyGoalLoaded(goal: goal)),
    );
  }

  Future<void> _onUpdateGoalSettings(
    UpdateGoalSettings event,
    Emitter<DailyGoalState> emit,
  ) async {
    final settings = GoalSettingsModel(
      targetEp: event.targetEp ?? 500,
      targetDuration: event.targetDuration ?? 30,
      targetActivities: event.targetActivities ?? 2,
    );

    final result = await _repository.updateGoalSettings(settings);
    result.fold((failure) => emit(DailyGoalError(message: failure.message)), (
      _,
    ) {
      // After settings update, reload today's goal
      add(const LoadTodayGoal());
    });
  }
}
