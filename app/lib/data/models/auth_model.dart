import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/user_model.dart';

/// Authentication provider enum
enum AuthProvider {
  google,
  apple;

  String toJson() => name.toUpperCase();

  static AuthProvider fromJson(String value) {
    return AuthProvider.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => AuthProvider.google,
    );
  }
}

/// Authentication response from backend
class AuthResponse extends Equatable {
  final String accessToken;
  final UserModel user;
  final bool isNewUser;

  const AuthResponse({
    required this.accessToken,
    required this.user,
    required this.isNewUser,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      isNewUser: json['isNewUser'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'user': user.toJson(),
      'isNewUser': isNewUser,
    };
  }

  @override
  List<Object?> get props => [accessToken, user, isNewUser];
}
