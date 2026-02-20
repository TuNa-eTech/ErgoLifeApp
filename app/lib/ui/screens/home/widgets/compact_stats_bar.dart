import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/data/models/stats_model.dart';
import 'package:ergo_life_app/ui/screens/stats/task_stats_screen.dart';
import 'package:ergo_life_app/l10n/app_localizations.dart';

/// Compact stats bar showing Streak, Points, and Time in a row.
///
/// Streak pill includes freeze badge and expands to show
/// longest streak on tap.
class CompactStatsBar extends StatefulWidget {
  const CompactStatsBar({
    required this.isDark,
    required this.stats,
    required this.currentStreak,
    this.longestStreak = 0,
    this.streakFreezeCount = 0,
    super.key,
  });

  final bool isDark;
  final WeeklyStats stats;
  final int currentStreak;
  final int longestStreak;
  final int streakFreezeCount;

  @override
  State<CompactStatsBar> createState() => _CompactStatsBarState();
}

class _CompactStatsBarState extends State<CompactStatsBar>
    with SingleTickerProviderStateMixin {
  bool _isStreakExpanded = false;
  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleStreakExpanded() {
    setState(() {
      _isStreakExpanded = !_isStreakExpanded;
      if (_isStreakExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.03 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TaskStatsScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Section Title
                  Text(
                    AppLocalizations.of(context)!.yourProgress,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Pills Row
                  Row(
                    children: [
                      // Streak Pill (tappable, expandable)
                      Expanded(
                        child: _StreakPill(
                          isDark: widget.isDark,
                          currentStreak: widget.currentStreak,
                          streakFreezeCount: widget.streakFreezeCount,
                          isExpanded: _isStreakExpanded,
                          onTap: _toggleStreakExpanded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Points Pill
                      Expanded(
                        child: _buildPill(
                          icon: Icons.stars_rounded,
                          iconColor: AppColors.primary,
                          label: AppLocalizations.of(
                            context,
                          )!.pointsCount(widget.stats.formattedPoints),
                          bgColor: AppColors.primary.withAlpha(
                            (0.1 * 255).round(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Time Pill
                      Expanded(
                        child: _buildPill(
                          icon: Icons.timer_rounded,
                          iconColor: AppColors.secondary,
                          label: _formatDuration(
                            context,
                            widget.stats.totalDurationMinutes,
                          ),
                          bgColor: AppColors.secondary.withAlpha(
                            (0.1 * 255).round(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Expandable streak detail
                  SizeTransition(
                    sizeFactor: _expandAnimation,
                    axisAlignment: -1,
                    child: _StreakDetailRow(
                      isDark: widget.isDark,
                      longestStreak: widget.longestStreak,
                      streakFreezeCount: widget.streakFreezeCount,
                    ),
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
        color: widget.isDark
            ? Colors.white.withAlpha((0.05 * 255).round())
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDark ? Colors.transparent : Colors.grey.shade100,
          width: 1,
        ),
        boxShadow: [
          if (!widget.isDark)
            BoxShadow(
              color: Colors.black.withAlpha((0.02 * 255).round()),
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
                color: widget.isDark ? AppColors.textMainDark : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(BuildContext context, int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      return AppLocalizations.of(context)!.hoursCount(hours);
    }
    return AppLocalizations.of(context)!.minutesCount(minutes);
  }
}

/// Streak pill with optional freeze badge overlay.
class _StreakPill extends StatelessWidget {
  const _StreakPill({
    required this.isDark,
    required this.currentStreak,
    required this.streakFreezeCount,
    required this.isExpanded,
    required this.onTap,
  });

  final bool isDark;
  final int currentStreak;
  final int streakFreezeCount;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withAlpha((0.05 * 255).round())
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isExpanded
                ? Colors.orange.withAlpha((0.4 * 255).round())
                : (isDark ? Colors.transparent : Colors.grey.shade100),
            width: 1,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withAlpha((0.02 * 255).round()),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              size: 14,
              color: Colors.orange,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                AppLocalizations.of(context)!.dayCount(currentStreak),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textMainDark : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Freeze badge
            if (streakFreezeCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha((0.15 * 255).round()),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🛡️', style: TextStyle(fontSize: 8)),
                    Text(
                      '$streakFreezeCount',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.blue.shade200
                            : Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Expandable row showing longest streak and freeze count.
class _StreakDetailRow extends StatelessWidget {
  const _StreakDetailRow({
    required this.isDark,
    required this.longestStreak,
    required this.streakFreezeCount,
  });

  final bool isDark;
  final int longestStreak;
  final int streakFreezeCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.withAlpha((0.08 * 255).round()),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.emoji_events_rounded,
              size: 14,
              color: Colors.orange.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              'Best: $longestStreak days',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.orange.shade200 : Colors.orange.shade800,
              ),
            ),
            const Spacer(),
            if (streakFreezeCount > 0) ...[
              Text('🛡️', style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                '$streakFreezeCount freeze'
                '${streakFreezeCount > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
