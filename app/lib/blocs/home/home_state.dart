import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/user_model.dart';
import 'package:ergo_life_app/data/models/stats_model.dart';
import 'package:ergo_life_app/data/models/house_model.dart';
import 'package:ergo_life_app/data/models/task_model.dart';

/// HomeBloc states
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Loading state
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Successfully loaded home data
class HomeLoaded extends HomeState {
  final UserModel user;
  final WeeklyStats stats;
  final HouseModel? house;
  final List<TaskModel> quickTasks;

  const HomeLoaded({
    required this.user,
    required this.stats,
    this.house,
    required this.quickTasks,
  });

  /// Get greeting based on time of day
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// Get user's first name
  String get firstName {
    final name = user.name ?? 'User';
    return name.split(' ').first;
  }

  /// Get rank position display
  String get rankDisplay {
    if (stats.rankPosition <= 0) return '-';
    return '#${stats.rankPosition}';
  }

  HomeLoaded copyWith({
    UserModel? user,
    WeeklyStats? stats,
    HouseModel? house,
    List<TaskModel>? quickTasks,
  }) {
    return HomeLoaded(
      user: user ?? this.user,
      stats: stats ?? this.stats,
      house: house ?? this.house,
      quickTasks: quickTasks ?? this.quickTasks,
    );
  }

  @override
  List<Object?> get props => [user, stats, house, quickTasks];
}

/// Error state
class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
