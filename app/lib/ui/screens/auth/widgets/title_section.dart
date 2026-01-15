import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/l10n/app_localizations.dart';

/// Title and subtitle section for login screen.
class TitleSection extends StatelessWidget {
  final bool isDark;
  final AnimationController animationController;

  const TitleSection({
    super.key,
    required this.isDark,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final animation = CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(animation),
        child: Column(
          children: [
            Text(
              l10n.startYourJourney,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textMainLight,
                height: 1.2,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.buildBetterHabits,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white60 : AppColors.textSubLight,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
