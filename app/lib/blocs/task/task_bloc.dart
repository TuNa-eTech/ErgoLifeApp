import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/task/task_event.dart';
import 'package:ergo_life_app/blocs/task/task_state.dart';
import 'package:ergo_life_app/data/services/api_service.dart';
import 'package:ergo_life_app/core/utils/logger.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final ApiService _apiService;

  TaskBloc(this._apiService) : super(const TaskInitial()) {
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
    try {
      final task = await _apiService.createCustomTask(event.request);
      emit(TaskCreated(task));
    } catch (e) {
      AppLogger.error('TaskBloc: Create task failed', e, null, 'TaskBloc');
      emit(TaskError('Failed to create task: ${e.toString()}'));
    }
  }

  Future<void> _onLoadCustomTasks(
    LoadCustomTasks event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    try {
      final tasks = await _apiService.getCustomTasks();
      emit(TasksLoaded(tasks));
    } catch (e) {
      AppLogger.error('TaskBloc: Load tasks failed', e, null, 'TaskBloc');
      emit(TaskError('Failed to load tasks: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteCustomTask(
    DeleteCustomTask event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    try {
      await _apiService.deleteCustomTask(event.taskId);
      emit(const TaskDeleted());
      // Reload tasks after deletion
      add(const LoadCustomTasks());
    } catch (e) {
      AppLogger.error('TaskBloc: Delete task failed', e, null, 'TaskBloc');
      emit(TaskError('Failed to delete task: ${e.toString()}'));
    }
  }

  Future<void> _onToggleTaskFavorite(
    ToggleTaskFavorite event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await _apiService.toggleCustomTaskFavorite(event.taskId);
      // Reload tasks to get updated favorite status
      add(const LoadCustomTasks());
    } catch (e) {
      AppLogger.error('TaskBloc: Toggle favorite failed', e, null, 'TaskBloc');
      emit(TaskError('Failed to toggle favorite: ${e.toString()}'));
    }
  }
}
