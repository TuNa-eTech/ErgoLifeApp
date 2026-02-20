import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/badge_model.dart';

/// States for the AchievementBloc.
abstract class AchievementState extends Equatable {
  const AchievementState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded.
class AchievementInitial extends AchievementState {
  const AchievementInitial();
}

/// Loading state while fetching badges.
class AchievementLoading extends AchievementState {
  const AchievementLoading();
}

/// Loaded state with the full badge list.
class AchievementLoaded extends AchievementState {
  final List<BadgeModel> badges;
  final int earnedCount;
  final int totalCount;

  const AchievementLoaded({
    required this.badges,
    required this.earnedCount,
    required this.totalCount,
  });

  @override
  List<Object?> get props => [badges, earnedCount, totalCount];
}

/// Error state.
class AchievementError extends AchievementState {
  final String message;

  const AchievementError({required this.message});

  @override
  List<Object?> get props => [message];
}
