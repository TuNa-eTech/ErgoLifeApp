import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Loading skeleton for TasksScreen with shimmer effect
class TasksLoadingSkeleton extends StatelessWidget {
  const TasksLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSkeleton(),
          _buildStatsSkeleton(),
          _buildHighPriorityCardSkeleton(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitleSkeleton(),
                const SizedBox(height: 16),
                ...List.generate(3, (index) => _buildTaskCardSkeleton()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSkeleton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSkeleton(180, 28, borderRadius: 8),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSkeleton(80, 36, borderRadius: 20),
              const SizedBox(width: 8),
              _buildSkeleton(100, 36, borderRadius: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSkeleton(double.infinity, 80, borderRadius: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSkeleton(double.infinity, 80, borderRadius: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSkeleton(double.infinity, 80, borderRadius: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHighPriorityCardSkeleton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: _buildSkeleton(double.infinity, 150, borderRadius: 24),
    );
  }

  Widget _buildSectionTitleSkeleton() {
    return _buildSkeleton(150, 20, borderRadius: 8);
  }

  Widget _buildTaskCardSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: _buildSkeleton(double.infinity, 80, borderRadius: 16),
    );
  }

  Widget _buildSkeleton(
    double width,
    double height, {
    double borderRadius = 12,
    bool isCircle = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}
