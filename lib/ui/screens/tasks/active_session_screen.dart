import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/ui/common/widgets/glass_button.dart';
import 'package:ergo_life_app/ui/screens/tasks/widgets/swipe_to_end_button.dart';
import 'package:ergo_life_app/ui/screens/tasks/widgets/session_stat_item.dart';

/// Screen showing active exercise session with timer and stats
class ActiveSessionScreen extends StatelessWidget {
  const ActiveSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      body: Column(
        children: [
          // Top Image Section (approx 55% height)
          Expanded(flex: 55, child: _buildTopSection(context, isDark)),

          // Bottom Content Section (approx 45% height)
          Expanded(flex: 45, child: _buildBottomSection(context, isDark)),
        ],
      ),
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
      child: Image.network(
        "https://lh3.googleusercontent.com/aida-public/AB6AXuDtXYc8ewuI4ZXCfxKjjphm98tp0-SyNTx3m5Y4pQ4_Z6gLZ4-x4pD9PXVCnRCJrQR7zw7TViMiAdlsAd2-QMNzTHBkocadgWanXb1DWSXxaUZuxX-N1sb4ocdh-wVKYVsOxdbBB_nTJ62ok1F_uxPjls-_3xABisYHc2ywuK3JTtN83p8vn7GtiEb08RdJeUy2WOLB_gnGdJXVBqo6rwHLbRQ9jDjsTenwodPLNuENnat_MTAsPIE-Enp7QcUO8XuXwrhrZH1Lfz0",
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
                onTap: () => Navigator.pop(context),
              ),
              _buildTitleWithIndicator(),
              const GlassButton(icon: Icons.more_horiz),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWithIndicator() {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
        ),
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

  Widget _buildBottomSection(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTimerSection(isDark),
          _buildStatsRow(isDark),
          _buildTaskInfo(isDark),
          SwipeToEndButton(
            isDark: isDark,
            onComplete: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection(bool isDark) {
    return Column(
      children: [
        Text(
          '12:45',
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w900,
            height: 1.0,
            letterSpacing: -2,
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
              'TARGET 20:00',
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
      ],
    );
  }

  Widget _buildStatsRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SessionStatItem(
          icon: Icons.local_fire_department,
          value: '184',
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
          value: '320',
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
          'Legs & Glutes: Vacuuming',
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
          'MODERATE • ROOM 1',
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
}
