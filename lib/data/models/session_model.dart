import 'dart:convert';
import 'package:equatable/equatable.dart';

class SessionModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final int duration; // in seconds
  final DateTime startTime;
  final DateTime? endTime;
  final String status; // 'active', 'completed', 'paused'

  const SessionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.startTime,
    this.endTime,
    required this.status,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      duration: json['duration'] as int,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null 
          ? DateTime.parse(json['end_time'] as String) 
          : null,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration': duration,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'status': status,
    };
  }

  String toJsonString() => json.encode(toJson());

  factory SessionModel.fromJsonString(String jsonString) {
    return SessionModel.fromJson(json.decode(jsonString));
  }

  SessionModel copyWith({
    String? id,
    String? title,
    String? description,
    int? duration,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
  }) {
    return SessionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, title, description, duration, startTime, endTime, status];
}
