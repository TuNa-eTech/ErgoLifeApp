import 'package:equatable/equatable.dart';

/// Base class for authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check if user is already authenticated
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Google sign-in requested
class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

/// Apple sign-in requested
class AuthAppleSignInRequested extends AuthEvent {
  const AuthAppleSignInRequested();
}

/// Sign out requested
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
