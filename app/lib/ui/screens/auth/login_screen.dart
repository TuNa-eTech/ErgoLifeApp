import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ergo_life_app/blocs/auth/auth_bloc.dart';
import 'package:ergo_life_app/blocs/auth/auth_state.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';
import 'package:ergo_life_app/ui/screens/auth/widgets/language_switcher.dart';
import 'package:ergo_life_app/ui/screens/auth/widgets/branding_section.dart';
import 'package:ergo_life_app/ui/screens/auth/widgets/title_section.dart';
import 'package:ergo_life_app/ui/screens/auth/widgets/social_proof.dart';
import 'package:ergo_life_app/ui/screens/auth/widgets/feature_highlights.dart';
import 'package:ergo_life_app/ui/screens/auth/widgets/auth_buttons_section.dart';
import 'package:ergo_life_app/ui/screens/auth/widgets/footer.dart';

/// Minimalist modern login screen for ErgoLife.
///
/// Design Philosophy:
/// - Clean, spacious layout with focus on simplicity
/// - Feature highlights for value proposition
/// - Social proof for trust building
/// - Subtle animations for engagement without distraction
/// - Clear visual hierarchy
/// - Brand-consistent color palette
class LoginScreen extends StatefulWidget {
  final AuthBloc authBloc;

  const LoginScreen({super.key, required this.authBloc});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.authBloc,
      child: const _LoginScreenContent(),
    );
  }
}

class _LoginScreenContent extends StatefulWidget {
  const _LoginScreenContent();

  @override
  State<_LoginScreenContent> createState() => _LoginScreenContentState();
}

class _LoginScreenContentState extends State<_LoginScreenContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.user.needsOnboarding) {
            context.go(AppRouter.onboarding);
          } else {
            context.go(AppRouter.home);
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        body: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return Column(
                children: [
                  // Top spacing with language switcher
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
                    child: LanguageSwitcher(
                      isDark: isDark,
                      animationController: _animationController,
                    ),
                  ),

                  // Main content - centered and fitted
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(height: 8),

                          // Logo & Branding Section
                          BrandingSection(
                            isDark: isDark,
                            animationController: _animationController,
                          ),

                          // Title Section
                          TitleSection(
                            isDark: isDark,
                            animationController: _animationController,
                          ),

                          // Social Proof
                          SocialProof(
                            isDark: isDark,
                            animationController: _animationController,
                          ),

                          // Feature Highlights
                          FeatureHighlights(
                            isDark: isDark,
                            animationController: _animationController,
                          ),

                          // Auth Buttons
                          AuthButtonsSection(
                            isDark: isDark,
                            isLoading: isLoading,
                            animationController: _animationController,
                          ),

                          // Footer
                          LoginFooter(
                            isDark: isDark,
                            animationController: _animationController,
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
