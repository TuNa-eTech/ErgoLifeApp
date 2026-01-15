import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';

/// Service for handling authentication with Firebase using social providers.
/// Supports Google Sign-In and Sign In with Apple.
class AuthService {
  static final _log = Logger('AuthService');

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  /// Subscription to Google authentication events
  StreamSubscription<GoogleSignInAuthenticationEvent>? _googleAuthSubscription;

  /// Completer for the current Google sign-in attempt
  Completer<UserCredential>? _googleSignInCompleter;

  AuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _auth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Returns the currently signed-in user, or null if not signed in.
  User? get currentUser => _auth.currentUser;

  /// Initializes the Google Sign-In SDK.
  /// This must be called before attempting to sign in with Google.
  ///
  /// [clientId] is required for iOS and web platforms.
  /// [serverClientId] is optional, used if you need a server auth code.
  Future<void> initializeGoogleSignIn({
    String? clientId,
    String? serverClientId,
  }) async {
    _log.info('Initializing Google Sign-In');

    await _googleSignIn.initialize(
      clientId: clientId,
      serverClientId: serverClientId,
    );

    // Listen to authentication events
    _googleAuthSubscription = _googleSignIn.authenticationEvents.listen(
      _handleGoogleAuthEvent,
      onError: _handleGoogleAuthError,
    );

    // Attempt lightweight authentication (silent sign-in)
    await _googleSignIn.attemptLightweightAuthentication();

    _log.info('Google Sign-In initialized');
  }

  void _handleGoogleAuthEvent(GoogleSignInAuthenticationEvent event) async {
    _log.info('Google auth event: ${event.runtimeType}');

    switch (event) {
      case GoogleSignInAuthenticationEventSignIn(:final user):
        try {
          // Get the authentication tokens from the user
          final authentication = user.authentication;
          final idToken = authentication.idToken;

          if (idToken == null) {
            _googleSignInCompleter?.completeError(
              FirebaseAuthException._(
                code: 'no-id-token',
                message: 'Failed to get ID token from Google',
              ),
            );
            return;
          }

          // Create Firebase credential (GoogleSignIn v7 only provides idToken)
          final credential = GoogleAuthProvider.credential(idToken: idToken);

          // Sign in to Firebase
          final userCredential = await _auth.signInWithCredential(credential);
          _log.info('Google Sign-In successful: ${userCredential.user?.email}');

          _googleSignInCompleter?.complete(userCredential);
        } catch (e) {
          _googleSignInCompleter?.completeError(e);
        }

      case GoogleSignInAuthenticationEventSignOut():
        _log.info('User signed out from Google');
    }
  }

  void _handleGoogleAuthError(Object error) {
    _log.warning('Google auth error: $error');
    _googleSignInCompleter?.completeError(error);
  }

  /// Signs in using Google.
  ///
  /// Returns [UserCredential] on success, or throws an exception on failure.
  Future<UserCredential> signInWithGoogle() async {
    _log.info('Starting Google Sign-In flow');

    // Check if authenticate is supported on this platform
    if (!_googleSignIn.supportsAuthenticate()) {
      throw FirebaseAuthException._(
        code: 'platform-not-supported',
        message:
            'Google Sign-In authenticate() is not supported on this platform',
      );
    }

    // Create a completer to wait for the authentication event
    _googleSignInCompleter = Completer<UserCredential>();

    try {
      // Start the authentication flow
      await _googleSignIn.authenticate();

      // Wait for the result from the event handler
      return await _googleSignInCompleter!.future;
    } finally {
      _googleSignInCompleter = null;
    }
  }

  /// Signs in using Apple.
  ///
  /// Returns [UserCredential] on success, or throws an exception on failure.
  /// Only available on iOS 13+ and macOS 10.15+.
  Future<UserCredential> signInWithApple() async {
    _log.info('Starting Apple Sign-In flow');

    // Use Firebase's built-in Apple provider
    // This handles the entire OAuth flow including nonce generation
    final appleProvider = AppleAuthProvider();
    appleProvider.addScope('email');
    appleProvider.addScope('name');

    final userCredential = await _auth.signInWithProvider(appleProvider);

    // Apple only returns the display name the first time,
    // so we need to update the user profile if it's available
    if (userCredential.additionalUserInfo?.isNewUser ?? false) {
      // Try to get display name from user profile first
      String? displayName = userCredential.user?.displayName;

      // If no display name, extract from email (part before @)
      if (displayName == null || displayName.isEmpty) {
        final email = userCredential.user?.email;
        if (email != null && email.contains('@')) {
          displayName = email.split('@').first;
        }
      }

      // Fallback to empty string if still null
      displayName ??= '';

      if (displayName.isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName);
      }
    }

    _log.info('Apple Sign-In successful: ${userCredential.user?.email}');
    return userCredential;
  }

  /// Signs out from all providers.
  Future<void> signOut() async {
    _log.info('Signing out');

    // Sign out from Google
    await _googleSignIn.disconnect();

    // Sign out from Firebase
    await _auth.signOut();

    _log.info('Sign out complete');
  }

  /// Disposes resources used by this service.
  void dispose() {
    _googleAuthSubscription?.cancel();
    _googleAuthSubscription = null;
  }
}

/// Custom exception for Firebase Auth errors.
class FirebaseAuthException implements Exception {
  final String code;
  final String message;

  FirebaseAuthException._({required this.code, required this.message});

  @override
  String toString() => 'FirebaseAuthException($code): $message';
}
