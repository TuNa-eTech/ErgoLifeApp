import 'package:equatable/equatable.dart';

/// Model representing a badge/achievement.
class BadgeModel extends Equatable {
  final String id;
  final String code;
  final String category;
  final String icon;
  final String color;
  final String rarity;
  final String name;
  final String? description;
  final bool isEarned;
  final double progress;
  final String? unlockedAt;
  final String conditionType;
  final int conditionValue;
  final int currentValue;

  const BadgeModel({
    required this.id,
    required this.code,
    required this.category,
    required this.icon,
    required this.color,
    required this.rarity,
    required this.name,
    this.description,
    required this.isEarned,
    required this.progress,
    this.unlockedAt,
    required this.conditionType,
    required this.conditionValue,
    required this.currentValue,
  });

  /// Creates a [BadgeModel] from a JSON map.
  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] as String,
      code: json['code'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      rarity: json['rarity'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isEarned: json['isEarned'] as bool,
      progress: (json['progress'] as num).toDouble(),
      unlockedAt: json['unlockedAt'] as String?,
      conditionType: json['conditionType'] as String,
      conditionValue: json['conditionValue'] as int,
      currentValue: json['currentValue'] as int,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'category': category,
    'icon': icon,
    'color': color,
    'rarity': rarity,
    'name': name,
    'description': description,
    'isEarned': isEarned,
    'progress': progress,
    'unlockedAt': unlockedAt,
    'conditionType': conditionType,
    'conditionValue': conditionValue,
    'currentValue': currentValue,
  };

  /// Creates a copy with updated fields.
  BadgeModel copyWith({
    String? id,
    String? code,
    String? category,
    String? icon,
    String? color,
    String? rarity,
    String? name,
    String? description,
    bool? isEarned,
    double? progress,
    String? unlockedAt,
    String? conditionType,
    int? conditionValue,
    int? currentValue,
  }) {
    return BadgeModel(
      id: id ?? this.id,
      code: code ?? this.code,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      rarity: rarity ?? this.rarity,
      name: name ?? this.name,
      description: description ?? this.description,
      isEarned: isEarned ?? this.isEarned,
      progress: progress ?? this.progress,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      conditionType: conditionType ?? this.conditionType,
      conditionValue: conditionValue ?? this.conditionValue,
      currentValue: currentValue ?? this.currentValue,
    );
  }

  /// Whether this is a common rarity badge.
  bool get isCommon => rarity == 'COMMON';

  /// Whether this is a rare rarity badge.
  bool get isRare => rarity == 'RARE';

  /// Whether this is an epic rarity badge.
  bool get isEpic => rarity == 'EPIC';

  /// Whether this is a legendary rarity badge.
  bool get isLegendary => rarity == 'LEGENDARY';

  @override
  List<Object?> get props => [
    id,
    code,
    category,
    icon,
    color,
    rarity,
    name,
    description,
    isEarned,
    progress,
    unlockedAt,
    conditionType,
    conditionValue,
    currentValue,
  ];
}
