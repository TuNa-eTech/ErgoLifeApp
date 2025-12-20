import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/auth/auth_event.dart';
import 'package:ergo_life_app/blocs/auth/auth_state.dart';
import 'package:ergo_life_app/data/repositories/auth_repository.dart';
import 'package:ergo_life_app/core/utils/logger.dart';

/// BLoC for managing authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthAppleSignInRequested>(_onAppleSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  /// Handle authentication check request
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Checking authentication status', 'AuthBloc');
    emit(const AuthLoading());

    // Check if user has stored token
    if (!_authRepository.hasStoredToken()) {
      AppLogger.info('No stored token found', 'AuthBloc');
      emit(const AuthUnauthenticated());
      return;
    }

    // Try to get current user with stored token
    final result = await _authRepository.getCurrentUser();

    result.fold(
      (failure) {
        AppLogger.warning(
          'Auto sign-in failed: ${failure.message}',
          'AuthBloc',
        );
        emit(const AuthUnauthenticated());
      },
      (user) {
        final token = _authRepository.getStoredToken()!;
        AppLogger.success('Auto sign-in successful', 'AuthBloc');
        emit(AuthAuthenticated(user: user, token: token));
      },
    );
  }

  /// Handle Google sign-in request
  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Google sign-in requested', 'AuthBloc');
    emit(const AuthLoading());

    final result = await _authRepository.signInWithGoogle();

    result.fold(
      (failure) {
        AppLogger.error(
          'Google sign-in failed',
          failure.message,
          null,
          'AuthBloc',
        );
        emit(AuthError(message: failure.message));
      },
      (user) {
        final token = _authRepository.getStoredToken()!;
        AppLogger.success('Google sign-in successful', 'AuthBloc');
        emit(AuthAuthenticated(user: user, token: token));
      },
    );
  }

  /// Handle Apple sign-in request
  Future<void> _onAppleSignInRequested(
    AuthAppleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Apple sign-in requested', 'AuthBloc');
    emit(const AuthLoading());

    final result = await _authRepository.signInWithApple();

    result.fold(
      (failure) {
        AppLogger.error(
          'Apple sign-in failed',
          failure.message,
          null,
          'AuthBloc',
        );
        emit(AuthError(message: failure.message));
      },
      (user) {
        final token = _authRepository.getStoredToken()!;
        AppLogger.success('Apple sign-in successful', 'AuthBloc');
        emit(AuthAuthenticated(user: user, token: token));
      },
    );
  }

  /// Handle sign-out request
  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Sign-out requested', 'AuthBloc');
    emit(const AuthLoading());

    await _authRepository.signOut();

    AppLogger.success('Sign-out successful', 'AuthBloc');
    emit(const AuthUnauthenticated());
  }
}
