import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/session/session_event.dart';
import 'package:ergo_life_app/blocs/session/session_state.dart';
import 'package:ergo_life_app/core/services/live_activity_service.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:ergo_life_app/data/repositories/activity_repository.dart';

/// BLoC for managing active exercise sessions with timer.
///
/// Uses wall-clock `DateTime` instead of tick-counting so the
/// elapsed time stays accurate even when the app is backgrounded.
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final ActivityRepository _activityRepository;
  final LiveActivityService _liveActivityService;

  Timer? _timer;

  /// Wall-clock time when the current running segment started.
  DateTime? _segmentStartTime;

  /// Accumulated seconds from previous (paused) segments.
  int _accumulatedSeconds = 0;

  SessionBloc({
    required ActivityRepository activityRepository,
    required LiveActivityService liveActivityService,
  }) : _activityRepository = activityRepository,
       _liveActivityService = liveActivityService,
       super(const SessionInactive()) {
    on<PrepareSession>(_onPrepareSession);
    on<StartSession>(_onStartSession);
    on<TimerTicked>(_onTimerTicked);
    on<PauseSession>(_onPauseSession);
    on<ResumeSession>(_onResumeSession);
    on<CompleteSession>(_onCompleteSession);
    on<CancelSession>(_onCancelSession);
    on<RefreshTimer>(_onRefreshTimer);
  }

  /// Calculate the real elapsed seconds using wall-clock time.
  int get _currentElapsedSeconds {
    if (_segmentStartTime == null) return _accumulatedSeconds;
    final segmentSeconds = DateTime.now()
        .difference(_segmentStartTime!)
        .inSeconds;
    return _accumulatedSeconds + segmentSeconds;
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

    emit(
      SessionPending(
        task: event.task,
        targetSeconds: event.task.durationSeconds,
      ),
    );
  }

  /// Start a new session
  Future<void> _onStartSession(
    StartSession event,
    Emitter<SessionState> emit,
  ) async {
    AppLogger.info(
      'Starting session: ${event.task.exerciseName}',
      'SessionBloc',
    );

    _accumulatedSeconds = 0;
    _segmentStartTime = DateTime.now();
    _startTimer();

    // Start iOS Live Activity
    _liveActivityService.startSessionActivity(
      taskName: event.task.exerciseName,
      targetSeconds: event.task.durationSeconds,
    );

    emit(
      SessionActive(
        task: event.task,
        elapsedSeconds: 0,
        targetSeconds: event.task.durationSeconds,
        isPaused: false,
      ),
    );
  }

  /// Timer tick — recalculate elapsed from wall-clock time.
  void _onTimerTicked(TimerTicked event, Emitter<SessionState> emit) {
    final currentState = state;
    if (currentState is SessionActive && !currentState.isPaused) {
      final elapsed = _currentElapsedSeconds;
      emit(currentState.copyWith(elapsedSeconds: elapsed));

      // Update Live Activity every 5 seconds to reduce overhead
      if (elapsed % 5 == 0) {
        _liveActivityService.updateSessionActivity(
          elapsedSeconds: elapsed,
          isPaused: false,
        );
      }
    }
  }

  /// Refresh timer — used when app resumes from background.
  void _onRefreshTimer(RefreshTimer event, Emitter<SessionState> emit) {
    final currentState = state;
    if (currentState is SessionActive && !currentState.isPaused) {
      AppLogger.info(
        'Refreshing timer after app resume: '
            '${_currentElapsedSeconds}s elapsed',
        'SessionBloc',
      );
      emit(currentState.copyWith(elapsedSeconds: _currentElapsedSeconds));
    }
  }

  /// Pause the session — save accumulated time.
  void _onPauseSession(PauseSession event, Emitter<SessionState> emit) {
    AppLogger.info('Pausing session', 'SessionBloc');

    _timer?.cancel();
    _timer = null;

    // Freeze the accumulated time
    _accumulatedSeconds = _currentElapsedSeconds;
    _segmentStartTime = null;

    final currentState = state;
    if (currentState is SessionActive) {
      _liveActivityService.updateSessionActivity(
        elapsedSeconds: _accumulatedSeconds,
        isPaused: true,
      );
      emit(currentState.copyWith(isPaused: true));
    }
  }

  /// Resume paused session — start a new segment.
  void _onResumeSession(ResumeSession event, Emitter<SessionState> emit) {
    AppLogger.info('Resuming session', 'SessionBloc');

    _segmentStartTime = DateTime.now();
    _startTimer();

    final currentState = state;
    if (currentState is SessionActive) {
      _liveActivityService.updateSessionActivity(
        elapsedSeconds: _accumulatedSeconds,
        isPaused: false,
      );
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

    final totalSeconds = _currentElapsedSeconds;

    _timer?.cancel();
    _timer = null;
    _segmentStartTime = null;

    // End Live Activity on completion
    _liveActivityService.endSessionActivity();

    emit(
      SessionCompleting(task: currentState.task, totalSeconds: totalSeconds),
    );

    final result = await _activityRepository.createActivity(
      taskName: currentState.task.exerciseName,
      durationSeconds: totalSeconds,
      metsValue: currentState.task.metsValue,
      magicWipePercentage: event.magicWipePercentage,
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'Failed to save activity',
          failure.message,
          null,
          'SessionBloc',
        );
        emit(
          SessionError(
            message: failure.message,
            task: currentState.task,
            elapsedSeconds: totalSeconds,
          ),
        );
      },
      (response) {
        AppLogger.success(
          'Session completed! '
              'Earned ${response.wallet.pointsEarned} points',
          'SessionBloc',
        );
        emit(
          SessionCompleted(
            activity: response.activity,
            pointsEarned: response.wallet.pointsEarned,
            newWalletBalance: response.wallet.newBalance,
            activityResponse: response,
          ),
        );
      },
    );
  }

  /// Cancel session without saving
  void _onCancelSession(CancelSession event, Emitter<SessionState> emit) {
    AppLogger.info('Cancelling session', 'SessionBloc');

    _timer?.cancel();
    _timer = null;
    _segmentStartTime = null;
    _accumulatedSeconds = 0;

    // End Live Activity on cancel
    _liveActivityService.endSessionActivity();

    emit(const SessionInactive());
  }

  /// Start the internal timer — used for UI updates only.
  /// The actual elapsed time is always calculated from wall-clock.
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => add(TimerTicked(elapsedSeconds: _currentElapsedSeconds)),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
