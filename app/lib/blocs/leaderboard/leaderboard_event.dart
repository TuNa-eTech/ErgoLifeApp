import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/leaderboard_model.dart';

/// LeaderboardBloc events
abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load leaderboard for current or specific week
class LoadLeaderboard extends LeaderboardEvent {
  final String? week;
  final LeaderboardScope? scope;

  const LoadLeaderboard({this.week, this.scope});

  @override
  List<Object?> get props => [week, scope];
}

/// Refresh leaderboard (pull-to-refresh)
class RefreshLeaderboard extends LeaderboardEvent {
  const RefreshLeaderboard();
}
