import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/task_model.dart';

/// SessionBloc events
abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

/// Start a new session with a task
class StartSession extends SessionEvent {
  final TaskModel task;

  const StartSession({required this.task});

  @override
  List<Object?> get props => [task];
}

/// Timer tick (called every second)
class TimerTicked extends SessionEvent {
  final int elapsedSeconds;

  const TimerTicked({required this.elapsedSeconds});

  @override
  List<Object?> get props => [elapsedSeconds];
}

/// Pause the current session
class PauseSession extends SessionEvent {
  const PauseSession();
}

/// Resume a paused session
class ResumeSession extends SessionEvent {
  const ResumeSession();
}

/// Complete the session and save to backend
class CompleteSession extends SessionEvent {
  final int magicWipePercentage;

  const CompleteSession({this.magicWipePercentage = 100});

  @override
  List<Object?> get props => [magicWipePercentage];
}

/// Cancel the session without saving
class CancelSession extends SessionEvent {
  const CancelSession();
}
