import 'package:equatable/equatable.dart';
import 'package:ergo_life_app/data/models/task_model.dart';

/// States for managing tasks screen
abstract class ManageTasksState extends Equatable {
  const ManageTasksState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ManageTasksInitial extends ManageTasksState {
  const ManageTasksInitial();
}

/// Loading tasks
class ManageTasksLoading extends ManageTasksState {
  const ManageTasksLoading();
}

/// Tasks loaded successfully
class ManageTasksLoaded extends ManageTasksState {
  const ManageTasksLoaded({
    required this.tasks,
    required this.hasChanges,
  });

  final List<TaskModel> tasks;
  final bool hasChanges;

  @override
  List<Object?> get props => [tasks, hasChanges];

  ManageTasksLoaded copyWith({
    List<TaskModel>? tasks,
    bool? hasChanges,
  }) {
    return ManageTasksLoaded(
      tasks: tasks ?? this.tasks,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }
}

/// Saving changes
class ManageTasksSaving extends ManageTasksState {
  const ManageTasksSaving({required this.tasks});

  final List<TaskModel> tasks;

  @override
  List<Object?> get props => [tasks];
}

/// Changes saved successfully
class ManageTasksSaved extends ManageTasksState {
  const ManageTasksSaved();
}

/// Error occurred
class ManageTasksError extends ManageTasksState {
  const ManageTasksError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
