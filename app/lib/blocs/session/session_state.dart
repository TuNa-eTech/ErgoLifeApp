import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/task_model.dart';
import 'package:ergo_life_app/data/models/activity_model.dart';

/// SessionBloc states
abstract class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

/// No active session
class SessionInactive extends SessionState {
  const SessionInactive();
}

/// Session is pending - waiting for user to start
class SessionPending extends SessionState {
  final TaskModel task;
  final int targetSeconds;

  const SessionPending({required this.task, required this.targetSeconds});

  /// Get formatted target time as MM:SS
  String get formattedTarget {
    final minutes = targetSeconds ~/ 60;
    final seconds = targetSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [task, targetSeconds];
}

/// Session is currently running
class SessionActive extends SessionState {
  final TaskModel task;
  final int elapsedSeconds;
  final int targetSeconds;
  final bool isPaused;

  /// Current heart rate from HealthKit in bpm, or null.
  final double? currentHeartRate;

  /// Real calories burned from HealthKit, or null.
  final double? realCaloriesBurned;

  /// User's body weight in kg (from HealthKit or default).
  final double bodyWeight;

  const SessionActive({
    required this.task,
    required this.elapsedSeconds,
    required this.targetSeconds,
    this.isPaused = false,
    this.currentHeartRate,
    this.realCaloriesBurned,
    this.bodyWeight = 65.0,
  });

  /// Whether real health data from HealthKit is available.
  bool get hasHealthData =>
      currentHeartRate != null || realCaloriesBurned != null;

  /// Get formatted elapsed time as MM:SS
  String get formattedTime {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Get formatted target time as MM:SS
  String get formattedTarget {
    final minutes = targetSeconds ~/ 60;
    final seconds = targetSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Get progress percentage (0.0 to 1.0+)
  double get progress {
    if (targetSeconds == 0) return 0;
    return elapsedSeconds / targetSeconds;
  }

  /// Calories burned — uses real HealthKit data when
  /// available, otherwise falls back to METs estimation.
  ///
  /// Formula: `(METs × 3.5 × bodyWeight) / 200 × minutes`
  int get estimatedCalories {
    if (realCaloriesBurned != null) {
      return realCaloriesBurned!.round();
    }
    final minutes = elapsedSeconds / 60;
    return ((task.metsValue * 3.5 * bodyWeight) / 200 * minutes).round();
  }

  /// EP multiplier based on current heart rate zone.
  ///
  /// Rewards genuine physical effort:
  /// - Rest zone (<80 bpm): 0.8x
  /// - Light (80–99 bpm): 1.0x
  /// - Fat Burn (100–129 bpm): 1.2x
  /// - Cardio (130+ bpm): 1.5x
  double get heartRateMultiplier {
    if (currentHeartRate == null) return 1.0;
    if (currentHeartRate! < 80) return 0.8;
    if (currentHeartRate! < 100) return 1.0;
    if (currentHeartRate! < 130) return 1.2;
    return 1.5;
  }

  /// HR zone label for display.
  String get heartRateZone {
    if (currentHeartRate == null) return '';
    if (currentHeartRate! < 80) return 'REST';
    if (currentHeartRate! < 100) return 'LIGHT';
    if (currentHeartRate! < 130) return 'FAT BURN';
    return 'CARDIO';
  }

  /// Estimate points earned so far, with HR bonus.
  int get estimatedPoints {
    final minutes = elapsedSeconds / 60;
    return (minutes * task.metsValue * 10 * heartRateMultiplier).round();
  }

  SessionActive copyWith({
    TaskModel? task,
    int? elapsedSeconds,
    int? targetSeconds,
    bool? isPaused,
    double? currentHeartRate,
    double? realCaloriesBurned,
    double? bodyWeight,
  }) {
    return SessionActive(
      task: task ?? this.task,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      targetSeconds: targetSeconds ?? this.targetSeconds,
      isPaused: isPaused ?? this.isPaused,
      currentHeartRate: currentHeartRate ?? this.currentHeartRate,
      realCaloriesBurned: realCaloriesBurned ?? this.realCaloriesBurned,
      bodyWeight: bodyWeight ?? this.bodyWeight,
    );
  }

  @override
  List<Object?> get props => [
    task,
    elapsedSeconds,
    targetSeconds,
    isPaused,
    currentHeartRate,
    realCaloriesBurned,
    bodyWeight,
  ];
}

/// Session is being completed (API call in progress)
class SessionCompleting extends SessionState {
  final TaskModel task;
  final int totalSeconds;

  const SessionCompleting({required this.task, required this.totalSeconds});

  @override
  List<Object?> get props => [task, totalSeconds];
}

/// Session completed successfully
class SessionCompleted extends SessionState {
  final ActivityModel activity;
  final int pointsEarned;
  final int newWalletBalance;
  final CreateActivityResponse? activityResponse;

  const SessionCompleted({
    required this.activity,
    required this.pointsEarned,
    required this.newWalletBalance,
    this.activityResponse,
  });

  @override
  List<Object?> get props => [
    activity,
    pointsEarned,
    newWalletBalance,
    activityResponse,
  ];
}

/// Session failed to complete
class SessionError extends SessionState {
  final String message;
  final TaskModel? task;
  final int? elapsedSeconds;

  const SessionError({required this.message, this.task, this.elapsedSeconds});

  /// Whether we can retry
  bool get canRetry => task != null && elapsedSeconds != null;

  @override
  List<Object?> get props => [message, task, elapsedSeconds];
}
