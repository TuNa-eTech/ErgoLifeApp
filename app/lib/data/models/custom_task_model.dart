/// Model representing a user's custom task/exercise
class CustomTaskModel {
  final String id;
  final String exerciseName;
  final String? taskDescription;
  final int durationMinutes;
  final double metsValue;
  final String icon;
  final bool isFavorite;
  final DateTime createdAt;

  const CustomTaskModel({
    required this.id,
    required this.exerciseName,
    this.taskDescription,
    required this.durationMinutes,
    required this.metsValue,
    required this.icon,
    required this.isFavorite,
    required this.createdAt,
  });

  factory CustomTaskModel.fromJson(Map<String, dynamic> json) {
    return CustomTaskModel(
      id: json['id'] as String,
      exerciseName: json['exerciseName'] as String,
      taskDescription: json['taskDescription'] as String?,
      durationMinutes: json['durationMinutes'] as int,
      metsValue: (json['metsValue'] as num).toDouble(),
      icon: json['icon'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(), // Fallback if not a string
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseName': exerciseName,
      'taskDescription': taskDescription,
      'durationMinutes': durationMinutes,
      'metsValue': metsValue,
      'icon': icon,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Calculates estimated points based on METs and duration
  /// Formula: (duration in minutes * METs * 10)
  int get estimatedPoints => (durationMinutes * metsValue * 10).floor();

  CustomTaskModel copyWith({
    String? id,
    String? exerciseName,
    String? taskDescription,
    int? durationMinutes,
    double? metsValue,
    String? icon,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return CustomTaskModel(
      id: id ?? this.id,
      exerciseName: exerciseName ?? this.exerciseName,
      taskDescription: taskDescription ?? this.taskDescription,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      metsValue: metsValue ?? this.metsValue,
      icon: icon ?? this.icon,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Request model for creating a custom task
class CreateCustomTaskRequest {
  final String exerciseName;
  final String? taskDescription;
  final int durationMinutes;
  final double? metsValue;
  final String? icon;

  const CreateCustomTaskRequest({
    required this.exerciseName,
    this.taskDescription,
    required this.durationMinutes,
    this.metsValue,
    this.icon,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'exerciseName': exerciseName,
      'durationMinutes': durationMinutes,
    };
    if (taskDescription != null) data['taskDescription'] = taskDescription;
    if (metsValue != null) data['metsValue'] = metsValue;
    if (icon != null) data['icon'] = icon;
    return data;
  }
}
