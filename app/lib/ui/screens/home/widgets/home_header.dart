import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';

/// Header widget for home screen
/// Contains avatar, notification button, date and greeting
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.isDark,
    this.userName = 'Minh',
    this.avatarUrl,
    this.onNotificationTap,
    this.onAvatarLongPress,
    super.key,
  });

  final bool isDark;
  final String userName;
  final String? avatarUrl;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarLongPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 0,
        left: 24,
        right: 24,
      ), // Removed horizontal padding
      child: Row(
        children: [
          // Left: Avatar
          _buildCompactAvatar(),
          const SizedBox(width: 12),

          // Middle: Greeting & Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildCompactGreeting(), _buildCompactDate()],
            ),
          ),

          // Right: Notification Bell
          _buildCompactNotificationButton(),
        ],
      ),
    );
  }

  Widget _buildCompactAvatar() {
    return GestureDetector(
      onLongPress: onAvatarLongPress,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: CircleAvatar(
          radius: 18, // Smaller avatar
          backgroundImage: avatarUrl != null
              ? NetworkImage(avatarUrl!)
              : const AssetImage("assets/images/default_avatar.png"),
        ),
      ),
    );
  }

  Widget _buildCompactGreeting() {
    return Text(
      'Hello, $userName!', // Minimal greeting
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
      ),
    );
  }

  Widget _buildCompactDate() {
    return Text(
      _getCurrentDate(),
      style: TextStyle(
        fontSize: 12,
        color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
      ),
    );
  }

  Widget _buildCompactNotificationButton() {
    return IconButton(
      onPressed: onNotificationTap,
      icon: Icon(
        Icons.notifications_none_rounded, // Cleaner icon
        color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];

    return '$weekday, $month ${now.day}';
  }
}
