import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/health/health_bloc.dart';
import 'package:ergo_life_app/blocs/health/health_event.dart';
import 'package:ergo_life_app/blocs/health/health_state.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/data/models/health_data_model.dart';

/// Card displaying today's health summary on the
/// home screen: Steps, Calories, Heart Rate.
///
/// Shows a "Connect" CTA when the
/// [HealthBloc] state is [HealthDisconnected] with
/// [shouldShowPrompt] true.
class HealthSummaryCard extends StatelessWidget {
  const HealthSummaryCard({
    required this.isDark,
    this.healthSummary,
    super.key,
  });

  final bool isDark;
  final DailyHealthSummary? healthSummary;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HealthBloc, HealthState>(
      builder: (context, healthState) {
        // Show connect CTA when disconnected + prompt OK
        if (healthState is HealthDisconnected && healthState.shouldShowPrompt) {
          return _buildConnectCta(context);
        }

        // Hide when no health data available
        if (healthSummary == null || !healthSummary!.hasData) {
          return const SizedBox.shrink();
        }

        return _buildCard(context);
      },
    );
  }

  Widget _buildCard(BuildContext context) {
    final summary = healthSummary!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Decorative circle (top-right)
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        size: 14,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "TODAY'S HEALTH",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Pills row
                  Row(
                    children: [
                      if (summary.steps != null)
                        Expanded(
                          child: _buildPill(
                            icon: Icons.directions_walk_rounded,
                            iconColor: Colors.green,
                            label: _formatSteps(summary.steps!),
                            bgColor: Colors.green.withValues(alpha: 0.1),
                          ),
                        ),
                      if (summary.steps != null &&
                          summary.activeCalories != null)
                        const SizedBox(width: 8),
                      if (summary.activeCalories != null)
                        Expanded(
                          child: _buildPill(
                            icon: Icons.local_fire_department_rounded,
                            iconColor: AppColors.secondary,
                            label: '${summary.activeCalories!.round()} kcal',
                            bgColor: AppColors.secondary.withValues(alpha: 0.1),
                          ),
                        ),
                      if (summary.activeCalories != null &&
                          summary.avgRestingHeartRate != null)
                        const SizedBox(width: 8),
                      if (summary.avgRestingHeartRate != null)
                        Expanded(
                          child: _buildPill(
                            icon: Icons.favorite_rounded,
                            iconColor: Colors.redAccent,
                            label:
                                '${summary.avgRestingHeartRate!.round()} bpm',
                            bgColor: Colors.redAccent.withValues(alpha: 0.1),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectCta(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.read<HealthBloc>().add(const ConnectHealth());
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.favorite_rounded,
                      size: 20,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Platform.isIOS
                              ? 'Connect Apple Health'
                              : 'Connect Health Connect',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textMainDark
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Track heart rate, steps & calories',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSubDark
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: isDark ? AppColors.textSubDark : Colors.black38,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color bgColor,
  }) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.transparent : Colors.grey.shade100,
          width: 1,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textMainDark : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Format step count with K suffix for readability.
  String _formatSteps(int steps) {
    if (steps >= 10000) {
      final k = steps / 1000;
      return '${k.toStringAsFixed(1)}K';
    }
    if (steps >= 1000) {
      return '${(steps / 1000).toStringAsFixed(1)}K';
    }
    return '$steps';
  }
}
