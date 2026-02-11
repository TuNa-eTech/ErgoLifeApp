import 'package:equatable/equatable.dart';

/// Represents a gift transaction (sent or received).
class GiftTransactionModel extends Equatable {
  final String id;
  final String senderId;
  final String? senderName;
  final String receiverId;
  final String? receiverName;
  final String rewardName;
  final String rewardIcon;
  final int pointsSpent;
  final String? message;
  final DateTime createdAt;

  const GiftTransactionModel({
    required this.id,
    required this.senderId,
    this.senderName,
    required this.receiverId,
    this.receiverName,
    required this.rewardName,
    required this.rewardIcon,
    required this.pointsSpent,
    this.message,
    required this.createdAt,
  });

  factory GiftTransactionModel.fromJson(Map<String, dynamic> json) {
    return GiftTransactionModel(
      id: json['id'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String?,
      receiverId: json['receiverId'] as String? ?? '',
      receiverName: json['receiverName'] as String?,
      rewardName: json['rewardName'] as String? ?? '',
      rewardIcon: json['rewardIcon'] as String? ?? '',
      pointsSpent: json['pointsSpent'] as int? ?? 0,
      message: json['message'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'senderName': senderName,
    'receiverId': receiverId,
    'receiverName': receiverName,
    'rewardName': rewardName,
    'rewardIcon': rewardIcon,
    'pointsSpent': pointsSpent,
    'message': message,
    'createdAt': createdAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    senderId,
    senderName,
    receiverId,
    receiverName,
    rewardName,
    rewardIcon,
    pointsSpent,
    message,
    createdAt,
  ];
}
