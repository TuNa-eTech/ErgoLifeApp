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
    super.key,
  });

  final bool isDark;
  final String userName;
  final String? avatarUrl;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24).copyWith(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopRow(),
          const SizedBox(height: 20),
          _buildDateText(),
          const SizedBox(height: 6),
          _buildGreetingText(),
        ],
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_buildAvatar(), _buildNotificationButton()],
    );
  }

  Widget _buildAvatar() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl!)
                : const AssetImage("assets/images/default_avatar.png"),
          ),
          // Online indicator
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? AppColors.backgroundDark
                      : AppColors.backgroundLight,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onNotificationTap,
        icon: Icon(
          Icons.notifications_outlined,
          color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
        ),
      ),
    );
  }

  Widget _buildDateText() {
    return Text(
      _getCurrentDate(),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 1,
        color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
      ),
    );
  }

  Widget _buildGreetingText() {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          height: 1.3,
          color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
        ),
        children: [
          const TextSpan(text: 'Chào buổi sáng,\n'),
          TextSpan(text: 'vận động viên $userName! 🚀'),
        ],
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final weekdays = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY',
    ];
    final months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    final weekday =
        weekdays[now.weekday - 1].substring(0, 1) +
        weekdays[now.weekday - 1].substring(1).toLowerCase();
    final month =
        months[now.month - 1].substring(0, 1) +
        months[now.month - 1].substring(1).toLowerCase();

    return '$weekday, $month ${now.day}';
  }
}
