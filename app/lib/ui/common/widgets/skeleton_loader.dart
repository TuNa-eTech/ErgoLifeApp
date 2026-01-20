import 'package:flutter/material.dart';

/// A shimmer skeleton loader widget for displaying loading states.
///
/// This widget creates a pulsing animation effect to indicate loading
/// content. It can be customized with different shapes, sizes, and colors.
class SkeletonLoader extends StatefulWidget {
  /// Creates a skeleton loader.
  const SkeletonLoader({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.baseColor,
    this.highlightColor,
  });

  /// Width of the skeleton. If null, takes available width.
  final double? width;

  /// Height of the skeleton.
  final double height;

  /// Border radius for rectangle shapes.
  final BorderRadius? borderRadius;

  /// Shape of the skeleton (rectangle or circle).
  final BoxShape shape;

  /// Base color of the skeleton.
  final Color? baseColor;

  /// Highlight color for the shimmer effect.
  final Color? highlightColor;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        widget.baseColor ??
        (isDark ? Colors.grey.shade800 : Colors.grey.shade300);
    final highlightColor =
        widget.highlightColor ??
        (isDark ? Colors.grey.shade700 : Colors.grey.shade100);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.rectangle
                ? (widget.borderRadius ?? BorderRadius.circular(4))
                : null,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton loader for profile header.
class ProfileHeaderSkeleton extends StatelessWidget {
  /// Creates a profile header skeleton.
  const ProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 15,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SkeletonLoader(width: 50, height: 50, shape: BoxShape.circle),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: 120,
                  height: 18,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for stats card.
class StatsCardSkeleton extends StatelessWidget {
  /// Creates a stats card skeleton.
  const StatsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      child: Row(
        children: [
          Expanded(child: _buildStatItemSkeleton()),
          _buildVerticalDivider(isDark),
          Expanded(child: _buildStatItemSkeleton()),
          _buildVerticalDivider(isDark),
          Expanded(child: _buildStatItemSkeleton()),
          _buildVerticalDivider(isDark),
          Expanded(child: _buildStatItemSkeleton()),
        ],
      ),
    );
  }

  Widget _buildStatItemSkeleton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SkeletonLoader(width: 24, height: 24, shape: BoxShape.circle),
        const SizedBox(height: 4),
        SkeletonLoader(
          width: 30,
          height: 18,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        SkeletonLoader(
          width: 50,
          height: 11,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      height: 32,
      width: 1,
      color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.grey.withValues(alpha: 0.2),
    );
  }
}

/// Skeleton loader for leaderboard podium (top 3 positions).
class LeaderboardPodiumSkeleton extends StatelessWidget {
  /// Creates a leaderboard podium skeleton.
  const LeaderboardPodiumSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _PodiumItemSkeleton(height: 120, avatarSize: 56),
          ),
          // 1st Place (Center and Highest)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _PodiumItemSkeleton(height: 150, avatarSize: 72),
          ),
          // 3rd Place
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _PodiumItemSkeleton(height: 100, avatarSize: 48),
          ),
        ],
      ),
    );
  }
}

class _PodiumItemSkeleton extends StatelessWidget {
  final double height;
  final double avatarSize;

  const _PodiumItemSkeleton({required this.height, required this.avatarSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: SkeletonLoader(
            width: avatarSize,
            height: avatarSize,
            shape: BoxShape.circle,
          ),
        ),

        // Name
        SkeletonLoader(
          width: 60,
          height: 14,
          borderRadius: BorderRadius.circular(4),
        ),

        const SizedBox(height: 4),

        // Points
        SkeletonLoader(
          width: 40,
          height: 10,
          borderRadius: BorderRadius.circular(4),
        ),

        const SizedBox(height: 8),

        // Podium Step
        SkeletonLoader(
          width: avatarSize == 72 ? 96 : 80,
          height: height,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ],
    );
  }
}

/// Skeleton loader for leaderboard ranking item.
class LeaderboardRankingItemSkeleton extends StatelessWidget {
  /// Creates a leaderboard ranking item skeleton.
  const LeaderboardRankingItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Rank
            SkeletonLoader(
              width: 24,
              height: 18,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(width: 16),

            // Avatar
            const SkeletonLoader(width: 40, height: 40, shape: BoxShape.circle),
            const SizedBox(width: 16),

            // Name and info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(
                    width: 120,
                    height: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  SkeletonLoader(
                    width: 60,
                    height: 10,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),

            // Points
            SkeletonLoader(
              width: 50,
              height: 18,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}

/// Complete skeleton loader for the leaderboard screen.
class LeaderboardScreenSkeleton extends StatelessWidget {
  /// Creates a complete leaderboard screen skeleton.
  const LeaderboardScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Podium
        const SliverToBoxAdapter(child: LeaderboardPodiumSkeleton()),

        // Rankings Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SkeletonLoader(
              width: 100,
              height: 18,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),

        // Ranking List
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => const LeaderboardRankingItemSkeleton(),
            childCount: 6, // Show 6 skeleton items
          ),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}
