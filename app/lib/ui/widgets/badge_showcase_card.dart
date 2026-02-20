import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/achievement/achievement_bloc.dart';
import 'package:ergo_life_app/blocs/achievement/achievement_event.dart';
import 'package:ergo_life_app/blocs/achievement/achievement_state.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/data/models/badge_model.dart';

/// Maps a Material icon name string to its [IconData].
IconData badgeIconData(String name) {
  const iconMap = {
    'emoji_events': Icons.emoji_events,
    'directions_run': Icons.directions_run,
    'fitness_center': Icons.fitness_center,
    'military_tech': Icons.military_tech,
    'workspace_premium': Icons.workspace_premium,
    'local_fire_department': Icons.local_fire_department,
    'whatshot': Icons.whatshot,
    'bolt': Icons.bolt,
    'diamond': Icons.diamond,
    'stars': Icons.stars,
    'auto_awesome': Icons.auto_awesome,
    'done_all': Icons.done_all,
    'verified': Icons.verified,
    'shield': Icons.shield,
    'flash_on': Icons.flash_on,
  };
  return iconMap[name] ?? Icons.emoji_events;
}

/// Parses a hex color string like `#FF5722` to a [Color].
Color parseBadgeColor(String hex) =>
    Color(int.parse(hex.replaceFirst('#', '0xFF')));

/// Horizontal scrollable badge showcase for the Profile screen.
///
/// No horizontal padding — parent provides it.
class BadgeShowcaseCard extends StatelessWidget {
  const BadgeShowcaseCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AchievementBloc, AchievementState>(
      builder: (context, state) {
        if (state is AchievementLoading) {
          return _buildSkeleton(isDark);
        }

        if (state is AchievementError) {
          return _buildError(context, state.message, isDark);
        }

        if (state is AchievementLoaded) {
          return _buildLoaded(context, state, isDark);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoaded(
    BuildContext context,
    AchievementLoaded state,
    bool isDark,
  ) {
    // Sort: earned first, then by sort order (implicit from API)
    final sorted = List<BadgeModel>.from(state.badges)
      ..sort((a, b) {
        if (a.isEarned != b.isEarned) {
          return a.isEarned ? -1 : 1;
        }
        return 0;
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BadgeHeader(
          earnedCount: state.earnedCount,
          totalCount: state.totalCount,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _BadgeItem(
                badge: sorted[index],
                isDark: isDark,
                onTap: () => _showBadgeDetail(context, sorted[index], isDark),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkeleton(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 160,
          height: 20,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) => Container(
              width: 72,
              height: 100,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message, bool isDark) {
    return GestureDetector(
      onTap: () => context.read<AchievementBloc>().add(const LoadAllBadges()),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade300, size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Failed to load badges. Tap to retry.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(BuildContext context, BadgeModel badge, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _BadgeDetailSheet(badge: badge, isDark: isDark),
    );
  }
}

class _BadgeHeader extends StatelessWidget {
  final int earnedCount;
  final int totalCount;
  final bool isDark;

  const _BadgeHeader({
    required this.earnedCount,
    required this.totalCount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '🏅 Badges',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$earnedCount / $totalCount',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final BadgeModel badge;
  final bool isDark;
  final VoidCallback onTap;

  const _BadgeItem({
    required this.badge,
    required this.isDark,
    required this.onTap,
  });

  Color get _badgeColor => parseBadgeColor(badge.color);

  Color get _rarityGlow {
    return switch (badge.rarity) {
      'LEGENDARY' => const Color(0xFFFFD700),
      'EPIC' => const Color(0xFFFF9800),
      'RARE' => const Color(0xFF9C27B0),
      _ => Colors.transparent,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badge.isEarned
                    ? _badgeColor.withValues(alpha: 0.15)
                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                border: Border.all(
                  color: badge.isEarned ? _badgeColor : Colors.transparent,
                  width: 2,
                ),
                boxShadow: badge.isEarned && _rarityGlow != Colors.transparent
                    ? [
                        BoxShadow(
                          color: _rarityGlow.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: badge.isEarned
                  ? Icon(
                      badgeIconData(badge.icon),
                      color: _badgeColor,
                      size: 24,
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          badgeIconData(badge.icon),
                          color: Colors.grey.shade500,
                          size: 24,
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Icon(
                            Icons.lock,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              badge.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: badge.isEarned ? FontWeight.w600 : FontWeight.w400,
                color: badge.isEarned
                    ? (isDark
                          ? AppColors.textMainDark
                          : AppColors.textMainLight)
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeDetailSheet extends StatelessWidget {
  final BadgeModel badge;
  final bool isDark;

  const _BadgeDetailSheet({required this.badge, required this.isDark});

  Color get _badgeColor => parseBadgeColor(badge.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Badge icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badge.isEarned
                  ? _badgeColor.withValues(alpha: 0.15)
                  : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
              border: Border.all(
                color: badge.isEarned
                    ? _badgeColor
                    : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                width: 3,
              ),
            ),
            child: Icon(
              badgeIconData(badge.icon),
              color: badge.isEarned ? _badgeColor : Colors.grey.shade500,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          // Badge name
          Text(
            badge.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 4),
          _RarityLabel(rarity: badge.rarity),
          const SizedBox(height: 8),
          // Description
          if (badge.description != null)
            Text(
              badge.description!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
              ),
            ),
          const SizedBox(height: 16),
          // Progress bar for unearned badges
          if (!badge.isEarned) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: badge.progress,
                minHeight: 8,
                backgroundColor: isDark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(_badgeColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${badge.currentValue} / '
              '${badge.conditionValue}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
              ),
            ),
          ],
          // Unlock date for earned badges
          if (badge.isEarned && badge.unlockedAt != null)
            Text(
              'Unlocked ${_formatDate(badge.unlockedAt!)}',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateString;
    }
  }
}

class _RarityLabel extends StatelessWidget {
  final String rarity;

  const _RarityLabel({required this.rarity});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (rarity) {
      'LEGENDARY' => (const Color(0xFFFFD700), 'Legendary'),
      'EPIC' => (const Color(0xFFFF9800), 'Epic'),
      'RARE' => (const Color(0xFF9C27B0), 'Rare'),
      _ => (const Color(0xFF4CAF50), 'Common'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
