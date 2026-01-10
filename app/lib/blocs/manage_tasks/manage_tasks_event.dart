import 'package:equatable/equatable.dart';

/// Events for managing tasks (reorder, visibility, etc.)
abstract class ManageTasksEvent extends Equatable {
  const ManageTasksEvent();

  @override
  List<Object?> get props => [];
}

/// Load all tasks (including hidden ones)
class LoadManageTasks extends ManageTasksEvent {
  const LoadManageTasks();
}

/// Reorder tasks after drag & drop
class ReorderTask extends ManageTasksEvent {
  const ReorderTask({required this.oldIndex, required this.newIndex});

  final int oldIndex;
  final int newIndex;

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

/// Toggle visibility of a task
class ToggleTaskVisibility extends ManageTasksEvent {
  const ToggleTaskVisibility({required this.taskId});

  final String taskId;

  @override
  List<Object?> get props => [taskId];
}

/// Save all changes (reorder + visibility)
class SaveTaskChanges extends ManageTasksEvent {
  const SaveTaskChanges();
}

/// Reset to original state
class ResetTaskChanges extends ManageTasksEvent {
  const ResetTaskChanges();
}
