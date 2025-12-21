import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/auth_model.dart';

class UserModel extends Equatable {
  final String id;
  final String firebaseUid;
  final AuthProvider provider;
  final String? email;
  final String? name;
  final int? avatarId;
  final String? avatarUrl;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.firebaseUid,
    required this.provider,
    this.email,
    this.name,
    this.avatarId,
    this.avatarUrl,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      firebaseUid: json['firebaseUid'] as String,
      provider: AuthProvider.fromJson(json['provider'] as String),
      email: json['email'] as String?,
      name: json['displayName'] as String?, // Backend uses 'displayName' not 'name'
      avatarId: json['avatarId'] as int?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebaseUid': firebaseUid,
      'provider': provider.toJson(),
      'email': email,
      'name': name,
      'avatarId': avatarId,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  String toJsonString() => json.encode(toJson());

  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(json.decode(jsonString));
  }

  UserModel copyWith({
    String? id,
    String? firebaseUid,
    AuthProvider? provider,
    String? email,
    String? name,
    int? avatarId,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      provider: provider ?? this.provider,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarId: avatarId ?? this.avatarId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, firebaseUid, provider, email, name, avatarId, avatarUrl, createdAt];
}
