import 'dart:convert';
import 'package:equatable/equatable.dart';

/// Notification priority levels
enum NotificationPriority {
  low,
  medium,
  high,
  urgent;

  String toJson() => name;

  static NotificationPriority fromJson(String json) {
    return NotificationPriority.values.firstWhere(
      (e) => e.name == json,
      orElse: () => NotificationPriority.medium,
    );
  }
}

///  Notification types matching backend
enum NotificationType {
  // Activity & Streaks
  streakReminder,
  streakLost,
  streakMilestone,
  activityCompleted,

  // House & Social
  houseInvite,
  memberJoined,
  leaderboardChange,
  houseActivity,

  // Rewards
  newReward,
  enoughPoints,
  redemptionApproved,
  redemptionRejected,

  // System
  welcome,
  appUpdate;

  String toJson() => name;

  static NotificationType fromJson(String json) {
    return NotificationType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => NotificationType.welcome,
    );
  }
}

/// Notification model matching backend schema
class NotificationModel extends Equatable {
  final String id;
  final String userId;
  final NotificationType type;
  final NotificationPriority priority;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final String? actionUrl;
  final bool isRead;
  final bool isSent;
  final DateTime? sentAt;
  final DateTime? readAt;
  final DateTime? scheduledFor;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.priority,
    required this.title,
    required this.body,
    this.imageUrl,
    this.data,
    this.actionUrl,
    required this.isRead,
    required this.isSent,
    this.sentAt,
    this.readAt,
    this.scheduledFor,
    required this.createdAt,
  });

  /// Create from JSON (backend response)
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      type: NotificationType.fromJson(json['type'] as String? ?? 'welcome'),
      priority: NotificationPriority.fromJson(
        json['priority'] as String? ?? 'medium',
      ),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      actionUrl: json['actionUrl'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      isSent: json['isSent'] as bool? ?? false,
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'] as String)
          : null,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      scheduledFor: json['scheduledFor'] != null
          ? DateTime.parse(json['scheduledFor'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': type.toJson(),
    'priority': priority.toJson(),
    'title': title,
    'body': body,
    'imageUrl': imageUrl,
    'data': data,
    'actionUrl': actionUrl,
    'isRead': isRead,
    'isSent': isSent,
    'sentAt': sentAt?.toIso8601String(),
    'readAt': readAt?.toIso8601String(),
    'scheduledFor': scheduledFor?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  /// Create copy with modifications
  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    NotificationPriority? priority,
    String? title,
    String? body,
    String? imageUrl,
    Map<String, dynamic>? data,
    String? actionUrl,
    bool? isRead,
    bool? isSent,
    DateTime? sentAt,
    DateTime? readAt,
    DateTime? scheduledFor,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      actionUrl: actionUrl ?? this.actionUrl,
      isRead: isRead ?? this.isRead,
      isSent: isSent ?? this.isSent,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON string
  String toJsonString() => json.encode(toJson());

  /// Create from JSON string
  factory NotificationModel.fromJsonString(String jsonString) {
    return NotificationModel.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    priority,
    title,
    body,
    imageUrl,
    data,
    actionUrl,
    isRead,
    isSent,
    sentAt,
    readAt,
    scheduledFor,
    createdAt,
  ];
}
