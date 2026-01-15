import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/l10n/app_localizations.dart';

/// Footer with terms and privacy text.
class LoginFooter extends StatelessWidget {
  final bool isDark;
  final AnimationController animationController;

  const LoginFooter({
    super.key,
    required this.isDark,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final animation = CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: animation,
      child: Text(
        l10n.termsPrivacyPolicy,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          height: 1.4,
          color: isDark
              ? Colors.white.withOpacity(0.4)
              : AppColors.textSubLight.withOpacity(0.6),
        ),
      ),
    );
  }
}
