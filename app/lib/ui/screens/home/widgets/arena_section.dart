import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/ui/common/widgets/striped_pattern_painter.dart';

/// Arena section showing daily competition between user and rival
class ArenaSection extends StatelessWidget {
  const ArenaSection({
    required this.isDark,
    this.userPoints = 0,
    this.rivalPoints = 0,
    this.totalPoints = 1600,
    this.onLeaderboardTap,
    super.key,
  });

  final bool isDark;
  final int userPoints;
  final int rivalPoints;
  final int totalPoints;
  final VoidCallback? onLeaderboardTap;

  @override
  Widget build(BuildContext context) {
    final difference = userPoints - rivalPoints;
    final isLeading = difference > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background decorations
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            _buildContent(difference, isLeading),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(int difference, bool isLeading) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _ProgressBar(
            isDark: isDark,
            label: 'You',
            current: userPoints,
            total: totalPoints,
            color: AppColors.primary,
            isUser: true,
          ),
          const SizedBox(height: 20),
          _ProgressBar(
            isDark: isDark,
            label: 'Rival',
            current: rivalPoints,
            total: totalPoints,
            color: AppColors.secondary,
            isUser: false,
          ),
          const SizedBox(height: 20),
          _buildStatusMessage(difference, isLeading),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DAILY COMPETITION',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'The Arena',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onLeaderboardTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Leaderboard >',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMessage(int difference, bool isLeading) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isLeading ? Icons.trending_up : Icons.trending_down,
            color: isLeading ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSubDark
                      : AppColors.textSubLight,
                ),
                children: [
                  TextSpan(
                    text: isLeading
                        ? 'You are leading by '
                        : 'You are behind by ',
                  ),
                  TextSpan(
                    text: '${difference.abs()} EP!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textMainDark
                          : AppColors.textMainLight,
                    ),
                  ),
                  TextSpan(text: isLeading ? ' Keep pushing!' : ' Catch up!'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Progress bar widget for arena section
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.isDark,
    required this.label,
    required this.current,
    required this.total,
    required this.color,
    required this.isUser,
  });

  final bool isDark;
  final String label;
  final int current;
  final int total;
  final Color color;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final progress = current / total;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
              ],
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$current ',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  TextSpan(
                    text: '/ $total EP',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSubDark
                          : AppColors.textSubLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 18,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C3038) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: isUser ? _buildUserProgressPattern() : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserProgressPattern() {
    return Stack(
      children: [
        // Striped Pattern
        Positioned.fill(
          child: CustomPaint(
            painter: StripedPatternPainter(
              color: Colors.black.withOpacity(0.1),
              stripeWidth: 10,
              gapWidth: 10,
            ),
          ),
        ),
        // White indicator at the end
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 4,
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}
