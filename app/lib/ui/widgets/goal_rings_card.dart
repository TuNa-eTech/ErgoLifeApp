import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/daily_goal/daily_goal_bloc.dart';
import 'package:ergo_life_app/blocs/daily_goal/daily_goal_event.dart';
import 'package:ergo_life_app/blocs/daily_goal/daily_goal_state.dart';
import 'package:ergo_life_app/data/models/daily_goal_model.dart';

/// Displays 3 concentric animated goal rings on the Home Screen.
///
/// Outer ring = EP (primary/orange), Middle = Duration (green),
/// Inner = Activities (blue). Center shows Perfect Day checkmark.
class GoalRingsCard extends StatelessWidget {
  const GoalRingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DailyGoalBloc, DailyGoalState>(
      builder: (context, state) {
        if (state is DailyGoalLoading) {
          return const _RingsPlaceholder();
        }

        if (state is DailyGoalError) {
          return _ErrorCard(
            message: state.message,
            onRetry: () =>
                context.read<DailyGoalBloc>().add(const LoadTodayGoal()),
          );
        }

        if (state is DailyGoalLoaded) {
          return _GoalRingsContent(goal: state.goal);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _GoalRingsContent extends StatelessWidget {
  final DailyGoalModel goal;

  const _GoalRingsContent({required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rings
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: _GoalRingsPainter(
                epProgress: goal.epProgress.clamp(0.0, 1.0),
                durationProgress: goal.durationProgress.clamp(0.0, 1.0),
                activitiesProgress: goal.activitiesProgress.clamp(0.0, 1.0),
                isPerfectDay: goal.isPerfectDay,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.isPerfectDay ? '🎉 Perfect Day!' : 'Daily Goals',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                _RingLabel(
                  color: const Color(0xFFFF6A00),
                  label: 'EP',
                  current: goal.currentEp,
                  target: goal.targetEp,
                  isClosed: goal.isEpClosed,
                ),
                const SizedBox(height: 4),
                _RingLabel(
                  color: const Color(0xFF4CAF50),
                  label: 'Duration',
                  current: goal.currentDuration,
                  target: goal.targetDuration,
                  suffix: 'min',
                  isClosed: goal.isDurationClosed,
                ),
                const SizedBox(height: 4),
                _RingLabel(
                  color: const Color(0xFF2196F3),
                  label: 'Activities',
                  current: goal.currentActivities,
                  target: goal.targetActivities,
                  isClosed: goal.isActivitiesClosed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingLabel extends StatelessWidget {
  final Color color;
  final String label;
  final int current;
  final int target;
  final String? suffix;
  final bool isClosed;

  const _RingLabel({
    required this.color,
    required this.label,
    required this.current,
    required this.target,
    this.suffix,
    required this.isClosed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suffixText = suffix != null ? ' $suffix' : '';
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          '$current / $target$suffixText',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isClosed ? color : null,
          ),
        ),
        if (isClosed) ...[
          const SizedBox(width: 4),
          Icon(Icons.check_circle, size: 14, color: color),
        ],
      ],
    );
  }
}

class _RingsPlaceholder extends StatelessWidget {
  const _RingsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      height: 132,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodySmall),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

/// Custom painter that draws 3 concentric arcs.
class _GoalRingsPainter extends CustomPainter {
  final double epProgress;
  final double durationProgress;
  final double activitiesProgress;
  final bool isPerfectDay;

  _GoalRingsPainter({
    required this.epProgress,
    required this.durationProgress,
    required this.activitiesProgress,
    required this.isPerfectDay,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = 8.0;
    final gap = 4.0;

    // Ring radii (outer → inner)
    final outerRadius = size.width / 2 - strokeWidth / 2;
    final middleRadius = outerRadius - strokeWidth - gap;
    final innerRadius = middleRadius - strokeWidth - gap;

    // Background ring paint
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = Colors.grey.withValues(alpha: 0.15);

    // Draw background rings
    canvas.drawCircle(center, outerRadius, bgPaint);
    canvas.drawCircle(center, middleRadius, bgPaint);
    canvas.drawCircle(center, innerRadius, bgPaint);

    // Progress ring paint helper
    Paint progressPaint(Color color) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    // Start from top (-π/2)
    const startAngle = -pi / 2;

    // Draw EP ring (outer, orange)
    _drawArc(
      canvas,
      center,
      outerRadius,
      startAngle,
      epProgress,
      progressPaint(const Color(0xFFFF6A00)),
    );

    // Draw Duration ring (middle, green)
    _drawArc(
      canvas,
      center,
      middleRadius,
      startAngle,
      durationProgress,
      progressPaint(const Color(0xFF4CAF50)),
    );

    // Draw Activities ring (inner, blue)
    _drawArc(
      canvas,
      center,
      innerRadius,
      startAngle,
      activitiesProgress,
      progressPaint(const Color(0xFF2196F3)),
    );

    // Perfect Day checkmark in center
    if (isPerfectDay) {
      final iconPaint = Paint()
        ..color = const Color(0xFFFF6A00)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 12, iconPaint);

      final checkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      final path = Path()
        ..moveTo(center.dx - 4, center.dy)
        ..lineTo(center.dx - 1, center.dy + 3)
        ..lineTo(center.dx + 5, center.dy - 3);
      canvas.drawPath(path, checkPaint);
    }
  }

  void _drawArc(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double progress,
    Paint paint,
  ) {
    if (progress <= 0) return;
    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_GoalRingsPainter oldDelegate) =>
      epProgress != oldDelegate.epProgress ||
      durationProgress != oldDelegate.durationProgress ||
      activitiesProgress != oldDelegate.activitiesProgress ||
      isPerfectDay != oldDelegate.isPerfectDay;
}
