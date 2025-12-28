import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/custom_task_model.dart';

// Events
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class CreateCustomTask extends TaskEvent {
  final CreateCustomTaskRequest request;

  const CreateCustomTask(this.request);

  @override
  List<Object?> get props => [request];
}

class LoadCustomTasks extends TaskEvent {
  const LoadCustomTasks();
}

class DeleteCustomTask extends TaskEvent {
  final String taskId;

  const DeleteCustomTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class ToggleTaskFavorite extends TaskEvent {
  final String taskId;

  const ToggleTaskFavorite(this.taskId);

  @override
  List<Object?> get props => [taskId];
}
