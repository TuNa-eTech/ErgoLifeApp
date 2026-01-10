import 'package:equatable/equatable.dart';

class RewardModel extends Equatable {
  final String id;
  final String title;
  final int cost;
  final String icon;
  final String? description;
  final bool isActive;
  final DateTime createdAt;

  const RewardModel({
    required this.id,
    required this.title,
    required this.cost,
    required this.icon,
    this.description,
    required this.isActive,
    required this.createdAt,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'] as String,
      title: json['title'] as String,
      cost: json['cost'] as int,
      icon: json['icon'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'cost': cost,
      'icon': icon,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    cost,
    icon,
    description,
    isActive,
    createdAt,
  ];
}
