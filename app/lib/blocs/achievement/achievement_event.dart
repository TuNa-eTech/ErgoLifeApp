import 'package:equatable/equatable.dart';

/// Events for the AchievementBloc.
abstract class AchievementEvent extends Equatable {
  const AchievementEvent();

  @override
  List<Object?> get props => [];
}

/// Load all badges with earned/locked status.
class LoadAllBadges extends AchievementEvent {
  const LoadAllBadges();
}

/// Refresh badges silently (no loading spinner).
class RefreshBadges extends AchievementEvent {
  const RefreshBadges();
}
