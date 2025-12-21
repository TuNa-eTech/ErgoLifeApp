import 'package:equatable/equatable.dart';

/// Model representing a completed activity/exercise
class ActivityModel extends Equatable {
  final String id;
  final String userId;
  final String taskName;
  final int durationSeconds;
  final double metsValue;
  final int magicWipePercentage;
  final int pointsEarned;
  final double? bonusMultiplier;
  final DateTime completedAt;

  const ActivityModel({
    required this.id,
    required this.userId,
    required this.taskName,
    required this.durationSeconds,
    required this.metsValue,
    required this.magicWipePercentage,
    required this.pointsEarned,
    this.bonusMultiplier,
    required this.completedAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      taskName: json['taskName'] as String,
      durationSeconds: json['durationSeconds'] as int,
      metsValue: (json['metsValue'] as num).toDouble(),
      magicWipePercentage: json['magicWipePercentage'] as int,
      pointsEarned: json['pointsEarned'] as int,
      bonusMultiplier: json['bonusMultiplier'] != null
          ? (json['bonusMultiplier'] as num).toDouble()
          : null,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'taskName': taskName,
      'durationSeconds': durationSeconds,
      'metsValue': metsValue,
      'magicWipePercentage': magicWipePercentage,
      'pointsEarned': pointsEarned,
      'bonusMultiplier': bonusMultiplier,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  /// Get formatted duration as MM:SS
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get duration in minutes
  int get durationMinutes => durationSeconds ~/ 60;

  @override
  List<Object?> get props => [
        id,
        userId,
        taskName,
        durationSeconds,
        metsValue,
        magicWipePercentage,
        pointsEarned,
        bonusMultiplier,
        completedAt,
      ];
}

/// Request model for creating a new activity
class CreateActivityRequest {
  final String taskName;
  final int durationSeconds;
  final double metsValue;
  final int magicWipePercentage;

  const CreateActivityRequest({
    required this.taskName,
    required this.durationSeconds,
    required this.metsValue,
    required this.magicWipePercentage,
  });

  Map<String, dynamic> toJson() {
    return {
      'taskName': taskName,
      'durationSeconds': durationSeconds,
      'metsValue': metsValue,
      'magicWipePercentage': magicWipePercentage,
    };
  }
}

/// Response model for activity creation
class CreateActivityResponse {
  final ActivityModel activity;
  final WalletInfo wallet;

  const CreateActivityResponse({
    required this.activity,
    required this.wallet,
  });

  factory CreateActivityResponse.fromJson(Map<String, dynamic> json) {
    return CreateActivityResponse(
      activity: ActivityModel.fromJson(json['activity'] as Map<String, dynamic>),
      wallet: WalletInfo.fromJson(json['wallet'] as Map<String, dynamic>),
    );
  }
}

/// Wallet balance information
class WalletInfo {
  final int previousBalance;
  final int pointsEarned;
  final int newBalance;

  const WalletInfo({
    required this.previousBalance,
    required this.pointsEarned,
    required this.newBalance,
  });

  factory WalletInfo.fromJson(Map<String, dynamic> json) {
    return WalletInfo(
      previousBalance: json['previousBalance'] as int,
      pointsEarned: json['pointsEarned'] as int,
      newBalance: json['newBalance'] as int,
    );
  }
}

/// Paginated list of activities
class PaginatedActivities {
  final List<ActivityModel> activities;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PaginatedActivities({
    required this.activities,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginatedActivities.fromJson(Map<String, dynamic> json) {
    return PaginatedActivities(
      activities: (json['activities'] as List)
          .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  bool get hasMore => page < totalPages;
}
