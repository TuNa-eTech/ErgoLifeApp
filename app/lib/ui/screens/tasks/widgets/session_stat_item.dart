import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';

/// Session stat item showing icon, value and label
class SessionStatItem extends StatelessWidget {
  const SessionStatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
    super.key,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: isDark
                    ? AppColors.textMainDark
                    : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: isDark
                ? AppColors.textSubDark
                : AppColors.textSubLight.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
