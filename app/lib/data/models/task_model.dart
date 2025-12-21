import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Model representing a task that can be started
class TaskModel extends Equatable {
  final String? id;
  final String exerciseName;
  final String? taskDescription;
  final int durationMinutes;
  final int estimatedPoints;
  final double metsValue;
  final String iconName;
  final int colorValue;
  final bool isCustom;
  final String? category;
  final int priority; // 0 = normal, 1 = high

  const TaskModel({
    this.id,
    required this.exerciseName,
    this.taskDescription,
    required this.durationMinutes,
    required this.estimatedPoints,
    required this.metsValue,
    this.iconName = 'fitness_center',
    this.colorValue = 0xFFFF6A00,
    this.isCustom = false,
    this.category,
    this.priority = 0,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String?,
      exerciseName: json['exerciseName'] as String,
      taskDescription: json['taskDescription'] as String?,
      durationMinutes: json['durationMinutes'] as int,
      estimatedPoints: json['estimatedPoints'] as int,
      metsValue: (json['metsValue'] as num).toDouble(),
      iconName: json['iconName'] as String? ?? 'fitness_center',
      colorValue: json['colorValue'] as int? ?? 0xFFFF6A00,
      isCustom: json['isCustom'] as bool? ?? false,
      category: json['category'] as String?,
      priority: json['priority'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseName': exerciseName,
      'taskDescription': taskDescription,
      'durationMinutes': durationMinutes,
      'estimatedPoints': estimatedPoints,
      'metsValue': metsValue,
      'iconName': iconName,
      'colorValue': colorValue,
      'isCustom': isCustom,
      'category': category,
      'priority': priority,
    };
  }

  /// Get Flutter Color from value
  Color get color => Color(colorValue);

  /// Get Flutter IconData from name
  IconData get icon => _iconFromName(iconName);

  /// Check if high priority
  bool get isHighPriority => priority > 0;

  /// Get duration as seconds
  int get durationSeconds => durationMinutes * 60;

  /// Get formatted duration
  String get formattedDuration => '$durationMinutes min';

  /// Get formatted points
  String get formattedPoints => '$estimatedPoints EP';

  static IconData _iconFromName(String name) {
    const iconMap = {
      'fitness_center': Icons.fitness_center,
      'cleaning_services': Icons.cleaning_services,
      'local_laundry_service': Icons.local_laundry_service,
      'shopping_cart': Icons.shopping_cart,
      'shopping_bag': Icons.shopping_bag,
      'directions_run': Icons.directions_run,
      'self_improvement': Icons.self_improvement,
      'water_drop': Icons.water_drop,
      'kitchen': Icons.kitchen,
      'local_fire_department': Icons.local_fire_department,
    };
    return iconMap[name] ?? Icons.fitness_center;
  }

  TaskModel copyWith({
    String? id,
    String? exerciseName,
    String? taskDescription,
    int? durationMinutes,
    int? estimatedPoints,
    double? metsValue,
    String? iconName,
    int? colorValue,
    bool? isCustom,
    String? category,
    int? priority,
  }) {
    return TaskModel(
      id: id ?? this.id,
      exerciseName: exerciseName ?? this.exerciseName,
      taskDescription: taskDescription ?? this.taskDescription,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      estimatedPoints: estimatedPoints ?? this.estimatedPoints,
      metsValue: metsValue ?? this.metsValue,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      isCustom: isCustom ?? this.isCustom,
      category: category ?? this.category,
      priority: priority ?? this.priority,
    );
  }

  @override
  List<Object?> get props => [
        id,
        exerciseName,
        taskDescription,
        durationMinutes,
        estimatedPoints,
        metsValue,
        iconName,
        colorValue,
        isCustom,
        category,
        priority,
      ];
}

/// Predefined tasks for quick start
class PredefinedTasks {
  static const List<TaskModel> quickTasks = [
    TaskModel(
      id: 'task_1',
      exerciseName: 'Legs & Glutes',
      taskDescription: 'Vacuuming the Living Room',
      durationMinutes: 20,
      estimatedPoints: 150,
      metsValue: 3.5,
      iconName: 'cleaning_services',
      colorValue: 0xFF9C27B0,
      category: 'cleaning',
    ),
    TaskModel(
      id: 'task_2',
      exerciseName: 'Upper Body Press',
      taskDescription: 'Laundry Loading & Hanging',
      durationMinutes: 15,
      estimatedPoints: 80,
      metsValue: 2.5,
      iconName: 'local_laundry_service',
      colorValue: 0xFF2196F3,
      category: 'laundry',
    ),
    TaskModel(
      id: 'task_3',
      exerciseName: 'Cardio Dash',
      taskDescription: 'Grocery Run (Heavy Load)',
      durationMinutes: 45,
      estimatedPoints: 200,
      metsValue: 4.0,
      iconName: 'shopping_bag',
      colorValue: 0xFF4CAF50,
      category: 'shopping',
    ),
    TaskModel(
      id: 'task_4',
      exerciseName: 'Core Stability',
      taskDescription: 'Dishwashing',
      durationMinutes: 10,
      estimatedPoints: 50,
      metsValue: 2.0,
      iconName: 'water_drop',
      colorValue: 0xFF00BCD4,
      category: 'kitchen',
    ),
    TaskModel(
      id: 'task_5',
      exerciseName: 'Full Body Blitz',
      taskDescription: 'Deep Clean Living Room & Kitchen',
      durationMinutes: 45,
      estimatedPoints: 350,
      metsValue: 4.5,
      iconName: 'local_fire_department',
      colorValue: 0xFFFF6A00,
      category: 'cleaning',
      priority: 1,
    ),
  ];

  static TaskModel? getHighPriorityTask() {
    try {
      return quickTasks.firstWhere((t) => t.isHighPriority);
    } catch (_) {
      return null;
    }
  }

  static List<TaskModel> getNormalTasks() {
    return quickTasks.where((t) => !t.isHighPriority).toList();
  }
}
