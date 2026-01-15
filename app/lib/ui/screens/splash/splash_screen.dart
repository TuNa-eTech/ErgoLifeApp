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
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    _controller.forward();

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      bloc: widget.authBloc,
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRouter.home);
        } else if (state is AuthUnauthenticated) {
          context.go(AppRouter.login);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo and branding
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildContent(isDark),
                  ),
                ),

                const Spacer(flex: 2),

                // Minimal loading indicator
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildLoadingDots(isDark),
                ),

                const SizedBox(height: 32),

                // Version
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildVersion(isDark),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    const primaryColor = Color(0xFFFF6A00);
    final textColor = isDark ? Colors.white : const Color(0xFF0A0A0A);
    final mutedColor = isDark
        ? Colors.white.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.4);

    return Column(
      children: [
        // App logo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Image.asset('assets/icons/app_icon.png', fit: BoxFit.cover),
          ),
        ),

        const SizedBox(height: 48),

        // Brand name - minimal
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: -1.5,
              height: 1.0,
            ),
            children: [
              const TextSpan(text: 'Ergo'),
              TextSpan(
                text: 'Life',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Simple tagline
        Text(
          'Move • Achieve • Conquer',
          style: TextStyle(
            color: mutedColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingDots(bool isDark) {
    const primaryColor = Color(0xFFFF6A00);
    final dotColor = isDark
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.1);

    return SizedBox(
      height: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _AnimatedDot(color: dotColor, activeColor: primaryColor, delay: 0),
          const SizedBox(width: 8),
          _AnimatedDot(color: dotColor, activeColor: primaryColor, delay: 150),
          const SizedBox(width: 8),
          _AnimatedDot(color: dotColor, activeColor: primaryColor, delay: 300),
        ],
      ),
    );
  }

  Widget _buildVersion(bool isDark) {
    final versionColor = isDark
        ? Colors.white.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.3);

    return Text(
      'v2.4.0',
      style: TextStyle(
        color: versionColor,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
      ),
    );
  }
}

/// Animated loading dot
class _AnimatedDot extends StatefulWidget {
  final Color color;
  final Color activeColor;
  final int delay;

  const _AnimatedDot({
    required this.color,
    required this.activeColor,
    required this.delay,
  });

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Start animation with delay
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.lerp(
              widget.color,
              widget.activeColor,
              _scaleAnimation.value - 1.0,
            ),
          ),
        );
      },
    );
  }
}
