import 'package:ergo_life_app/data/models/daily_goal_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DailyGoalModel', () {
    final sampleJson = {
      'id': 'goal-uuid',
      'date': '2026-02-20',
      'targetEp': 500,
      'targetDuration': 30,
      'targetActivities': 2,
      'currentEp': 250,
      'currentDuration': 15,
      'currentActivities': 1,
      'isPerfectDay': false,
      'completedAt': null,
      'epProgress': 0.5,
      'durationProgress': 0.5,
      'activitiesProgress': 0.5,
    };

    test('fromJson creates correct model', () {
      final model = DailyGoalModel.fromJson(sampleJson);
      expect(model.id, 'goal-uuid');
      expect(model.date, '2026-02-20');
      expect(model.targetEp, 500);
      expect(model.currentEp, 250);
      expect(model.epProgress, 0.5);
      expect(model.isPerfectDay, false);
    });

    test('toJson produces correct map', () {
      final model = DailyGoalModel.fromJson(sampleJson);
      final json = model.toJson();
      expect(json['id'], 'goal-uuid');
      expect(json['targetEp'], 500);
      expect(json['epProgress'], 0.5);
    });

    test('copyWith updates specified fields', () {
      final model = DailyGoalModel.fromJson(sampleJson);
      final updated = model.copyWith(currentEp: 500, isPerfectDay: true);
      expect(updated.currentEp, 500);
      expect(updated.isPerfectDay, true);
      expect(updated.targetEp, 500);
    });

    test('isEpClosed returns true when target met', () {
      final model = DailyGoalModel.fromJson(
        sampleJson,
      ).copyWith(currentEp: 500);
      expect(model.isEpClosed, true);
    });

    test('isEpClosed returns false when below target', () {
      final model = DailyGoalModel.fromJson(sampleJson);
      expect(model.isEpClosed, false);
    });

    test('isDurationClosed returns correctly', () {
      final model = DailyGoalModel.fromJson(sampleJson);
      expect(model.isDurationClosed, false);

      final closed = model.copyWith(currentDuration: 30);
      expect(closed.isDurationClosed, true);
    });

    test('isActivitiesClosed returns correctly', () {
      final model = DailyGoalModel.fromJson(sampleJson);
      expect(model.isActivitiesClosed, false);

      final closed = model.copyWith(currentActivities: 2);
      expect(closed.isActivitiesClosed, true);
    });

    test('equatable works correctly', () {
      final model1 = DailyGoalModel.fromJson(sampleJson);
      final model2 = DailyGoalModel.fromJson(sampleJson);
      expect(model1, equals(model2));
    });
  });

  group('GoalSettingsModel', () {
    final settingsJson = {
      'targetEp': 500,
      'targetDuration': 30,
      'targetActivities': 2,
    };

    test('fromJson creates correct model', () {
      final model = GoalSettingsModel.fromJson(settingsJson);
      expect(model.targetEp, 500);
      expect(model.targetDuration, 30);
      expect(model.targetActivities, 2);
    });

    test('toJson produces correct map', () {
      final model = GoalSettingsModel.fromJson(settingsJson);
      final json = model.toJson();
      expect(json['targetEp'], 500);
      expect(json['targetDuration'], 30);
    });

    test('copyWith updates specified fields', () {
      final model = GoalSettingsModel.fromJson(settingsJson);
      final updated = model.copyWith(targetEp: 1000);
      expect(updated.targetEp, 1000);
      expect(updated.targetDuration, 30);
    });

    test('equatable works correctly', () {
      final model1 = GoalSettingsModel.fromJson(settingsJson);
      final model2 = GoalSettingsModel.fromJson(settingsJson);
      expect(model1, equals(model2));
    });
  });
}
