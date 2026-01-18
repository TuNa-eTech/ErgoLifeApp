import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/core/di/service_locator.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';
import 'package:ergo_life_app/blocs/home/home_bloc.dart';
import 'package:ergo_life_app/blocs/home/home_event.dart';
import 'package:ergo_life_app/blocs/home/home_state.dart';
import 'package:ergo_life_app/blocs/leaderboard/leaderboard_bloc.dart';
import 'package:ergo_life_app/blocs/leaderboard/leaderboard_event.dart';
import 'package:ergo_life_app/blocs/session/session_bloc.dart';
import 'package:ergo_life_app/blocs/session/session_event.dart';
import 'package:ergo_life_app/blocs/session/session_state.dart';
import 'package:ergo_life_app/data/models/task_model.dart';
import 'package:ergo_life_app/ui/screens/tasks/widgets/swipe_to_end_button.dart';
import 'package:ergo_life_app/ui/screens/tasks/widgets/session_start_overlay.dart';
import 'package:ergo_life_app/ui/screens/tasks/widgets/session_progress_bar.dart';
import 'package:ergo_life_app/ui/screens/tasks/widgets/compact_session_stats.dart';
import 'package:ergo_life_app/ui/widgets/streak_milestone_dialog.dart';
import 'package:ergo_life_app/ui/widgets/modern_dialog.dart';

/// Screen showing active exercise session - Redesigned for simplicity
class ActiveSessionScreen extends StatelessWidget {
  final TaskModel task;

  const ActiveSessionScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SessionBloc>(
      create: (_) => sl<SessionBloc>()..add(PrepareSession(task: task)),
      child: ActiveSessionView(task: task),
    );
  }
}

class ActiveSessionView extends StatelessWidget {
  final TaskModel task;

  const ActiveSessionView({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<SessionBloc, SessionState>(
      listener: (context, state) {
        if (state is SessionCompleted) {
          _showCompletionDialog(context, state);
        } else if (state is SessionError) {
          _showErrorSnackBar(context, state.message);
        }
      },
      builder: (context, state) {
        // Show start overlay when session is pending
        if (state is SessionPending) {
          int currentStreak = 0;
          try {
            final homeState = context.read<HomeBloc>().state;
            currentStreak = homeState is HomeLoaded
                ? homeState.stats.streakDays
                : 0;
          } catch (e) {
            currentStreak = 0;
          }

          return Scaffold(
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
            body: SessionStartOverlay(
              task: task,
              formattedTarget: state.formattedTarget,
              currentStreak: currentStreak,
              onStart: () {
                context.read<SessionBloc>().add(StartSession(task: task));
              },
              onCancel: () => Navigator.pop(context),
            ),
          );
        }

        return Scaffold(
          backgroundColor: isDark
              ? AppColors.backgroundDark
              : AppColors.backgroundLight,
          body: state is SessionCompleting
              ? _buildCompletingView(isDark)
              : state is SessionActive
              ? _buildActiveSessionView(context, state, isDark)
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildActiveSessionView(
    BuildContext context,
    SessionActive state,
    bool isDark,
  ) {
    // Check if exceeded target
    final hasExceededTarget = state.elapsedSeconds >= state.targetSeconds;
    final overtimeSeconds = hasExceededTarget
        ? state.elapsedSeconds - state.targetSeconds
        : 0;

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
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, state, isDark),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    // Task icon
                    _buildTaskIcon(isDark, hasExceededTarget),
                    const SizedBox(height: 16),
                    // Task name
                    Text(
                      task.exerciseName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textMainDark
                            : AppColors.textMainLight,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Task description/category
                    if (task.taskDescription != null)
                      Text(
                        task.taskDescription!.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: isDark
                              ? AppColors.textSubDark
                              : AppColors.textSubLight,
                        ),
                      ),
                    const SizedBox(height: 32),
                    // HUGE Timer
                    _buildTimer(state, isDark, hasExceededTarget),
                    const SizedBox(height: 12),
                    // Progress bar
                    SessionProgressBar(
                      progress: state.progress,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    // Target time or overtime indicator
                    _buildTargetOrOvertimeText(
                      state,
                      isDark,
                      hasExceededTarget,
                      overtimeSeconds,
                    ),
                    const SizedBox(height: 32),
                    // Compact stats
                    CompactSessionStats(
                      durationMinutes: state.elapsedSeconds ~/ 60,
                      calories: state.estimatedCalories,
                      points: state.estimatedPoints,
                      isDark: isDark,
                    ),
                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
            // Swipe to end button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SwipeToEndButton(
                isDark: isDark,
                onComplete: () {
                  context.read<SessionBloc>().add(const CompleteSession());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SessionActive state, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildGlassButton(
            icon: Icons.keyboard_arrow_down,
            onTap: () => _handleBackButton(context),
            isDark: isDark,
          ),
          _buildStatusIndicator(state.isPaused, isDark),
          _buildGlassButton(
            icon: state.isPaused ? Icons.play_arrow : Icons.pause,
            onTap: () {
              if (state.isPaused) {
                context.read<SessionBloc>().add(const ResumeSession());
              } else {
                context.read<SessionBloc>().add(const PauseSession());
              }
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 22),
        color: isDark ? Colors.white : Colors.black87,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildStatusIndicator(bool isPaused, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isPaused) const PulsingDot(),
        if (!isPaused) const SizedBox(width: 8),
        Text(
          isPaused ? '⏸ PAUSED' : 'ACTIVE SESSION',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isPaused
                ? Colors.orange
                : (isDark ? AppColors.textMainDark : AppColors.textMainLight),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskIcon(bool isDark, bool hasExceededTarget) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasExceededTarget ? Colors.green : AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: (hasExceededTarget ? Colors.green : AppColors.primary)
                .withValues(alpha: 0.3),
            blurRadius: hasExceededTarget ? 16 : 12,
            spreadRadius: hasExceededTarget ? 2 : 0,
          ),
        ],
      ),
      child: Icon(
        hasExceededTarget ? Icons.check_circle : task.icon,
        size: 36,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTimer(SessionActive state, bool isDark, bool hasExceededTarget) {
    return Text(
      state.formattedTime,
      style: TextStyle(
        fontSize: 96,
        fontWeight: FontWeight.w900,
        height: 1.0,
        letterSpacing: -2,
        color: hasExceededTarget
            ? Colors.green
            : (isDark ? AppColors.textMainDark : const Color(0xFF0F172A)),
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  Widget _buildTargetOrOvertimeText(
    SessionActive state,
    bool isDark,
    bool hasExceededTarget,
    int overtimeSeconds,
  ) {
    if (hasExceededTarget) {
      final overtimeMinutes = overtimeSeconds ~/ 60;
      final overtimeRemainder = overtimeSeconds % 60;
      final overtimeFormatted =
          '+${overtimeMinutes.toString().padLeft(2, '0')}:${overtimeRemainder.toString().padLeft(2, '0')}';

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.celebration, color: Colors.green, size: 16),
              const SizedBox(width: 6),
              Text(
                'TARGET EXCEEDED',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.celebration, color: Colors.green, size: 16),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'OVERTIME $overtimeFormatted',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
            ),
          ),
        ],
      );
    } else {
      return Text(
        'TARGET ${state.formattedTarget}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
        ),
      );
    }
  }

  Widget _buildCompletingView(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Saving your progress...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
        ],
      ),
    );
  }

  void _handleBackButton(BuildContext context) {
    final state = context.read<SessionBloc>().state;
    if (state is SessionActive) {
      _showCancelDialog(context);
    } else {
      Navigator.pop(context);
    }
  }

  void _showCancelDialog(BuildContext context) async {
    final confirmed = await ModernDialog.showConfirmation(
      context,
      title: 'Cancel Session?',
      message:
          'Your progress will not be saved. Are you sure you want to cancel?',
      confirmText: 'Cancel Session',
      cancelText: 'Continue',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      context.read<SessionBloc>().add(const CancelSession());
      // Navigate back to tasks screen
      context.go(AppRouter.tasks);
    }
  }

  void _showCompletionDialog(
    BuildContext context,
    SessionCompleted state,
  ) async {
    final streakInfo = state.activityResponse?.streak;
    if (streakInfo != null && streakInfo.isMilestone) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) =>
            StreakMilestoneDialog(streakDays: streakInfo.currentStreak),
      );
    }

    if (context.mounted) {
      // Build custom streak info widget if available
      Widget? streakWidget;
      if (streakInfo != null && streakInfo.info != null) {
        streakWidget = Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: streakInfo.usedFreeze
                ? Colors.orange.withValues(alpha: 0.1)
                : streakInfo.wasReset
                ? Colors.grey.withValues(alpha: 0.1)
                : Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: streakInfo.usedFreeze
                  ? Colors.orange
                  : streakInfo.wasReset
                  ? Colors.grey
                  : Colors.green,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                streakInfo.usedFreeze
                    ? Icons.ac_unit
                    : streakInfo.wasReset
                    ? Icons.refresh
                    : Icons.local_fire_department,
                color: streakInfo.usedFreeze
                    ? Colors.orange
                    : streakInfo.wasReset
                    ? Colors.grey
                    : Colors.green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  streakInfo.info!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: streakInfo.usedFreeze
                        ? Colors.orange.shade900
                        : streakInfo.wasReset
                        ? Colors.grey.shade700
                        : Colors.green.shade900,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      await ModernDialog.showSuccess(
        context,
        title: 'Session Complete! 🎉',
        message:
            'You earned ${state.pointsEarned} points!\nNew balance: ${state.newWalletBalance} EP',
        buttonText: 'Done',
        customContent: streakWidget,
      );

      if (context.mounted) {
        sl<HomeBloc>().add(const RefreshHomeData());
        sl<LeaderboardBloc>().add(const RefreshLeaderboard());
        // Navigate back to tasks screen
        context.go(AppRouter.tasks);
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            context.read<SessionBloc>().add(const CompleteSession());
          },
        ),
      ),
    );
  }
}

/// Pulsing dot indicator for active state
class PulsingDot extends StatefulWidget {
  const PulsingDot({super.key});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10,
      height: 10,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 2.0).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeOut),
            ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.75, end: 0.0).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeOut),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
