import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/session_model.dart';
import 'package:ergo_life_app/data/repositories/session_repository.dart';
import 'package:ergo_life_app/core/utils/logger.dart';

// States
abstract class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

class SessionInitial extends SessionState {}

class SessionLoading extends SessionState {}

class SessionsLoaded extends SessionState {
  final List<SessionModel> sessions;

  const SessionsLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

class SessionActive extends SessionState {
  final SessionModel session;

  const SessionActive(this.session);

  @override
  List<Object?> get props => [session];
}

class SessionError extends SessionState {
  final String message;

  const SessionError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class SessionCubit extends Cubit<SessionState> {
  final SessionRepository _repository;

  SessionCubit(this._repository) : super(SessionInitial());

  Future<void> loadSessions() async {
    try {
      AppLogger.info('Loading sessions...', 'SessionCubit');
      emit(SessionLoading());

      // For demo, use mock data
      final sessions = _repository.getMockSessions();

      AppLogger.success('Sessions loaded successfully', 'SessionCubit');
      emit(SessionsLoaded(sessions));
    } catch (e) {
      AppLogger.error('Failed to load sessions', e, null, 'SessionCubit');
      emit(SessionError(e.toString()));
    }
  }

  Future<void> startSession({
    required String title,
    required String description,
  }) async {
    try {
      AppLogger.info('Starting session...', 'SessionCubit');

      // Create mock session for demo
      final session = SessionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        duration: 0,
        startTime: DateTime.now(),
        status: 'active',
      );

      AppLogger.success('Session started successfully', 'SessionCubit');
      emit(SessionActive(session));
    } catch (e) {
      AppLogger.error('Failed to start session', e, null, 'SessionCubit');
      emit(SessionError(e.toString()));
    }
  }

  Future<void> endSession(String sessionId) async {
    try {
      AppLogger.info('Ending session...', 'SessionCubit');

      // Reload sessions
      await loadSessions();

      AppLogger.success('Session ended successfully', 'SessionCubit');
    } catch (e) {
      AppLogger.error('Failed to end session', e, null, 'SessionCubit');
      emit(SessionError(e.toString()));
    }
  }
}
