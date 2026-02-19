import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health/health.dart';
import 'package:ergo_life_app/blocs/session/session_event.dart';
import 'package:ergo_life_app/blocs/session/session_state.dart';
import 'package:ergo_life_app/core/services/live_activity_service.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:ergo_life_app/data/repositories/activity_repository.dart';
import 'package:ergo_life_app/data/repositories/health_repository.dart';

/// BLoC for managing active exercise sessions with timer.
///
/// Uses wall-clock `DateTime` instead of tick-counting so the
/// elapsed time stays accurate even when the app is backgrounded.
/// Polls HealthKit every 10s for heart rate and calories when
/// a [HealthRepository] is provided.
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final ActivityRepository _activityRepository;
  final LiveActivityService _liveActivityService;
  final HealthRepository? _healthRepository;

  Timer? _timer;

  /// Wall-clock time when the session was first started.
  /// Used as the `start` parameter for health queries.
  DateTime? _sessionStartTime;

  /// Wall-clock time when the current running segment
  /// started.
  DateTime? _segmentStartTime;

  /// Accumulated seconds from previous (paused) segments.
  int _accumulatedSeconds = 0;

  /// Interval in seconds between health data polls.
  static const _healthPollInterval = 10;

  SessionBloc({
    required ActivityRepository activityRepository,
    required LiveActivityService liveActivityService,
    HealthRepository? healthRepository,
  }) : _activityRepository = activityRepository,
       _liveActivityService = liveActivityService,
       _healthRepository = healthRepository,
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

  /// Calculate the real elapsed seconds using wall-clock
  /// time.
  int get _currentElapsedSeconds {
    if (_segmentStartTime == null) {
      return _accumulatedSeconds;
    }
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
    _sessionStartTime = DateTime.now();
    _segmentStartTime = _sessionStartTime;
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
  ///
  /// Every [_healthPollInterval] seconds, also polls
  /// HealthKit for heart rate and calories.
  Future<void> _onTimerTicked(
    TimerTicked event,
    Emitter<SessionState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SessionActive || currentState.isPaused) {
      return;
    }

    final elapsed = _currentElapsedSeconds;
    var newState = currentState.copyWith(elapsedSeconds: elapsed);

    // Poll health data every N seconds
    if (_healthRepository != null &&
        _sessionStartTime != null &&
        elapsed > 0 &&
        elapsed % _healthPollInterval == 0) {
      newState = await _pollHealthData(newState);
    }

    emit(newState);

    // Update Live Activity every 5 seconds
    if (elapsed % 5 == 0) {
      _liveActivityService.updateSessionActivity(
        elapsedSeconds: elapsed,
        isPaused: false,
      );
    }
  }

  /// Polls HealthKit for latest HR and active calories.
  ///
  /// Returns an updated [SessionActive] state with health
  /// data. Never throws — returns original state on failure.
  Future<SessionActive> _pollHealthData(SessionActive currentState) async {
    if (_healthRepository == null || _sessionStartTime == null) {
      return currentState;
    }

    try {
      final now = DateTime.now();

      // Fetch HR (last 30s window for freshness)
      final hrResult = await _healthRepository.getLatestHeartRate(
        since: now.subtract(const Duration(seconds: 30)),
      );

      // Fetch cumulative calories since session start
      final calResult = await _healthRepository.getSessionCalories(
        start: _sessionStartTime!,
        end: now,
      );

      final hr = hrResult.fold((_) => null, (v) => v);
      final cal = calResult.fold((_) => null, (v) => v);

      if (hr != null || cal != null) {
        AppLogger.info(
          'Health poll: HR=${hr?.toStringAsFixed(0)} bpm, '
              'cal=${cal?.toStringAsFixed(1)} kcal',
          'SessionBloc',
        );
      }

      return currentState.copyWith(
        currentHeartRate: hr ?? currentState.currentHeartRate,
        realCaloriesBurned: cal ?? currentState.realCaloriesBurned,
      );
    } on Exception catch (e) {
      AppLogger.error('Health poll failed: $e', 'SessionBloc');
      return currentState;
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

  /// Complete the session and submit to backend.
  ///
  /// Also aggregates final health data and writes a
  /// workout to HealthKit when available.
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
    final sessionStart = _sessionStartTime;

    _timer?.cancel();
    _timer = null;
    _segmentStartTime = null;

    // End Live Activity on completion
    _liveActivityService.endSessionActivity();

    emit(
      SessionCompleting(task: currentState.task, totalSeconds: totalSeconds),
    );

    // Aggregate final health data
    await _writeWorkoutToHealthKit(
      sessionStart: sessionStart,
      totalSeconds: totalSeconds,
      currentState: currentState,
    );

    final result = await _activityRepository.createActivity(
      taskName: currentState.task.exerciseName,
      durationSeconds: totalSeconds,
      metsValue: currentState.task.metsValue,
      magicWipePercentage: event.magicWipePercentage,
      avgHeartRate: currentState.currentHeartRate,
      realCaloriesBurned: currentState.realCaloriesBurned?.toDouble(),
      healthDataSource: currentState.hasHealthData
          ? (Platform.isIOS ? 'healthkit' : 'health_connect')
          : null,
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

    _sessionStartTime = null;
  }

  /// Writes the completed session as a workout to HealthKit.
  Future<void> _writeWorkoutToHealthKit({
    required DateTime? sessionStart,
    required int totalSeconds,
    required SessionActive currentState,
  }) async {
    if (_healthRepository == null || sessionStart == null) {
      return;
    }

    try {
      final sessionEnd = sessionStart.add(Duration(seconds: totalSeconds));
      final calories =
          currentState.realCaloriesBurned?.toDouble() ??
          currentState.estimatedCalories.toDouble();

      final result = await _healthRepository.saveWorkout(
        activityType: HealthWorkoutActivityType.FUNCTIONAL_STRENGTH_TRAINING,
        start: sessionStart,
        end: sessionEnd,
        totalCalories: calories,
      );

      result.fold(
        (failure) => AppLogger.warning(
          'Could not write workout: $failure',
          'SessionBloc',
        ),
        (success) => AppLogger.success(
          'Workout written to HealthKit: $success',
          'SessionBloc',
        ),
      );
    } on Exception catch (e) {
      AppLogger.error('Failed to write workout: $e', 'SessionBloc');
    }
  }

  /// Cancel session without saving
  void _onCancelSession(CancelSession event, Emitter<SessionState> emit) {
    AppLogger.info('Cancelling session', 'SessionBloc');

    _timer?.cancel();
    _timer = null;
    _segmentStartTime = null;
    _sessionStartTime = null;
    _accumulatedSeconds = 0;

    // End Live Activity on cancel
    _liveActivityService.endSessionActivity();

    emit(const SessionInactive());
  }

  /// Start the internal timer — used for UI updates only.
  /// Actual elapsed time is always from wall-clock.
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
