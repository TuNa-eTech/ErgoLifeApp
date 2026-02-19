import 'package:dartz/dartz.dart';
import 'package:health/health.dart';
import 'package:ergo_life_app/core/services/health_service.dart';
import 'package:ergo_life_app/core/utils/logger.dart';
import 'package:ergo_life_app/data/models/health_data_model.dart';

/// Failure type for health operations.
class HealthFailure {
  final String message;
  const HealthFailure(this.message);

  @override
  String toString() => 'HealthFailure($message)';
}

/// Repository for health data operations.
///
/// Wraps [HealthService] with the Either pattern used
/// throughout the app's data layer, providing a clean
/// interface for BLoCs.
class HealthRepository {
  final HealthService _healthService;

  HealthRepository(this._healthService);

  /// Configures the health service for use.
  Future<Either<HealthFailure, bool>> configure() async {
    try {
      await _healthService.configure();
      return const Right(true);
    } on Exception catch (e) {
      return Left(HealthFailure('Configuration failed: $e'));
    }
  }

  /// Requests authorization for health data access.
  Future<Either<HealthFailure, bool>> requestAccess() async {
    try {
      final granted = await _healthService.requestAuthorization();
      return Right(granted);
    } on Exception catch (e) {
      return Left(HealthFailure('Authorization failed: $e'));
    }
  }

  /// Checks if health permissions have been granted.
  ///
  /// Returns `null` on iOS when the state is unknown
  /// (Apple does not reveal denied state).
  Future<Either<HealthFailure, bool?>> checkPermissions() async {
    try {
      final result = await _healthService.hasPermissions();
      return Right(result);
    } on Exception catch (e) {
      return Left(HealthFailure('Permission check failed: $e'));
    }
  }

  /// Gets the latest heart rate in bpm.
  ///
  /// Queries the last 30 seconds of data and returns
  /// the most recent value.
  Future<Either<HealthFailure, double?>> getLatestHeartRate({
    DateTime? since,
  }) async {
    try {
      final now = DateTime.now();
      final start = since ?? now.subtract(const Duration(seconds: 30));

      final dataPoints = await _healthService.getHeartRate(
        start: start,
        end: now,
      );

      if (dataPoints.isEmpty) return const Right(null);

      // Get most recent data point
      dataPoints.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
      final latest = dataPoints.first.value;
      if (latest is NumericHealthValue) {
        return Right(latest.numericValue.toDouble());
      }
      return const Right(null);
    } on Exception catch (e) {
      return Left(HealthFailure('Failed to get heart rate: $e'));
    }
  }

  /// Gets active calories burned in the given time range.
  Future<Either<HealthFailure, double?>> getSessionCalories({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final dataPoints = await _healthService.getActiveCalories(
        start: start,
        end: end,
      );

      if (dataPoints.isEmpty) return const Right(null);

      // Sum all calorie data points in the range
      double total = 0;
      for (final point in dataPoints) {
        if (point.value is NumericHealthValue) {
          total += (point.value as NumericHealthValue).numericValue.toDouble();
        }
      }
      return Right(total);
    } on Exception catch (e) {
      return Left(HealthFailure('Failed to get calories: $e'));
    }
  }

  /// Gets today's total step count.
  Future<Either<HealthFailure, int?>> getTodaySteps() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final dataPoints = await _healthService.getSteps(
        start: startOfDay,
        end: now,
      );

      if (dataPoints.isEmpty) return const Right(null);

      int total = 0;
      for (final point in dataPoints) {
        if (point.value is NumericHealthValue) {
          total += (point.value as NumericHealthValue).numericValue.toInt();
        }
      }
      return Right(total);
    } on Exception catch (e) {
      return Left(HealthFailure('Failed to get steps: $e'));
    }
  }

  /// Gets the most recent body weight in kg.
  Future<Either<HealthFailure, double?>> getBodyWeight() async {
    try {
      final now = DateTime.now();
      // Look back 90 days for the latest weight entry
      final start = now.subtract(const Duration(days: 90));

      final dataPoints = await _healthService.getBodyWeight(
        start: start,
        end: now,
      );

      if (dataPoints.isEmpty) return const Right(null);

      dataPoints.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
      final latest = dataPoints.first.value;
      if (latest is NumericHealthValue) {
        return Right(latest.numericValue.toDouble());
      }
      return const Right(null);
    } on Exception catch (e) {
      return Left(HealthFailure('Failed to get body weight: $e'));
    }
  }

  /// Aggregates session health data for the given range.
  ///
  /// Collects heart rate stats and real calories for the
  /// session. Returns data with `dataSource: "healthkit"` if
  /// any real data is available.
  Future<Either<HealthFailure, SessionHealthData>> getSessionHealthData({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final hrResult = await _healthService.getHeartRate(
        start: start,
        end: end,
      );

      final calResult = await _healthService.getActiveCalories(
        start: start,
        end: end,
      );

      double? avgHr;
      double? maxHr;
      double? totalCal;

      // Calculate HR stats
      if (hrResult.isNotEmpty) {
        final hrValues = <double>[];
        for (final p in hrResult) {
          if (p.value is NumericHealthValue) {
            hrValues.add(
              (p.value as NumericHealthValue).numericValue.toDouble(),
            );
          }
        }
        if (hrValues.isNotEmpty) {
          avgHr = hrValues.reduce((a, b) => a + b) / hrValues.length;
          maxHr = hrValues.reduce((a, b) => a > b ? a : b);
        }
      }

      // Sum calories
      if (calResult.isNotEmpty) {
        totalCal = 0;
        for (final p in calResult) {
          if (p.value is NumericHealthValue) {
            totalCal =
                totalCal! +
                (p.value as NumericHealthValue).numericValue.toDouble();
          }
        }
      }

      final hasReal = avgHr != null || totalCal != null;
      return Right(
        SessionHealthData(
          avgHeartRate: avgHr,
          maxHeartRate: maxHr,
          realCaloriesBurned: totalCal,
          dataSource: hasReal ? _healthService.dataSourceName : 'estimate',
        ),
      );
    } on Exception catch (e) {
      AppLogger.error(
        'Failed to aggregate session health data: $e',
        'HealthRepository',
      );
      return const Right(SessionHealthData(dataSource: 'estimate'));
    }
  }

  /// Gets a complete daily health summary.
  Future<Either<HealthFailure, DailyHealthSummary>>
  getDailyHealthSummary() async {
    try {
      final stepsResult = await getTodaySteps();
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final calResult = await getSessionCalories(start: startOfDay, end: now);

      return Right(
        DailyHealthSummary(
          steps: stepsResult.fold((_) => null, (v) => v),
          activeCalories: calResult.fold((_) => null, (v) => v),
        ),
      );
    } on Exception catch (e) {
      return Left(HealthFailure('Failed to get daily summary: $e'));
    }
  }

  /// Saves a workout to HealthKit.
  Future<Either<HealthFailure, bool>> saveWorkout({
    required HealthWorkoutActivityType activityType,
    required DateTime start,
    required DateTime end,
    required double totalCalories,
  }) async {
    try {
      final success = await _healthService.writeWorkout(
        activityType: activityType,
        start: start,
        end: end,
        totalCalories: totalCalories,
      );
      return Right(success);
    } on Exception catch (e) {
      return Left(HealthFailure('Failed to save workout: $e'));
    }
  }
}
