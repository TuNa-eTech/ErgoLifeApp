import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';

/// Dual action buttons for house management: Join House + Invite Friends
class HouseActionsRow extends StatelessWidget {
  const HouseActionsRow({
    required this.isDark,
    this.onJoinTap,
    this.onInviteTap,
    super.key,
  });

  final bool isDark;
  final VoidCallback? onJoinTap;
  final VoidCallback? onInviteTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              isDark: isDark,
              icon: Icons.group_add_rounded,
              label: 'Join House',
              color: AppColors.secondary,
              onTap: onJoinTap,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              isDark: isDark,
              icon: Icons.share_rounded,
              label: 'Invite Friends',
              color: AppColors.primary,
              onTap: onInviteTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.isDark,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final bool isDark;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withAlpha(25), color.withAlpha(15)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
