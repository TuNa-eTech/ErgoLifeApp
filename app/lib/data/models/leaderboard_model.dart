import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/user_model.dart';

/// Leaderboard scope: house (family) or global (all users)
enum LeaderboardScope {
  house,
  global;

  static LeaderboardScope fromString(String? value) {
    return LeaderboardScope.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LeaderboardScope.house,
    );
  }
}

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
      rank: json['rank'] as int? ?? 0,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      weeklyPoints: json['weeklyPoints'] as int? ?? 0,
      activityCount: json['activityCount'] as int? ?? 0,
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

/// Current user's ranking info (simplified, without full user object)
class MyRanking extends Equatable {
  final int rank;
  final int weeklyPoints;
  final int activityCount;

  const MyRanking({
    required this.rank,
    required this.weeklyPoints,
    required this.activityCount,
  });

  factory MyRanking.fromJson(Map<String, dynamic> json) {
    return MyRanking(
      rank: json['rank'] as int? ?? 0,
      weeklyPoints: json['weeklyPoints'] as int? ?? 0,
      activityCount: json['activityCount'] as int? ?? 0,
    );
  }

  /// Format points with comma separator
  String get formattedPoints {
    if (weeklyPoints >= 1000) {
      return '${(weeklyPoints / 1000).toStringAsFixed(1)}k';
    }
    return weeklyPoints.toString();
  }

  @override
  List<Object?> get props => [rank, weeklyPoints, activityCount];
}

/// Complete leaderboard response
class LeaderboardResponse extends Equatable {
  final LeaderboardScope scope;
  final String week;
  final DateTime weekStart;
  final DateTime weekEnd;
  final String? houseName;
  final List<LeaderboardEntry> rankings;
  final MyRanking? myRanking;
  final int totalParticipants;

  const LeaderboardResponse({
    required this.scope,
    required this.week,
    required this.weekStart,
    required this.weekEnd,
    this.houseName,
    required this.rankings,
    this.myRanking,
    required this.totalParticipants,
  });

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) {
    return LeaderboardResponse(
      scope: LeaderboardScope.fromString(json['scope'] as String?),
      week: json['week'] as String? ?? 'current',
      weekStart: json['weekStart'] != null
          ? DateTime.parse(json['weekStart'] as String)
          : DateTime.now(),
      weekEnd: json['weekEnd'] != null
          ? DateTime.parse(json['weekEnd'] as String)
          : DateTime.now(),
      houseName: json['houseName'] as String?,
      rankings: (json['rankings'] as List?)
              ?.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      myRanking: json['myRanking'] != null
          ? MyRanking.fromJson(json['myRanking'] as Map<String, dynamic>)
          : null,
      totalParticipants: json['totalParticipants'] as int? ?? 0,
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
  List<Object?> get props => [
        scope,
        week,
        weekStart,
        weekEnd,
        houseName,
        rankings,
        myRanking,
        totalParticipants,
      ];
}
