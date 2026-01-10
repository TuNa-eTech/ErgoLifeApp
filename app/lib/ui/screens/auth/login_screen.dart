import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ergo_life_app/blocs/auth/auth_bloc.dart';
import 'package:ergo_life_app/blocs/auth/auth_event.dart';
import 'package:ergo_life_app/blocs/auth/auth_state.dart';
import 'package:ergo_life_app/blocs/locale/locale_cubit.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';
import 'package:ergo_life_app/l10n/app_localizations.dart';

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

class _LoginScreenContent extends StatelessWidget {
  const _LoginScreenContent();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.secondary;
    final secondaryColor = isDark ? Colors.white : AppColors.textMainLight;
    final bgColor = isDark ? AppColors.backgroundDark : const Color(0xFFF2F4F7);
    final surfaceColor = isDark ? AppColors.surfaceDark : Colors.white;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Check if user needs onboarding (no house yet)
          if (state.user.needsOnboarding) {
            context.go(AppRouter.onboarding);
          } else {
            // User already has a house, go directly to home
            context.go(AppRouter.home);
          }
        } else if (state is AuthError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return Column(
                children: [
                  // Header with Language Switcher
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: isLoading
                              ? null
                              : () {
                                  context.read<LocaleCubit>().toggleLocale();
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                if (!isDark)
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.language,
                                  size: 18,
                                  color: secondaryColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  Localizations.localeOf(
                                            context,
                                          ).languageCode ==
                                          'vi'
                                      ? 'VI'
                                      : 'EN',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Main Content
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo Box
                          Transform.rotate(
                            angle: 3 * 3.14159 / 180, // 3 degrees
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.bolt,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Texts
                          Text(
                            AppLocalizations.of(context)!.loginTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: secondaryColor,
                              height: 1.1,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.loginSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.grey[400]
                                  : const Color(0xFF667085),
                            ),
                          ),
                          const SizedBox(height: 48),

                          // Loading indicator or sign-in buttons
                          if (isLoading)
                            const CircularProgressIndicator()
                          else ...[
                            // Google Button
                            _buildSocialButton(
                              isDark: isDark,
                              surfaceColor: surfaceColor,
                              textColor: secondaryColor,
                              icon: SvgPicture.string(
                                '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M23.52 12.29C23.52 11.43 23.45 10.71 23.31 10H12V14.52H18.55C18.42 15.68 17.65 17.48 15.28 19.06V22.8H19.23C21.54 20.68 22.87 17.55 23.52 12.29Z" fill="#4285F4"/><path d="M12 24C15.24 24 17.96 22.92 19.95 21.09L16 17.27C14.93 18 13.56 18.35 12 18.35C8.87 18.35 6.22 16.24 5.27 13.4H1.19V16.57C3.17 20.5 7.28 24 12 24Z" fill="#34A853"/><path d="M5.27 13.4C5.02 12.56 4.89 11.69 4.89 10.8C4.89 9.91 5.03 9.04 5.27 8.2V5.03H1.19C0.43 6.55 0 8.27 0 10.8C0 13.33 0.43 15.05 1.19 16.57L5.27 13.4Z" fill="#FBBC05"/><path d="M12 5.65C14.28 5.65 15.82 6.64 16.69 7.47L20.03 4.13C17.95 2.19 15.24 1 12 1C7.28 1 3.17 4.5 1.19 8.43L5.27 11.6C6.22 8.76 8.87 5.65 12 5.65Z" fill="#EA4335"/></svg>''',
                              ),
                              text: 'Continue with Google',
                              onPressed: () {
                                context.read<AuthBloc>().add(
                                  const AuthGoogleSignInRequested(),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Apple Button
                            _buildSocialButton(
                              isDark: isDark,
                              surfaceColor: surfaceColor,
                              textColor: secondaryColor,
                              icon: SvgPicture.string(
                                '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M17.05 20.28c-.98.95-2.05 2.3-3.73 2.3-1.6 0-2.14-1-4.04-1-1.85 0-2.45 1-4.06 1-1.63 0-3.09-1.58-4.22-3.32-2.31-3.55-2.03-9.5 2.05-12.01 1.76-1.07 3.25-.95 4.54-.33 1.13.55 2.27.52 3.32.06 1.48-.68 2.87-1.16 4.67-.17 1.76.99 2.65 2.12 3.1 3.29-.05.03-1.89 1.14-1.9 3.99-.01 2.91 2.37 4.1 2.44 4.14l-.03.1c-.34 1.13-1.15 2.65-1.97 3.96l-.17.29zm-3.66-16.73c.79-1.01 1.34-2.37 1.18-3.75-1.22.06-2.65.86-3.48 1.88-.73.88-1.39 2.3-1.2 3.63 1.37.11 2.76-.73 3.5-1.76z" fill="${isDark ? 'white' : 'black'}"/></svg>''',
                              ),
                              text: 'Continue with Apple',
                              onPressed: () {
                                context.read<AuthBloc>().add(
                                  const AuthAppleSignInRequested(),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required bool isDark,
    required Color surfaceColor,
    required Color textColor,
    required Widget icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 80, // h-20
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16), // xl roughly
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: Material(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey[50],
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: icon,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward, color: Colors.grey[300]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
