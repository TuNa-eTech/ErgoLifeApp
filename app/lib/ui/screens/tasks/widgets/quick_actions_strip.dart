import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';

/// Quick action button for the session start overlay
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            child: Icon(
              icon,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Row of quick actions
class QuickActionsStrip extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onEditTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onStatsTap;

  const QuickActionsStrip({
    super.key,
    required this.isDark,
    this.onEditTap,
    this.onFavoriteTap,
    this.onShareTap,
    this.onStatsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (onEditTap != null)
            QuickActionButton(
              icon: Icons.edit_outlined,
              label: 'Edit',
              onTap: onEditTap!,
              isDark: isDark,
            ),
          if (onFavoriteTap != null)
            QuickActionButton(
              icon: Icons.favorite_border,
              label: 'Favorite',
              onTap: onFavoriteTap!,
              isDark: isDark,
            ),
          if (onShareTap != null)
            QuickActionButton(
              icon: Icons.share_outlined,
              label: 'Share',
              onTap: onShareTap!,
              isDark: isDark,
            ),
          if (onStatsTap != null)
            QuickActionButton(
              icon: Icons.bar_chart_rounded,
              label: 'Stats',
              onTap: onStatsTap!,
              isDark: isDark,
            ),
        ],
      ),
    );
  }
}
