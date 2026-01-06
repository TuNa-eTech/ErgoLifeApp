import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Model representing a task that can be started
class TaskModel extends Equatable {
  final String? id;
  final String? templateId;
  final String exerciseName;
  final String? taskDescription;
  final int durationMinutes;
  final int estimatedPoints;
  final double metsValue;
  final String iconName;
  final String? animation;
  final int colorValue;
  final bool isCustom;
  final String? category;
  final int priority;
  final int sortOrder;
  final bool isHidden;
  final bool isFavorite;

  const TaskModel({
    this.id,
    this.templateId,
    required this.exerciseName,
    this.taskDescription,
    required this.durationMinutes,
    required this.estimatedPoints,
    required this.metsValue,
    this.iconName = 'fitness_center',
    this.animation,
    this.colorValue = 0xFFFF6A00,
    this.isCustom = false,
    this.category,
    this.priority = 0,
    this.sortOrder = 0,
    this.isHidden = false,
    this.isFavorite = false,
  });

  /// Create from backend API response
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    // Parse color from hex string or int
    int colorVal = 0xFFFF6A00;
    if (json['color'] != null) {
      final colorStr = json['color'] as String;
      if (colorStr.startsWith('#')) {
        colorVal = int.parse('FF${colorStr.substring(1)}', radix: 16);
      }
    } else if (json['colorValue'] != null) {
      colorVal = json['colorValue'] as int;
    }

    // Calculate estimated points: (MET * duration * 3.5 * 70kg) / 200
    final mets = (json['metsValue'] as num?)?.toDouble() ?? 3.5;
    final duration = (json['durationMinutes'] as num?)?.toInt() ?? 15;
    final estimatedPts = json['estimatedPoints'] as int? ??
        ((mets * duration * 3.5 * 70) / 200).round();

    return TaskModel(
      id: json['id'] as String?,
      templateId: json['templateId'] as String?,
      exerciseName: json['exerciseName'] as String? ?? json['name'] as String,
      taskDescription:
          json['taskDescription'] as String? ?? json['description'] as String?,
      durationMinutes: duration,
      estimatedPoints: estimatedPts,
      metsValue: mets,
      iconName: json['icon'] as String? ??
          json['iconName'] as String? ??
          'fitness_center',
      animation: json['animation'] as String?,
      colorValue: colorVal,
      isCustom: json['isCustom'] as bool? ?? json['templateId'] == null,
      category: json['category'] as String?,
      priority: json['priority'] as int? ?? 0,
      sortOrder: json['sortOrder'] as int? ?? 0,
      isHidden: json['isHidden'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  /// Create from task template (for seeding)
  factory TaskModel.fromTemplate(Map<String, dynamic> template) {
    int colorVal = 0xFFFF6A00;
    if (template['color'] != null) {
      final colorStr = template['color'] as String;
      if (colorStr.startsWith('#')) {
        colorVal = int.parse('FF${colorStr.substring(1)}', radix: 16);
      }
    }

    final mets = (template['metsValue'] as num).toDouble();
    final duration = (template['defaultDuration'] as num).toInt();
    final estimatedPts = ((mets * duration * 3.5 * 70) / 200).round();

    return TaskModel(
      id: null,
      templateId: template['id'] as String,
      exerciseName: template['name'] as String,
      taskDescription: template['description'] as String?,
      durationMinutes: duration,
      estimatedPoints: estimatedPts,
      metsValue: mets,
      iconName: template['icon'] as String? ?? 'fitness_center',
      animation: template['animation'] as String?,
      colorValue: colorVal,
      isCustom: false,
      category: template['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'exerciseName': exerciseName,
      'taskDescription': taskDescription,
      'durationMinutes': durationMinutes,
      'estimatedPoints': estimatedPoints,
      'metsValue': metsValue,
      'icon': iconName,
      'animation': animation,
      'color': '#${colorValue.toRadixString(16).substring(2).toUpperCase()}',
      'isCustom': isCustom,
      'category': category,
      'priority': priority,
      'sortOrder': sortOrder,
      'isHidden': isHidden,
      'isFavorite': isFavorite,
    };
  }

  /// Convert to seed DTO for backend
  Map<String, dynamic> toSeedDto() {
    return {
      'exerciseName': exerciseName,
      'taskDescription': taskDescription,
      'durationMinutes': durationMinutes,
      'metsValue': metsValue,
      'icon': iconName,
      'animation': animation,
      'color': '#${colorValue.toRadixString(16).substring(2).toUpperCase()}',
      'templateId': templateId,
    };
  }

  Color get color => Color(colorValue);

  IconData get icon => _iconFromName(iconName);

  bool get isHighPriority => priority > 0;

  int get durationSeconds => durationMinutes * 60;

  String get formattedDuration => '$durationMinutes min';

  String get formattedPoints => '$estimatedPoints EP';

  static IconData _iconFromName(String name) {
    const iconMap = {
      'fitness_center': Icons.fitness_center,
      'cleaning_services': Icons.cleaning_services,
      'local_laundry_service': Icons.local_laundry_service,
      'dry_cleaning': Icons.dry_cleaning,
      'shopping_cart': Icons.shopping_cart,
      'shopping_bag': Icons.shopping_bag,
      'directions_run': Icons.directions_run,
      'self_improvement': Icons.self_improvement,
      'water_drop': Icons.water_drop,
      'kitchen': Icons.kitchen,
      'local_fire_department': Icons.local_fire_department,
      'restaurant': Icons.restaurant,
      'bathroom': Icons.bathroom,
      'bed': Icons.bed,
      'air': Icons.air,
      'iron': Icons.iron,
      'checkroom': Icons.checkroom,
      'yard': Icons.yard,
      'delete': Icons.delete,
      'window': Icons.window,
      'bathtub': Icons.bathtub,
      'inventory_2': Icons.inventory_2,
      'pets': Icons.pets,
      'grass': Icons.grass,
    };
    return iconMap[name] ?? Icons.fitness_center;
  }

  TaskModel copyWith({
    String? id,
    String? templateId,
    String? exerciseName,
    String? taskDescription,
    int? durationMinutes,
    int? estimatedPoints,
    double? metsValue,
    String? iconName,
    String? animation,
    int? colorValue,
    bool? isCustom,
    String? category,
    int? priority,
    int? sortOrder,
    bool? isHidden,
    bool? isFavorite,
  }) {
    return TaskModel(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      exerciseName: exerciseName ?? this.exerciseName,
      taskDescription: taskDescription ?? this.taskDescription,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      estimatedPoints: estimatedPoints ?? this.estimatedPoints,
      metsValue: metsValue ?? this.metsValue,
      iconName: iconName ?? this.iconName,
      animation: animation ?? this.animation,
      colorValue: colorValue ?? this.colorValue,
      isCustom: isCustom ?? this.isCustom,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      sortOrder: sortOrder ?? this.sortOrder,
      isHidden: isHidden ?? this.isHidden,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
        id,
        templateId,
        exerciseName,
        taskDescription,
        durationMinutes,
        estimatedPoints,
        metsValue,
        iconName,
        animation,
        colorValue,
        isCustom,
        category,
        priority,
        sortOrder,
        isHidden,
        isFavorite,
      ];
}

// PredefinedTasks class has been removed.
// Tasks are now fetched from the API via TaskRepository.
