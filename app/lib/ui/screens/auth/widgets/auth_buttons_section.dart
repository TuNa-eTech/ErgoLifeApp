import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ergo_life_app/blocs/auth/auth_bloc.dart';
import 'package:ergo_life_app/blocs/auth/auth_event.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/l10n/app_localizations.dart';
import 'package:ergo_life_app/ui/screens/auth/widgets/social_button.dart';

/// Authentication buttons section with Google and Apple sign-in.
class AuthButtonsSection extends StatelessWidget {
  final bool isDark;
  final bool isLoading;
  final AnimationController animationController;

  const AuthButtonsSection({
    super.key,
    required this.isDark,
    required this.isLoading,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final animation = CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    );

    if (isLoading) {
      return _LoadingState(animation: animation, isDark: isDark);
    }

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(animation),
        child: Column(
          children: [
            // Apple Sign In
            SocialButton(
              isDark: isDark,
              icon: SvgPicture.asset(
                'assets/icons/apple-black-logo.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  isDark ? Colors.white : Colors.black,
                  BlendMode.srcIn,
                ),
              ),
              label: l10n.continueWithApple,
              onPressed: () {
                context.read<AuthBloc>().add(const AuthAppleSignInRequested());
              },
            ),

            const SizedBox(height: 16),

            // Google Sign In
            SocialButton(
              isDark: isDark,
              icon: SvgPicture.asset(
                'assets/icons/google-icon-logo.svg',
                width: 20,
                height: 20,
              ),
              label: l10n.continueWithGoogle,
              onPressed: () {
                context.read<AuthBloc>().add(const AuthGoogleSignInRequested());
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading state widget.
class _LoadingState extends StatelessWidget {
  final Animation<double> animation;
  final bool isDark;

  const _LoadingState({required this.animation, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Column(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Signing in...',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white60 : AppColors.textSubLight,
            ),
          ),
        ],
      ),
    );
  }
}
