import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/custom_task_model.dart';

// States
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TaskCreating extends TaskState {
  const TaskCreating();
}

class TaskCreated extends TaskState {
  final CustomTaskModel task;

  const TaskCreated(this.task);

  @override
  List<Object?> get props => [task];
}

class TasksLoaded extends TaskState {
  final List<CustomTaskModel> tasks;

  const TasksLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TaskDeleted extends TaskState {
  const TaskDeleted();
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}
