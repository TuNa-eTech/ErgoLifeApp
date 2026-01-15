import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';

/// Feature highlights section with 3 value propositions.
class FeatureHighlights extends StatelessWidget {
  final bool isDark;
  final AnimationController animationController;

  const FeatureHighlights({
    super.key,
    required this.isDark,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _FeatureCard(
          icon: Icons.track_changes_rounded,
          label: 'Track Habits',
          isDark: isDark,
          animationController: animationController,
          delay: 0.4,
        ),
        _FeatureCard(
          icon: Icons.emoji_events_rounded,
          label: 'Compete',
          isDark: isDark,
          animationController: animationController,
          delay: 0.5,
        ),
        _FeatureCard(
          icon: Icons.diamond_rounded,
          label: 'Earn Rewards',
          isDark: isDark,
          animationController: animationController,
          delay: 0.6,
        ),
      ],
    );
  }
}

/// Single feature card component.
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final AnimationController animationController;
  final double delay;

  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.animationController,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: animationController,
      curve: Interval(delay, delay + 0.3, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(animation),
        child: Container(
          width: 85,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: AppColors.secondary),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white.withOpacity(0.9)
                      : AppColors.textMainLight,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
