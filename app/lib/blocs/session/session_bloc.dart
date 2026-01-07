import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/session/session_event.dart';
import 'package:ergo_life_app/blocs/session/session_state.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:ergo_life_app/data/repositories/activity_repository.dart';

/// BLoC for managing active exercise sessions with timer
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final ActivityRepository _activityRepository;

  Timer? _timer;
  int _elapsedSeconds = 0;

  SessionBloc({
    required ActivityRepository activityRepository,
  })  : _activityRepository = activityRepository,
        super(const SessionInactive()) {
    on<PrepareSession>(_onPrepareSession);
    on<StartSession>(_onStartSession);
    on<TimerTicked>(_onTimerTicked);
    on<PauseSession>(_onPauseSession);
    on<ResumeSession>(_onResumeSession);
    on<CompleteSession>(_onCompleteSession);
    on<CancelSession>(_onCancelSession);
  }

  /// Prepare session (waiting for user to start)
  Future<void> _onPrepareSession(
    PrepareSession event,
    Emitter<SessionState> emit,
  ) async {
    AppLogger.info(
      'Preparing session: ${event.task.exerciseName}',
      'SessionBloc',
    );

    emit(SessionPending(
      task: event.task,
      targetSeconds: event.task.durationSeconds,
    ));
  }

  /// Start a new session
  Future<void> _onStartSession(
    StartSession event,
    Emitter<SessionState> emit,
  ) async {
    AppLogger.info('Starting session: ${event.task.exerciseName}', 'SessionBloc');

    _elapsedSeconds = 0;
    _startTimer();

    emit(SessionActive(
      task: event.task,
      elapsedSeconds: 0,
      targetSeconds: event.task.durationSeconds,
      isPaused: false,
    ));
  }

  /// Timer tick handler
  void _onTimerTicked(
    TimerTicked event,
    Emitter<SessionState> emit,
  ) {
    final currentState = state;
    if (currentState is SessionActive && !currentState.isPaused) {
      emit(currentState.copyWith(elapsedSeconds: event.elapsedSeconds));
    }
  }

  /// Pause the session
  void _onPauseSession(
    PauseSession event,
    Emitter<SessionState> emit,
  ) {
    AppLogger.info('Pausing session', 'SessionBloc');

    _timer?.cancel();
    _timer = null;

    final currentState = state;
    if (currentState is SessionActive) {
      emit(currentState.copyWith(isPaused: true));
    }
  }

  /// Resume paused session
  void _onResumeSession(
    ResumeSession event,
    Emitter<SessionState> emit,
  ) {
    AppLogger.info('Resuming session', 'SessionBloc');

    _startTimer();

    final currentState = state;
    if (currentState is SessionActive) {
      emit(currentState.copyWith(isPaused: false));
    }
  }

  /// Complete the session and submit to backend
  Future<void> _onCompleteSession(
    CompleteSession event,
    Emitter<SessionState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SessionActive) {
      AppLogger.warning('Cannot complete - no active session', 'SessionBloc');
      return;
    }

    AppLogger.info('Completing session...', 'SessionBloc');

    _timer?.cancel();
    _timer = null;

    emit(SessionCompleting(
      task: currentState.task,
      totalSeconds: currentState.elapsedSeconds,
    ));

    final result = await _activityRepository.createActivity(
      taskName: currentState.task.exerciseName,
      durationSeconds: currentState.elapsedSeconds,
      metsValue: currentState.task.metsValue,
      magicWipePercentage: event.magicWipePercentage,
    );

    result.fold(
      (failure) {
        AppLogger.error('Failed to save activity', failure.message, null, 'SessionBloc');
        emit(SessionError(
          message: failure.message,
          task: currentState.task,
          elapsedSeconds: currentState.elapsedSeconds,
        ));
      },
      (response) {
        AppLogger.success(
          'Session completed! Earned ${response.wallet.pointsEarned} points',
          'SessionBloc',
        );
        emit(SessionCompleted(
          activity: response.activity,
          pointsEarned: response.wallet.pointsEarned,
          newWalletBalance: response.wallet.newBalance,
        ));
      },
    );
  }

  /// Cancel session without saving
  void _onCancelSession(
    CancelSession event,
    Emitter<SessionState> emit,
  ) {
    AppLogger.info('Cancelling session', 'SessionBloc');

    _timer?.cancel();
    _timer = null;
    _elapsedSeconds = 0;

    emit(const SessionInactive());
  }

  /// Start the internal timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        _elapsedSeconds++;
        add(TimerTicked(elapsedSeconds: _elapsedSeconds));
      },
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
