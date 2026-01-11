import 'package:ergo_life_app/data/models/leaderboard_model.dart';
import 'package:flutter/material.dart';

class LeaderboardPodium extends StatelessWidget {
  final List<LeaderboardEntry> podium;

  const LeaderboardPodium({super.key, required this.podium});

  @override
  Widget build(BuildContext context) {
    if (podium.isEmpty) {
      return const SizedBox.shrink();
    }

    // Flexible container that fits contents
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          if (podium.length > 1)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _PodiumItem(
                entry: podium[1],
                position: 2,
                height: 120,
              ),
            ),
          // 1st Place (Center and Highest)
          if (podium.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _PodiumItem(
                entry: podium[0],
                position: 1,
                height: 150,
              ),
            ),
          // 3rd Place
          if (podium.length > 2)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _PodiumItem(
                entry: podium[2],
                position: 3,
                height: 100,
              ),
            ),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final int position;
  final double height;

  const _PodiumItem({
    required this.entry,
    required this.position,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Use tonal colors for ranking steps
    Color stepColor;
    Color textColor;
    double avatarSize;
    FontWeight fontWeight;

    switch (position) {
      case 1:
        stepColor = colorScheme.primaryContainer;
        textColor = colorScheme.onPrimaryContainer;
        avatarSize = 72;
        fontWeight = FontWeight.w800;
        break;
      case 2:
        stepColor = colorScheme.secondaryContainer;
        textColor = colorScheme.onSecondaryContainer;
        avatarSize = 56;
        fontWeight = FontWeight.w600;
        break;
      case 3:
      default:
        stepColor = colorScheme.tertiaryContainer;
        textColor = colorScheme.onTertiaryContainer;
        avatarSize = 48;
        fontWeight = FontWeight.w500;
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: stepColor,
          ),
          clipBehavior: Clip.antiAlias,
          child: entry.user.avatarUrl != null
              ? Image.network(entry.user.avatarUrl!, fit: BoxFit.cover)
              : Center(
                  child: Text(
                    (entry.user.name ?? 'U').substring(0, 1).toUpperCase(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
        
        // Name
        SizedBox(
          width: 80, // Constrain width for long names
          child: Text(
            (entry.user.name ?? 'User').split(' ').first,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        // Points
        Text(
          entry.formattedPoints,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.outline,
          ),
        ),

        const SizedBox(height: 8),
        
        // Podium Step
        Container(
          width: position == 1 ? 96 : 80,
          height: height,
          decoration: BoxDecoration(
            color: stepColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            '$position',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: textColor,
              fontWeight: fontWeight,
            ),
          ),
        ),
      ],
    );
  }
}

