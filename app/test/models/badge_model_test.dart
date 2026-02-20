import 'package:flutter_test/flutter_test.dart';
import 'package:ergo_life_app/data/models/badge_model.dart';

void main() {
  const tJson = {
    'id': 'badge-uuid',
    'code': 'STREAK_7',
    'category': 'streak',
    'icon': 'local_fire_department',
    'color': '#FF5722',
    'rarity': 'COMMON',
    'name': '7-Day Warrior',
    'description': 'Maintain a 7-day streak',
    'isEarned': true,
    'progress': 1.0,
    'unlockedAt': '2026-02-20T08:00:00Z',
    'conditionType': 'streak',
    'conditionValue': 7,
    'currentValue': 10,
  };

  const tBadge = BadgeModel(
    id: 'badge-uuid',
    code: 'STREAK_7',
    category: 'streak',
    icon: 'local_fire_department',
    color: '#FF5722',
    rarity: 'COMMON',
    name: '7-Day Warrior',
    description: 'Maintain a 7-day streak',
    isEarned: true,
    progress: 1.0,
    unlockedAt: '2026-02-20T08:00:00Z',
    conditionType: 'streak',
    conditionValue: 7,
    currentValue: 10,
  );

  group('BadgeModel', () {
    test('fromJson creates correct model', () {
      final badge = BadgeModel.fromJson(tJson);
      expect(badge, equals(tBadge));
    });

    test('toJson returns correct map', () {
      final json = tBadge.toJson();
      expect(json['id'], 'badge-uuid');
      expect(json['code'], 'STREAK_7');
      expect(json['rarity'], 'COMMON');
      expect(json['isEarned'], true);
      expect(json['progress'], 1.0);
      expect(json['conditionValue'], 7);
      expect(json['currentValue'], 10);
    });

    test('copyWith creates copy with updated fields', () {
      final updated = tBadge.copyWith(
        isEarned: false,
        progress: 0.5,
        currentValue: 3,
      );

      expect(updated.isEarned, false);
      expect(updated.progress, 0.5);
      expect(updated.currentValue, 3);
      expect(updated.code, 'STREAK_7');
      expect(updated.name, '7-Day Warrior');
    });

    test('Equatable equality', () {
      final badge1 = BadgeModel.fromJson(tJson);
      final badge2 = BadgeModel.fromJson(tJson);
      expect(badge1, equals(badge2));
    });

    test('Equatable inequality on different rarity', () {
      final badge1 = BadgeModel.fromJson(tJson);
      final badge2 = badge1.copyWith(rarity: 'LEGENDARY');
      expect(badge1, isNot(equals(badge2)));
    });

    group('rarity helpers', () {
      test('isCommon', () {
        expect(tBadge.isCommon, true);
        expect(tBadge.isRare, false);
      });

      test('isRare', () {
        final rare = tBadge.copyWith(rarity: 'RARE');
        expect(rare.isRare, true);
        expect(rare.isCommon, false);
      });

      test('isEpic', () {
        final epic = tBadge.copyWith(rarity: 'EPIC');
        expect(epic.isEpic, true);
      });

      test('isLegendary', () {
        final legendary = tBadge.copyWith(rarity: 'LEGENDARY');
        expect(legendary.isLegendary, true);
      });
    });

    test('fromJson handles null description', () {
      final json = Map<String, dynamic>.from(tJson);
      json['description'] = null;
      final badge = BadgeModel.fromJson(json);
      expect(badge.description, isNull);
    });

    test('fromJson handles null unlockedAt', () {
      final json = Map<String, dynamic>.from(tJson);
      json['unlockedAt'] = null;
      final badge = BadgeModel.fromJson(json);
      expect(badge.unlockedAt, isNull);
    });
  });
}
