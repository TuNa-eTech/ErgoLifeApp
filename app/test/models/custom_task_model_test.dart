import 'package:flutter_test/flutter_test.dart';
import 'package:ergo_life_app/data/models/custom_task_model.dart';

void main() {
  group('CustomTaskModel', () {
    test('fromJson should parse valid response correctly', () {
      final json = {
        'id': 'test-id-123',
        'exerciseName': 'Test Exercise',
        'taskDescription': 'Test Description',
        'durationMinutes': 30,
        'metsValue': 4.5,
        'icon': 'fitness_center',
        'isFavorite': true,
        'createdAt': '2025-12-27T10:00:00.000Z',
      };

      final model = CustomTaskModel.fromJson(json);

      expect(model.id, 'test-id-123');
      expect(model.exerciseName, 'Test Exercise');
      expect(model.taskDescription, 'Test Description');
      expect(model.durationMinutes, 30);
      expect(model.metsValue, 4.5);
      expect(model.icon, 'fitness_center');
      expect(model.isFavorite, true);
      expect(model.createdAt.isAfter(DateTime(2025, 12, 27)), true);
    });

    test('fromJson should handle null taskDescription', () {
      final json = {
        'id': 'test-id-123',
        'exerciseName': 'Test Exercise',
        'taskDescription': null,
        'durationMinutes': 30,
        'metsValue': 4.5,
        'icon': 'fitness_center',
        'isFavorite': false,
        'createdAt': '2025-12-27T10:00:00.000Z',
      };

      final model = CustomTaskModel.fromJson(json);

      expect(model.taskDescription, null);
      expect(model.isFavorite, false);
    });

    test('fromJson should handle missing isFavorite with default false', () {
      final json = {
        'id': 'test-id-123',
        'exerciseName': 'Test Exercise',
        'durationMinutes': 30,
        'metsValue': 4.5,
        'icon': 'fitness_center',
        'createdAt': '2025-12-27T10:00:00.000Z',
      };

      final model = CustomTaskModel.fromJson(json);

      expect(model.isFavorite, false);
    });

    test('fromJson should handle non-String createdAt with fallback', () {
      final json = {
        'id': 'test-id-123',
        'exerciseName': 'Test Exercise',
        'durationMinutes': 30,
        'metsValue': 4.5,
        'icon': 'fitness_center',
        'isFavorite': false,
        'createdAt': 1234567890, // Not a string
      };

      final model = CustomTaskModel.fromJson(json);

      // Should use DateTime.now() as fallback
      expect(model.createdAt.isAfter(DateTime(2020)), true);
    });

    test('estimatedPoints should calculate correctly', () {
      final json = {
        'id': 'test-id-123',
        'exerciseName': 'Test Exercise',
        'durationMinutes': 25,
        'metsValue': 4.5,
        'icon': 'fitness_center',
        'isFavorite': false,
        'createdAt': '2025-12-27T10:00:00.000Z',
      };

      final model = CustomTaskModel.fromJson(json);

      // 25 * 4.5 * 10 = 1125
      expect(model.estimatedPoints, 1125);
    });

    test('toJson should serialize correctly', () {
      final model = CustomTaskModel(
        id: 'test-id-123',
        exerciseName: 'Test Exercise',
        taskDescription: 'Test Description',
        durationMinutes: 30,
        metsValue: 4.5,
        icon: 'fitness_center',
        isFavorite: true,
        createdAt: DateTime(2025, 12, 27, 10, 0, 0),
      );

      final json = model.toJson();

      expect(json['id'], 'test-id-123');
      expect(json['exerciseName'], 'Test Exercise');
      expect(json['taskDescription'], 'Test Description');
      expect(json['durationMinutes'], 30);
      expect(json['metsValue'], 4.5);
      expect(json['icon'], 'fitness_center');
      expect(json['isFavorite'], true);
      expect(json['createdAt'], isA<String>());
    });
  });

  group('CreateCustomTaskRequest', () {
    test('toJson should include all required fields', () {
      final request = CreateCustomTaskRequest(
        exerciseName: 'Test Exercise',
        taskDescription: 'Test Description',
        durationMinutes: 30,
        metsValue: 4.5,
        icon: 'fitness_center',
      );

      final json = request.toJson();

      expect(json['exerciseName'], 'Test Exercise');
      expect(json['taskDescription'], 'Test Description');
      expect(json['durationMinutes'], 30);
      expect(json['metsValue'], 4.5);
      expect(json['icon'], 'fitness_center');
    });

    test('toJson should omit null optional fields', () {
      final request = CreateCustomTaskRequest(
        exerciseName: 'Test Exercise',
        durationMinutes: 30,
      );

      final json = request.toJson();

      expect(json['exerciseName'], 'Test Exercise');
      expect(json['durationMinutes'], 30);
      expect(json.containsKey('taskDescription'), false);
      expect(json.containsKey('metsValue'), false);
      expect(json.containsKey('icon'), false);
    });
  });
}
