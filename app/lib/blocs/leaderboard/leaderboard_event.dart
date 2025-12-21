import 'package:equatable/equatable.dart';

/// LeaderboardBloc events
abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load leaderboard for current or specific week
class LoadLeaderboard extends LeaderboardEvent {
  final String? week;

  const LoadLeaderboard({this.week});

  @override
  List<Object?> get props => [week];
}

/// Refresh leaderboard (pull-to-refresh)
class RefreshLeaderboard extends LeaderboardEvent {
  const RefreshLeaderboard();
}
