import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/user_model.dart';

/// Model representing a House (group/team)
class HouseModel extends Equatable {
  final String id;
  final String name;
  final String inviteCode;
  final String ownerId;
  final DateTime createdAt;
  final List<HouseMember>? members;

  const HouseModel({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.ownerId,
    required this.createdAt,
    this.members,
  });

  factory HouseModel.fromJson(Map<String, dynamic> json) {
    return HouseModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed House',
      inviteCode: json['inviteCode'] as String? ?? '',
      // API returns 'createdBy' instead of 'ownerId'
      ownerId: (json['ownerId'] ?? json['createdBy']) as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      members: json['members'] != null
          ? (json['members'] as List)
              .map((e) => HouseMember.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'inviteCode': inviteCode,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'members': members?.map((e) => e.toJson()).toList(),
    };
  }

  /// Get member count
  int get memberCount => members?.length ?? 0;

  /// Check if current user is owner
  bool isOwner(String userId) => ownerId == userId;

  @override
  List<Object?> get props => [id, name, inviteCode, ownerId, createdAt, members];
}

/// Model representing a house member
class HouseMember extends Equatable {
  final UserModel user;
  final int weeklyPoints;
  final int totalPoints;
  final String role; // 'owner' | 'member'
  final DateTime joinedAt;

  const HouseMember({
    required this.user,
    required this.weeklyPoints,
    required this.totalPoints,
    required this.role,
    required this.joinedAt,
  });

  factory HouseMember.fromJson(Map<String, dynamic> json) {
    // API may return flat member object or nested 'user' object
    final userData = json['user'] as Map<String, dynamic>? ?? json;
    
    return HouseMember(
      user: UserModel.fromJson(userData),
      weeklyPoints: json['weeklyPoints'] as int? ?? 0,
      totalPoints: json['totalPoints'] as int? ?? 0,
      role: json['role'] as String? ?? 'member',
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'weeklyPoints': weeklyPoints,
      'totalPoints': totalPoints,
      'role': role,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  bool get isOwner => role == 'owner';

  @override
  List<Object?> get props => [user, weeklyPoints, totalPoints, role, joinedAt];
}

/// House invite details
class HouseInvite {
  final String inviteCode;
  final String inviteLink;
  final DateTime expiresAt;

  const HouseInvite({
    required this.inviteCode,
    required this.inviteLink,
    required this.expiresAt,
  });

  factory HouseInvite.fromJson(Map<String, dynamic> json) {
    return HouseInvite(
      inviteCode: json['inviteCode'] as String,
      inviteLink: json['inviteLink'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}

/// House preview (before joining)
class HousePreview {
  final String name;
  final int memberCount;
  final String ownerName;

  const HousePreview({
    required this.name,
    required this.memberCount,
    required this.ownerName,
  });

  factory HousePreview.fromJson(Map<String, dynamic> json) {
    return HousePreview(
      name: json['name'] as String,
      memberCount: json['memberCount'] as int,
      ownerName: json['ownerName'] as String,
    );
  }
}

/// Request to create a house
class CreateHouseRequest {
  final String name;

  const CreateHouseRequest({required this.name});

  Map<String, dynamic> toJson() => {'name': name};
}

/// Request to join a house
class JoinHouseRequest {
  final String inviteCode;

  const JoinHouseRequest({required this.inviteCode});

  Map<String, dynamic> toJson() => {'inviteCode': inviteCode};
}
