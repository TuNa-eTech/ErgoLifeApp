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

  const SessionPending({
    required this.task,
    required this.targetSeconds,
  });

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

  const SessionActive({
    required this.task,
    required this.elapsedSeconds,
    required this.targetSeconds,
    this.isPaused = false,
  });

  /// Get formatted elapsed time as MM:SS
  String get formattedTime {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get formatted target time as MM:SS
  String get formattedTarget {
    final minutes = targetSeconds ~/ 60;
    final seconds = targetSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get progress percentage (0.0 to 1.0+)
  double get progress {
    if (targetSeconds == 0) return 0;
    return elapsedSeconds / targetSeconds;
  }

  /// Estimate calories burned (simplified formula)
  /// Calories = (METs × 3.5 × bodyWeight in kg) / 200 × minutes
  /// Using average 70kg body weight for estimation
  int get estimatedCalories {
    const avgBodyWeight = 65.0;
    final minutes = elapsedSeconds / 60;
    return ((task.metsValue * 3.5 * avgBodyWeight) / 200 * minutes).round();
  }

  /// Estimate points earned so far
  int get estimatedPoints {
    final minutes = elapsedSeconds / 60;
    return (minutes * task.metsValue * 10).round();
  }

  SessionActive copyWith({
    TaskModel? task,
    int? elapsedSeconds,
    int? targetSeconds,
    bool? isPaused,
  }) {
    return SessionActive(
      task: task ?? this.task,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      targetSeconds: targetSeconds ?? this.targetSeconds,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  @override
  List<Object?> get props => [task, elapsedSeconds, targetSeconds, isPaused];
}

/// Session is being completed (API call in progress)
class SessionCompleting extends SessionState {
  final TaskModel task;
  final int totalSeconds;

  const SessionCompleting({
    required this.task,
    required this.totalSeconds,
  });

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

  const SessionError({
    required this.message,
    this.task,
    this.elapsedSeconds,
  });

  /// Whether we can retry
  bool get canRetry => task != null && elapsedSeconds != null;

  @override
  List<Object?> get props => [message, task, elapsedSeconds];
}
