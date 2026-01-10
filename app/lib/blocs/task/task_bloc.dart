import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/task/task_event.dart';
import 'package:ergo_life_app/blocs/task/task_state.dart';
import 'package:ergo_life_app/data/repositories/task_repository.dart';
import 'package:ergo_life_app/core/utils/logger.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;

  TaskBloc(this._taskRepository) : super(const TaskInitial()) {
    on<CreateCustomTask>(_onCreateCustomTask);
    on<LoadCustomTasks>(_onLoadCustomTasks);
    on<DeleteCustomTask>(_onDeleteCustomTask);
    on<ToggleTaskFavorite>(_onToggleTaskFavorite);
  }

  Future<void> _onCreateCustomTask(
    CreateCustomTask event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskCreating());
    final result = await _taskRepository.createCustomTask(event.request);
    result.fold((failure) {
      AppLogger.error(
        'TaskBloc: Create task failed',
        failure.message,
        null,
        'TaskBloc',
      );
      emit(TaskError('Failed to create task: ${failure.message}'));
    }, (task) => emit(TaskCreated(task)));
  }

  Future<void> _onLoadCustomTasks(
    LoadCustomTasks event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    final result = await _taskRepository.getCustomTasks();
    result.fold((failure) {
      AppLogger.error(
        'TaskBloc: Load tasks failed',
        failure.message,
        null,
        'TaskBloc',
      );
      emit(TaskError('Failed to load tasks: ${failure.message}'));
    }, (tasks) => emit(TasksLoaded(tasks)));
  }

  Future<void> _onDeleteCustomTask(
    DeleteCustomTask event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    final result = await _taskRepository.deleteCustomTask(event.taskId);
    result.fold(
      (failure) {
        AppLogger.error(
          'TaskBloc: Delete task failed',
          failure.message,
          null,
          'TaskBloc',
        );
        emit(TaskError('Failed to delete task: ${failure.message}'));
      },
      (_) {
        emit(const TaskDeleted());
        // Reload tasks after deletion
        add(const LoadCustomTasks());
      },
    );
  }

  Future<void> _onToggleTaskFavorite(
    ToggleTaskFavorite event,
    Emitter<TaskState> emit,
  ) async {
    final result = await _taskRepository.toggleCustomTaskFavorite(event.taskId);
    result.fold(
      (failure) {
        AppLogger.error(
          'TaskBloc: Toggle favorite failed',
          failure.message,
          null,
          'TaskBloc',
        );
        emit(TaskError('Failed to toggle favorite: ${failure.message}'));
      },
      (_) {
        // Reload tasks to get updated favorite status
        add(const LoadCustomTasks());
      },
    );
  }
}
