import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/manage_tasks/manage_tasks_event.dart';
import 'package:ergo_life_app/blocs/manage_tasks/manage_tasks_state.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:ergo_life_app/data/models/task_model.dart';
import 'package:ergo_life_app/data/repositories/task_repository.dart';

/// BLoC for managing tasks (reorder, hide/show)
class ManageTasksBloc extends Bloc<ManageTasksEvent, ManageTasksState> {
  final TaskRepository _taskRepository;

  // Store original tasks to detect changes
  List<TaskModel> _originalTasks = [];

  ManageTasksBloc({
    required TaskRepository taskRepository,
  })  : _taskRepository = taskRepository,
        super(const ManageTasksInitial()) {
    on<LoadManageTasks>(_onLoadManageTasks);
    on<ReorderTask>(_onReorderTask);
    on<ToggleTaskVisibility>(_onToggleTaskVisibility);
    on<SaveTaskChanges>(_onSaveTaskChanges);
    on<ResetTaskChanges>(_onResetTaskChanges);
  }

  /// Load all tasks including hidden ones
  Future<void> _onLoadManageTasks(
    LoadManageTasks event,
    Emitter<ManageTasksState> emit,
  ) async {
    AppLogger.info('Loading tasks for management...', 'ManageTasksBloc');
    emit(const ManageTasksLoading());

    try {
      final result = await _taskRepository.getTasks(includeHidden: true);

      await result.fold(
        (failure) async {
          AppLogger.error(
            'Failed to load tasks',
            failure.message,
            null,
            'ManageTasksBloc',
          );
          emit(ManageTasksError(message: failure.message));
        },
        (taskMaps) async {
          final tasks = taskMaps
              .map((json) => TaskModel.fromJson(json))
              .toList();

          // Sort by sortOrder
          tasks.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

          // Store original state
          _originalTasks = tasks.map((t) => t).toList();

          AppLogger.success(
            'Loaded ${tasks.length} tasks for management',
            'ManageTasksBloc',
          );
          emit(ManageTasksLoaded(tasks: tasks, hasChanges: false));
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected error loading tasks', e, null, 'ManageTasksBloc');
      emit(const ManageTasksError(message: 'Failed to load tasks'));
    }
  }

  /// Reorder task after drag & drop
  void _onReorderTask(
    ReorderTask event,
    Emitter<ManageTasksState> emit,
  ) {
    if (state is! ManageTasksLoaded) return;

    final currentState = state as ManageTasksLoaded;
    final tasks = List<TaskModel>.from(currentState.tasks);

    // Perform reorder
    final task = tasks.removeAt(event.oldIndex);
    tasks.insert(event.newIndex, task);

    // Update sortOrder for all tasks
    final updatedTasks = tasks.asMap().entries.map((entry) {
      return entry.value.copyWith(sortOrder: entry.key);
    }).toList();

    final hasChanges = _hasChanges(updatedTasks);

    AppLogger.info(
      'Reordered task from ${event.oldIndex} to ${event.newIndex}',
      'ManageTasksBloc',
    );

    emit(ManageTasksLoaded(
      tasks: updatedTasks,
      hasChanges: hasChanges,
    ));
  }

  /// Toggle task visibility (hide/show)
  void _onToggleTaskVisibility(
    ToggleTaskVisibility event,
    Emitter<ManageTasksState> emit,
  ) {
    if (state is! ManageTasksLoaded) return;

    final currentState = state as ManageTasksLoaded;
    final tasks = currentState.tasks.map((task) {
      if (task.id == event.taskId) {
        return task.copyWith(isHidden: !task.isHidden);
      }
      return task;
    }).toList();

    final hasChanges = _hasChanges(tasks);

    AppLogger.info(
      'Toggled visibility for task ${event.taskId}',
      'ManageTasksBloc',
    );

    emit(ManageTasksLoaded(
      tasks: tasks,
      hasChanges: hasChanges,
    ));
  }

  /// Save all changes to backend
  Future<void> _onSaveTaskChanges(
    SaveTaskChanges event,
    Emitter<ManageTasksState> emit,
  ) async {
    if (state is! ManageTasksLoaded) return;

    final currentState = state as ManageTasksLoaded;
    final tasks = currentState.tasks;

    AppLogger.info('Saving task changes...', 'ManageTasksBloc');
    emit(ManageTasksSaving(tasks: tasks));

    try {
      // Step 1: Handle visibility changes
      final visibilityChanges = <String>[];
      for (int i = 0; i < tasks.length; i++) {
        final current = tasks[i];
        final original =
            _originalTasks.firstWhere((t) => t.id == current.id, orElse: () => current);

        if (current.isHidden != original.isHidden) {
          visibilityChanges.add(current.id!);
        }
      }

      // Toggle visibility for changed tasks
      for (final taskId in visibilityChanges) {
        AppLogger.info('Toggling visibility for $taskId', 'ManageTasksBloc');
        final result = await _taskRepository.toggleTaskVisibility(taskId);
        result.fold(
          (failure) => AppLogger.error(
            'Failed to toggle visibility',
            failure.message,
            null,
            'ManageTasksBloc',
          ),
          (_) => AppLogger.success(
            'Toggled visibility for $taskId',
            'ManageTasksBloc',
          ),
        );
      }

      // Step 2: Reorder all tasks
      final reorderData = tasks
          .asMap()
          .entries
          .map((entry) => {
                'id': entry.value.id!,
                'sortOrder': entry.key,
              })
          .toList();

      AppLogger.info('Reordering ${tasks.length} tasks', 'ManageTasksBloc');
      final reorderResult = await _taskRepository.reorderTasks(reorderData);

      await reorderResult.fold(
        (failure) async {
          AppLogger.error(
            'Failed to reorder tasks',
            failure.message,
            null,
            'ManageTasksBloc',
          );
          emit(ManageTasksError(message: failure.message));
        },
        (_) async {
          AppLogger.success('All changes saved successfully', 'ManageTasksBloc');
          emit(const ManageTasksSaved());
        },
      );
    } catch (e) {
      AppLogger.error('Error saving changes', e, null, 'ManageTasksBloc');
      emit(const ManageTasksError(message: 'Failed to save changes'));
    }
  }

  /// Reset changes to original state
  void _onResetTaskChanges(
    ResetTaskChanges event,
    Emitter<ManageTasksState> emit,
  ) {
    AppLogger.info('Resetting task changes', 'ManageTasksBloc');
    emit(ManageTasksLoaded(
      tasks: _originalTasks.map((t) => t).toList(),
      hasChanges: false,
    ));
  }

  /// Check if there are any changes compared to original
  bool _hasChanges(List<TaskModel> currentTasks) {
    if (currentTasks.length != _originalTasks.length) return true;

    for (int i = 0; i < currentTasks.length; i++) {
      final current = currentTasks[i];
      final original = _originalTasks[i];

      // Check if order changed
      if (current.id != original.id) return true;

      // Check if visibility changed
      if (current.isHidden != original.isHidden) return true;

      // Check if sortOrder changed
      if (current.sortOrder != original.sortOrder) return true;
    }

    return false;
  }
}
