import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/user_model.dart';

/// Leaderboard entry for a single user
class LeaderboardEntry extends Equatable {
  final int rank;
  final UserModel user;
  final int weeklyPoints;
  final int activityCount;

  const LeaderboardEntry({
    required this.rank,
    required this.user,
    required this.weeklyPoints,
    required this.activityCount,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      weeklyPoints: json['weeklyPoints'] as int,
      activityCount: json['activityCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'user': user.toJson(),
      'weeklyPoints': weeklyPoints,
      'activityCount': activityCount,
    };
  }

  /// Format points with comma separator
  String get formattedPoints {
    if (weeklyPoints >= 1000) {
      return '${(weeklyPoints / 1000).toStringAsFixed(1)}k';
    }
    return weeklyPoints.toString();
  }

  @override
  List<Object?> get props => [rank, user, weeklyPoints, activityCount];
}

/// Complete leaderboard response
class LeaderboardResponse extends Equatable {
  final String week;
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<LeaderboardEntry> rankings;

  const LeaderboardResponse({
    required this.week,
    required this.weekStart,
    required this.weekEnd,
    required this.rankings,
  });

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) {
    return LeaderboardResponse(
      week: json['week'] as String,
      weekStart: DateTime.parse(json['weekStart'] as String),
      weekEnd: DateTime.parse(json['weekEnd'] as String),
      rankings: (json['rankings'] as List)
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get podium entries (top 3)
  List<LeaderboardEntry> get podium => rankings.take(3).toList();

  /// Get runners up (rank 4+)
  List<LeaderboardEntry> get runnersUp => rankings.skip(3).toList();

  /// Find current user's rank
  int? getUserRank(String userId) {
    final index = rankings.indexWhere((e) => e.user.id == userId);
    return index >= 0 ? index + 1 : null;
  }

  /// Find current user's entry
  LeaderboardEntry? getUserEntry(String userId) {
    try {
      return rankings.firstWhere((e) => e.user.id == userId);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [week, weekStart, weekEnd, rankings];
}
