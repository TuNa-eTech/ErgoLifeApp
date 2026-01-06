import 'package:dartz/dartz.dart';
import 'package:ergo_life_app/core/constants/api_constants.dart';
import 'package:ergo_life_app/core/errors/exceptions.dart';
import 'package:ergo_life_app/core/errors/failures.dart';
import 'package:ergo_life_app/core/network/api_client.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:ergo_life_app/data/models/custom_task_model.dart';

/// Repository for all task-related operations
/// Handles: Task Templates, User Tasks, Custom Tasks, and Task Seeding
class TaskRepository {
  final ApiClient _apiClient;

  TaskRepository(this._apiClient);

  // ===== Task Templates =====

  /// Get all task templates (localized)
  Future<Either<Failure, List<Map<String, dynamic>>>> getTaskTemplates({
    String locale = 'en',
  }) async {
    try {
      AppLogger.info('Fetching task templates for locale: $locale', 'TaskRepository');

      final response = await _apiClient.get(
        ApiConstants.taskTemplates,
        queryParameters: {'locale': locale},
      );

      final data = _apiClient.unwrapResponse(response.data);
      final templates = (data['templates'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      AppLogger.success('Loaded ${templates.length} templates', 'TaskRepository');
      return Right(templates);
    } on ServerException catch (e) {
      AppLogger.error('Get templates failed', e.message, null, 'TaskRepository');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error', e.message, null, 'TaskRepository');
      return Left(NetworkFailure(message: 'Unable to connect'));
    } catch (e) {
      AppLogger.error('Get templates failed', e, null, 'TaskRepository');
      return Left(ServerFailure(message: 'Failed to load templates'));
    }
  }

  // ===== Task Seeding =====

  /// Check if user needs task seeding
  Future<Either<Failure, bool>> needsTaskSeeding() async {
    try {
      AppLogger.info('Calling needsTaskSeeding API...', 'TaskRepository');
      final response = await _apiClient.get(ApiConstants.tasksNeedsSeeding);
      AppLogger.info('Raw response: ${response.data}', 'TaskRepository');
      
      final data = _apiClient.unwrapResponse(response.data);
      AppLogger.info('Unwrapped data: $data', 'TaskRepository');
      
      final needsSeeding = data['needsSeeding'] as bool? ?? false;
      AppLogger.info('Parsed needsSeeding: $needsSeeding', 'TaskRepository');
      
      return Right(needsSeeding);
    } on ServerException catch (e) {
      AppLogger.error('Check seeding status failed', e.message, null, 'TaskRepository');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Check seeding status failed', e, null, 'TaskRepository');
      return Left(ServerFailure(message: 'Failed to check seeding status'));
    }
  }

  /// Seed default tasks from templates
  Future<Either<Failure, Map<String, dynamic>>> seedTasks(
    List<Map<String, dynamic>> tasks,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.tasksSeed,
        data: {'tasks': tasks},
      );
      final data = _apiClient.unwrapResponse(response.data);
      return Right(data as Map<String, dynamic>? ?? {});
    } on ServerException catch (e) {
      AppLogger.error('Seed tasks failed', e.message, null, 'TaskRepository');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Seed tasks failed', e, null, 'TaskRepository');
      return Left(ServerFailure(message: 'Failed to seed tasks'));
    }
  }

  // ===== User Tasks =====

  /// Get all user tasks
  Future<Either<Failure, List<Map<String, dynamic>>>> getTasks({
    bool includeHidden = false,
  }) async {
    try {
      AppLogger.info('Fetching user tasks', 'TaskRepository');

      final response = await _apiClient.get(
        ApiConstants.tasks,
        queryParameters: {'includeHidden': includeHidden.toString()},
      );

      final data = _apiClient.unwrapResponse(response.data);
      final tasks = (data['tasks'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      AppLogger.success('Loaded ${tasks.length} tasks', 'TaskRepository');
      return Right(tasks);
    } on ServerException catch (e) {
      AppLogger.error('Get tasks failed', e.message, null, 'TaskRepository');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error', e.message, null, 'TaskRepository');
      return Left(NetworkFailure(message: 'Unable to connect'));
    } catch (e) {
      AppLogger.error('Get tasks failed', e, null, 'TaskRepository');
      return Left(ServerFailure(message: 'Failed to load tasks'));
    }
  }

  /// Create a new task
  Future<Either<Failure, Map<String, dynamic>>> createTask(
    Map<String, dynamic> taskData,
  ) async {
    try {
      final response = await _apiClient.post(ApiConstants.tasks, data: taskData);
      final data = _apiClient.unwrapResponse(response.data);
      return Right(data as Map<String, dynamic>? ?? {});
    } on ServerException catch (e) {
      AppLogger.error('Create task failed', e.message, null, 'TaskRepository');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Create task failed', e, null, 'TaskRepository');
      return Left(ServerFailure(message: 'Failed to create task'));
    }
  }

  /// Update a task
  Future<Either<Failure, Map<String, dynamic>>> updateTask(
    String taskId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConstants.tasks}/$taskId',
        data: data,
      );
      final responseData = _apiClient.unwrapResponse(response.data);
      return Right(responseData as Map<String, dynamic>? ?? {});
    } on ServerException catch (e) {
      AppLogger.error('Update task failed', e.message, null, 'TaskRepository');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Update task failed', e, null, 'TaskRepository');
      return Left(ServerFailure(message: 'Failed to update task'));
    }
  }

  /// Delete a task
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    try {
      await _apiClient.delete('${ApiConstants.tasks}/$taskId');
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('Delete task failed', e.message, null, 'TaskRepository');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Delete task failed', e, null, 'TaskRepository');
      return Left(ServerFailure(message: 'Failed to delete task'));
    }
  }

  /// Toggle task visibility (hide/show)
  Future<Either<Failure, Map<String, dynamic>>> toggleTaskVisibility(
    String taskId,
  ) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConstants.tasks}/$taskId/visibility',
      );
      final data = _apiClient.unwrapResponse(response.data);
      return Right(data as Map<String, dynamic>? ?? {});
    } on ServerException catch (e) {
      AppLogger.error('Toggle visibility failed', e.message, null, 'TaskRepository');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Toggle visibility failed', e, null, 'TaskRepository');
      return Left(ServerFailure(message: 'Failed to toggle visibility'));
    }
  }

  /// Toggle task favorite
  Future<Either<Failure, Map<String, dynamic>>> toggleTaskFavorite(
    String taskId,
  ) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConstants.tasks}/$taskId/favorite',
      );
      final data = _apiClient.unwrapResponse(response.data);
      return Right(data as Map<String, dynamic>? ?? {});
    } on ServerException catch (e) {
      AppLogger.error('Toggle favorite failed', e.message, null, 'TaskRepository');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Toggle favorite failed', e, null, 'TaskRepository');
      return Left(ServerFailure(message: 'Failed to toggle favorite'));
    }
  }

  /// Reorder tasks
  Future<Either<Failure, void>> reorderTasks(
    List<Map<String, dynamic>> taskOrders,
  ) async {
    try {
      await _apiClient.post(
        ApiConstants.tasksReorder,
        data: {'tasks': taskOrders},
      );
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('Reorder tasks failed', e.message, null, 'TaskRepository');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Reorder tasks failed', e, null, 'TaskRepository');
      return Left(ServerFailure(message: 'Failed to reorder tasks'));
    }
  }

  // ===== Custom Tasks =====

  /// Create a custom task
  Future<Either<Failure, CustomTaskModel>> createCustomTask(
    CreateCustomTaskRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.tasksCustom,
        data: request.toJson(),
      );
      final data = _apiClient.unwrapResponse(response.data);
      return Right(CustomTaskModel.fromJson(data as Map<String, dynamic>));
    } on ServerException catch (e) {
      AppLogger.error('Create custom task failed', e.message, null, 'TaskRepository');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Create custom task failed', e, null, 'TaskRepository');
      return Left(ServerFailure(message: 'Failed to create custom task'));
    }
  }

  /// Get user's custom tasks
  Future<Either<Failure, List<CustomTaskModel>>> getCustomTasks() async {
    try {
      final response = await _apiClient.get(ApiConstants.tasksCustom);
      final data = _apiClient.unwrapResponse(response.data);
      final tasksData = data['tasks'] as List<dynamic>? ?? [];
      final tasks = tasksData
          .map((json) => CustomTaskModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Right(tasks);
    } on ServerException catch (e) {
      AppLogger.error('Get custom tasks failed', e.message, null, 'TaskRepository');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Get custom tasks failed', e, null, 'TaskRepository');
      return Left(ServerFailure(message: 'Failed to load custom tasks'));
    }
  }

  /// Delete a custom task
  Future<Either<Failure, void>> deleteCustomTask(String taskId) async {
    try {
      await _apiClient.delete('${ApiConstants.tasksCustom}/$taskId');
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('Delete custom task failed', e.message, null, 'TaskRepository');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Delete custom task failed', e, null, 'TaskRepository');
      return Left(ServerFailure(message: 'Failed to delete custom task'));
    }
  }

  /// Toggle favorite status of a custom task
  Future<Either<Failure, CustomTaskModel>> toggleCustomTaskFavorite(
    String taskId,
  ) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConstants.tasksCustom}/$taskId/favorite',
      );
      final data = _apiClient.unwrapResponse(response.data);
      return Right(CustomTaskModel.fromJson(data as Map<String, dynamic>));
    } on ServerException catch (e) {
      AppLogger.error('Toggle favorite failed', e.message, null, 'TaskRepository');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Toggle favorite failed', e, null, 'TaskRepository');
      return Left(ServerFailure(message: 'Failed to toggle favorite'));
    }
  }
}
