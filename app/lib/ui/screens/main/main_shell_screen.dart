// Updated navigation to show Rewards instead of Rank
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';

class MainShellScreen extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({super.key, required this.navigationShell});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: _buildBottomNavBar(context, isDark),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                index: 0,
                icon: Icons.home,
                filledIcon: Icons.home,
                label: 'Home',
                isDark: isDark,
              ),
              _buildNavItem(
                context,
                index: 1,
                icon: Icons.leaderboard_outlined,
                filledIcon: Icons.leaderboard,
                label: 'Leaderboard',
                isDark: isDark,
              ),
              _buildNavItem(
                context,
                index: 2,
                icon: Icons.task_alt_outlined,
                filledIcon: Icons.task_alt,
                label: 'Tasks',
                isDark: isDark,
              ),
              _buildNavItem(
                context,
                index: 3,
                icon: Icons.person_outline,
                filledIcon: Icons.person,
                label: 'Profile',
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData filledIcon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = widget.navigationShell.currentIndex == index;
    final selectedColor = AppColors.primary;
    final unselectedColor = isDark
        ? AppColors.textSubDark
        : AppColors.textSubLight;

    return GestureDetector(
      onTap: () => widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      ),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? filledIcon : icon,
              color: isSelected ? selectedColor : unselectedColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
