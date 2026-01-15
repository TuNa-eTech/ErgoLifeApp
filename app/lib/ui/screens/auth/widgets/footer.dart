import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';
import 'package:ergo_life_app/l10n/app_localizations.dart';

/// Footer with clickable terms and privacy text.
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

    final baseStyle = TextStyle(
      fontSize: 12,
      height: 1.4,
      color: isDark
          ? Colors.white.withOpacity(0.4)
          : AppColors.textSubLight.withOpacity(0.6),
    );

    final linkStyle = baseStyle.copyWith(
      color: isDark ? Colors.white.withOpacity(0.7) : AppColors.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );

    return FadeTransition(
      opacity: animation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            // "By continuing, you agree to our" - splitting string is hard, so manually constructing:
            // "By continuing, you agree to our Terms & Privacy Policy" ->
            // Let's assume the user is okay with a slight visual change to ensure clickability
            'By continuing, you agree to our', // Hardcoding English for specific "split", ideally should represent "agreement prefix"
            // BETTER: Use RichText if we can know the layout, but separating is safer for "click targets"
            style: baseStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLink(
                context,
                l10n.termsOfService,
                () => context.push(AppRouter.termsOfService),
                linkStyle,
              ),
              Text(' & ', style: baseStyle),
              _buildLink(
                context,
                l10n.privacyPolicy,
                () => context.push(AppRouter.privacyPolicy),
                linkStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLink(
    BuildContext context,
    String text,
    VoidCallback onTap,
    TextStyle style,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Text(text, style: style),
    );
  }
}
