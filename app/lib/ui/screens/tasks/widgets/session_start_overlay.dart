import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/data/models/task_model.dart';
import 'package:ergo_life_app/ui/screens/tasks/widgets/motivation_context_bar.dart';
import 'package:ergo_life_app/ui/screens/tasks/widgets/hero_start_button.dart';
import 'package:ergo_life_app/ui/screens/tasks/widgets/quick_actions_strip.dart';

/// Beautiful overlay displayed when session is pending, waiting for user to start
/// Enhanced with particles, hero animations, motivation, and rich stats
class SessionStartOverlay extends StatefulWidget {
  final TaskModel task;
  final String formattedTarget;
  final VoidCallback onStart;
  final VoidCallback onCancel;
  final int currentStreak;

  const SessionStartOverlay({
    super.key,
    required this.task,
    required this.formattedTarget,
    required this.onStart,
    required this.onCancel,
    this.currentStreak = 0,
  });

  @override
  State<SessionStartOverlay> createState() => _SessionStartOverlayState();
}

class _SessionStartOverlayState extends State<SessionStartOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Fade in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Slide up animation for content
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          // Background with particles
          _buildBackground(isDark),
          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, isDark),
                Expanded(child: _buildContent(isDark)),
                _buildBottomSection(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  Colors.black.withValues(alpha: 0.95),
                  const Color(0xFF0F1115).withValues(alpha: 0.98),
                ]
              : [
                  Colors.white.withValues(alpha: 0.95),
                  const Color(0xFFF5F6F8).withValues(alpha: 0.98),
                ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildGlassButton(icon: Icons.close, onTap: widget.onCancel),
          Text(
            'Ready to Start',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
          const SizedBox(width: 44), // Balance the header
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: Colors.grey[700], size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            // Simple task icon
            _buildSimpleTaskIcon(isDark),
            const SizedBox(height: 24),
            // Task name
            Text(
              widget.task.exerciseName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            // Task description
            if (widget.task.taskDescription != null)
              Text(
                widget.task.taskDescription!,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.textSubDark
                      : AppColors.textSubLight,
                  height: 1.4,
                ),
              ),
            const SizedBox(height: 20),
            // Motivation context bar
            if (widget.currentStreak > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: MotivationContextBar(
                  currentStreak: widget.currentStreak,
                  isDark: isDark,
                ),
              ),
            // Enhanced stats
            _buildEnhancedStats(isDark),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleTaskIcon(bool isDark) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(widget.task.icon, size: 44, color: Colors.white),
    );
  }

  Widget _buildEnhancedStats(bool isDark) {
    // Calculate estimated calories
    final estimatedCalories =
        (widget.task.metsValue * widget.task.durationMinutes * 3.5 * 70 / 200)
            .round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCompactStatItem(
            icon: Icons.timer_outlined,
            value: widget.formattedTarget,
            label: 'Duration',
            color: AppColors.primary,
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
          _buildCompactStatItem(
            icon: Icons.local_fire_department,
            value: '$estimatedCalories',
            label: 'Calories',
            color: AppColors.secondary,
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
          _buildCompactStatItem(
            icon: Icons.bolt,
            value:
                '${(widget.task.durationSeconds ~/ 60 * widget.task.metsValue * 10).round()}',
            label: 'Points',
            color: Colors.amber,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          // Quick actions
          QuickActionsStrip(
            isDark: isDark,
            onFavoriteTap: () {
              // TODO: Implement favorite toggle
            },
            onShareTap: () {
              // TODO: Implement share
            },
            onStatsTap: () {
              // TODO: Show detailed stats
            },
          ),
          const SizedBox(height: 16),
          // Hero start button
          HeroStartButton(
            onTap: widget.onStart,
            primaryColor: AppColors.secondary,
            secondaryColor: const Color(0xFFFF8C00),
          ),
          const SizedBox(height: 16),
          // Tap hint
          Text(
            'Tap to begin your session',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
