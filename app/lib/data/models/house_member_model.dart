import 'package:equatable/equatable.dart';

/// Simple model for a house member shown in the gift recipient picker.
class HouseMemberModel extends Equatable {
  final String id;
  final String? displayName;
  final int? avatarId;

  const HouseMemberModel({required this.id, this.displayName, this.avatarId});

  factory HouseMemberModel.fromJson(Map<String, dynamic> json) {
    return HouseMemberModel(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String?,
      avatarId: json['avatarId'] as int?,
    );
  }

  @override
  List<Object?> get props => [id, displayName, avatarId];
}
