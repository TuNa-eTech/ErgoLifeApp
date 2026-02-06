import 'package:flutter/material.dart';
import 'package:ergo_life_app/data/models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Widget to display a single notification item
class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.streakReminder:
      case NotificationType.streakMilestone:
        return Icons.local_fire_department_rounded;
      case NotificationType.streakLost:
        return Icons.warning_amber_rounded;
      case NotificationType.activityCompleted:
        return Icons.check_circle_rounded;
      case NotificationType.houseInvite:
        return Icons.home_rounded;
      case NotificationType.memberJoined:
        return Icons.person_add_rounded;
      case NotificationType.leaderboardChange:
        return Icons.leaderboard_rounded;
      case NotificationType.houseActivity:
        return Icons.group_rounded;
      case NotificationType.newReward:
      case NotificationType.enoughPoints:
        return Icons.card_giftcard_rounded;
      case NotificationType.redemptionApproved:
        return Icons.check_circle_outline_rounded;
      case NotificationType.redemptionRejected:
        return Icons.cancel_outlined;
      case NotificationType.welcome:
        return Icons.waving_hand_rounded;
      case NotificationType.appUpdate:
        return Icons.update_rounded;
    }
  }

  Color _getColorForPriority(
    BuildContext context,
    NotificationPriority priority,
  ) {
    final theme = Theme.of(context);
    switch (priority) {
      case NotificationPriority.low:
        return theme.textTheme.bodySmall?.color ?? Colors.grey;
      case NotificationPriority.medium:
        return theme.colorScheme.primary;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.urgent:
        return theme.colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = notification.isRead
        ? (theme.dividerColor)
        : theme.colorScheme.primary.withOpacity(0.3);
    final bgColor = notification.isRead
        ? theme.cardColor
        : theme.colorScheme.primary.withOpacity(0.05);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getColorForPriority(
                    context,
                    notification.priority,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForType(notification.type),
                  color: _getColorForPriority(context, notification.priority),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      timeago.format(notification.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
