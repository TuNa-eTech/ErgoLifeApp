import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/core/di/service_locator.dart';
import 'package:ergo_life_app/blocs/session/session_bloc.dart';
import 'package:ergo_life_app/blocs/session/session_event.dart';
import 'package:ergo_life_app/blocs/session/session_state.dart';
import 'package:ergo_life_app/data/models/task_model.dart';
import 'package:ergo_life_app/ui/common/widgets/glass_button.dart';
import 'package:ergo_life_app/ui/screens/tasks/widgets/swipe_to_end_button.dart';
import 'package:ergo_life_app/ui/screens/tasks/widgets/session_stat_item.dart';

/// Screen showing active exercise session with real timer and stats
class ActiveSessionScreen extends StatelessWidget {
  final TaskModel task;

  const ActiveSessionScreen({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SessionBloc>(
      create: (_) => sl<SessionBloc>()..add(StartSession(task: task)),
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
        // Handle session completion
        if (state is SessionCompleted) {
          _showCompletionDialog(context, state);
        } else if (state is SessionError) {
          _showErrorSnackBar(context, state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          body: Column(
            children: [
              // Top Image Section (approx 55% height)
              Expanded(flex: 55, child: _buildTopSection(context, isDark)),

              // Bottom Content Section (approx 45% height)
              Expanded(
                flex: 45,
                child: _buildBottomSection(context, isDark, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopSection(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(48),
          bottomRight: Radius.circular(48),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          _buildBackgroundImage(),
          _buildTopGradient(),
          _buildHeader(context),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: Image.asset(
        "assets/images/active_session_bg.png",
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTopGradient() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 128,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.8),
              Colors.white.withValues(alpha: 0.3),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GlassButton(
                icon: Icons.keyboard_arrow_down,
                onTap: () => _handleBackButton(context),
              ),
              _buildTitleWithIndicator(),
              BlocBuilder<SessionBloc, SessionState>(
                builder: (context, state) {
                  if (state is SessionActive) {
                    return GlassButton(
                      icon: state.isPaused ? Icons.play_arrow : Icons.pause,
                      onTap: () {
                        if (state.isPaused) {
                          context.read<SessionBloc>().add(const ResumeSession());
                        } else {
                          context.read<SessionBloc>().add(const PauseSession());
                        }
                      },
                    );
                  }
                  return const GlassButton(icon: Icons.more_horiz);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWithIndicator() {
    return Row(
      children: [
        const PulsingRecordIndicator(),
        const SizedBox(width: 8),
        const Text(
          'Active Session',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    bool isDark,
    SessionState state,
  ) {
    if (state is SessionCompleting) {
      return _buildCompletingView(isDark);
    }

    if (state is! SessionActive) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTimerSection(isDark, state),
          _buildStatsRow(isDark, state),
          _buildTaskInfo(isDark),
          SwipeToEndButton(
            isDark: isDark,
            onComplete: () => _handleCompleteSession(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection(bool isDark, SessionActive state) {
    return Column(
      children: [
        Text(
          state.formattedTime,
          style: TextStyle(
            fontSize: 88,
            fontWeight: FontWeight.w900,
            height: 1.0,
            letterSpacing: -4,
            color: isDark ? AppColors.textMainDark : const Color(0xFF0F172A),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer, color: AppColors.secondary, size: 20),
            const SizedBox(width: 6),
            Text(
              'TARGET ${state.formattedTarget}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: isDark
                    ? AppColors.textMainDark
                    : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        if (state.isPaused) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pause_circle, color: Colors.orange, size: 16),
                SizedBox(width: 6),
                Text(
                  'PAUSED',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsRow(bool isDark, SessionActive state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SessionStatItem(
          icon: Icons.local_fire_department,
          value: '${state.estimatedCalories}',
          label: 'CALORIES',
          color: AppColors.secondary,
          isDark: isDark,
        ),
        Container(
          height: 32,
          width: 1,
          margin: const EdgeInsets.symmetric(horizontal: 40),
          color: Colors.grey.withValues(alpha: 0.3),
        ),
        SessionStatItem(
          icon: Icons.bolt,
          value: '${state.estimatedPoints}',
          label: 'POINTS',
          color: Colors.amber,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildTaskInfo(bool isDark) {
    return Column(
      children: [
        Text(
          task.exerciseName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textMainDark : const Color(0xFF0F172A),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          task.taskDescription?.toUpperCase() ?? 'EXERCISE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
          ),
        ),
      ],
    );
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
              color: isDark ? AppColors.textMainDark : const Color(0xFF0F172A),
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

  void _handleCompleteSession(BuildContext context) {
    context.read<SessionBloc>().add(const CompleteSession());
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Session?'),
        content: const Text(
          'Your progress will not be saved. Are you sure you want to cancel?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continue Session'),
          ),
          TextButton(
            onPressed: () {
              context.read<SessionBloc>().add(const CancelSession());
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, SessionCompleted state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 32),
            SizedBox(width: 12),
            Text('Great Job!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You earned ${state.pointsEarned} points!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('New balance: ${state.newWalletBalance} EP'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
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

class PulsingRecordIndicator extends StatefulWidget {
  const PulsingRecordIndicator({super.key});

  @override
  State<PulsingRecordIndicator> createState() => _PulsingRecordIndicatorState();
}

class _PulsingRecordIndicatorState extends State<PulsingRecordIndicator>
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
          // Ping animation
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 2.0).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Curves.easeOut,
              ),
            ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.75, end: 0.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeOut,
                ),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ),
          // Solid center
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
