import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/leaderboard_model.dart';

/// LeaderboardBloc states
abstract class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class LeaderboardInitial extends LeaderboardState {
  const LeaderboardInitial();
}

/// Loading state
class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading();
}

/// Successfully loaded leaderboard
class LeaderboardLoaded extends LeaderboardState {
  final LeaderboardResponse leaderboard;
  final String currentUserId;

  const LeaderboardLoaded({
    required this.leaderboard,
    required this.currentUserId,
  });

  /// Get top 3 for podium
  List<LeaderboardEntry> get podium => leaderboard.podium;

  /// Get rank 4+ for list
  List<LeaderboardEntry> get runnersUp => leaderboard.runnersUp;

  /// Get current user's rank
  int? get myRank => leaderboard.getUserRank(currentUserId);

  /// Get current user's entry
  LeaderboardEntry? get myEntry => leaderboard.getUserEntry(currentUserId);

  /// Check if an entry is the current user
  bool isMe(LeaderboardEntry entry) => entry.user.id == currentUserId;

  @override
  List<Object?> get props => [leaderboard, currentUserId];
}

/// Error state
class LeaderboardError extends LeaderboardState {
  final String message;

  const LeaderboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
