import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/leaderboard_model.dart';

/// LeaderboardBloc events
abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load leaderboard for current or specific month
class LoadLeaderboard extends LeaderboardEvent {
  final int? month;
  final int? year;
  final LeaderboardScope? scope;

  const LoadLeaderboard({this.month, this.year, this.scope});

  @override
  List<Object?> get props => [month, year, scope];
}

/// Refresh leaderboard (pull-to-refresh)
class RefreshLeaderboard extends LeaderboardEvent {
  const RefreshLeaderboard();
}
