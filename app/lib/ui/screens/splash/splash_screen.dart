import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ergo_life_app/blocs/auth/auth_bloc.dart';
import 'package:ergo_life_app/blocs/auth/auth_event.dart';
import 'package:ergo_life_app/blocs/auth/auth_state.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';

class SplashScreen extends StatefulWidget {
  final AuthBloc authBloc;

  const SplashScreen({super.key, required this.authBloc});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Check authentication status
    widget.authBloc.add(const AuthCheckRequested());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //  Specific colors from design
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF23170F) : const Color(0xFFF8F7F5);
    final navyColor = isDark ? Colors.white : const Color(0xFF1D2939);
    final primaryColor = const Color(0xFFFF6A00); // Matches design primary

    return BlocListener<AuthBloc, AuthState>(
      bloc: widget.authBloc,
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // User is authenticated, go to home
          context.go(AppRouter.home);
        } else if (state is AuthUnauthenticated) {
          // User is not authenticated, go to login
          context.go(AppRouter.login);
        }
        // For AuthInitial and AuthLoading, stay on splash screen
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
        child: Column(
          children: [
            // Status Bar Placeholder (Visual only, usually handled by system)
            // Included to match design visually if needed, but in Flutter SafeArea handles spacing.
            // We can add the specific header row if we strictly want to match the HTML layout "look".
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '9:41',
                    style: TextStyle(
                      color: navyColor.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.signal_cellular_alt,
                        size: 16,
                        color: navyColor.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.wifi,
                        size: 16,
                        color: navyColor.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.battery_full,
                        size: 16,
                        color: navyColor.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Main Content Area
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  SizedBox(
                    width: 128,
                    height: 128,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                        // Logo Container
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF23170F)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(40), // 2.5rem
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.grey.shade100,
                            ),
                            boxShadow: isDark
                                ? []
                                : [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 30,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end, // Align bottom
                                children: [
                                  _buildPill(
                                    12,
                                    32,
                                    isDark ? Colors.white : const Color(0xFF1D2939),
                                  ), // Navy
                                  const SizedBox(width: 6),
                                  _buildPill(12, 48, primaryColor), // Orange
                                  const SizedBox(width: 6),
                                  _buildPill(
                                    12,
                                    24,
                                    (isDark ? Colors.white : const Color(0xFF1D2939))
                                        .withValues(alpha: 0.8),
                                  ), // Navy 80%
                                ],
                              ),
                              const SizedBox(height: 4),
                              _buildPill(48, 12, primaryColor), // Bottom Orange Pill
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Text
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 36, // text-4xl
                        fontWeight: FontWeight.w800,
                        color: navyColor,
                        letterSpacing: -1.0,
                        height: 1.0,
                      ),
                      children: [
                        const TextSpan(text: 'Ergo'),
                        TextSpan(
                          text: 'Life',
                          style: TextStyle(color: primaryColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'MOVE. ACHIEVE. CONQUER.',
                    style: TextStyle(
                      color: navyColor.withValues(alpha: 0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Loading Indicator & Version
            SizedBox(
              width: 160,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: 0.66,
                      minHeight: 6,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(primaryColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'v2.4.0',
                    style: TextStyle(
                      color: navyColor.withValues(alpha: 0.3),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildPill(double width, double height, Color color) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
