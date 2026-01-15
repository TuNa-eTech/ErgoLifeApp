import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/l10n/app_localizations.dart';

/// Social proof badge to build trust.
class SocialProof extends StatelessWidget {
  final bool isDark;
  final AnimationController animationController;

  const SocialProof({
    super.key,
    required this.isDark,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final animation = CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(animation),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                l10n.joinUsersWorldwide,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.primary.withOpacity(0.9)
                      : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
