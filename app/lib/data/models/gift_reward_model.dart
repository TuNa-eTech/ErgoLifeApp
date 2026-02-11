import 'package:equatable/equatable.dart';

/// Represents a gift reward available in the catalog.
class GiftRewardModel extends Equatable {
  final String id;
  final String key;
  final String category;
  final String icon;
  final int cost;
  final String name;
  final String? description;

  const GiftRewardModel({
    required this.id,
    required this.key,
    required this.category,
    required this.icon,
    required this.cost,
    required this.name,
    this.description,
  });

  factory GiftRewardModel.fromJson(Map<String, dynamic> json) {
    return GiftRewardModel(
      id: json['id'] as String? ?? '',
      key: json['key'] as String? ?? '',
      category: json['category'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      cost: json['cost'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'key': key,
    'category': category,
    'icon': icon,
    'cost': cost,
    'name': name,
    'description': description,
  };

  @override
  List<Object?> get props => [id, key, category, icon, cost, name, description];
}
