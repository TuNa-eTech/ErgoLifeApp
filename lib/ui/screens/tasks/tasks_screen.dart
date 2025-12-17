import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';


class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isDark),
                _buildHighPriorityTask(context, isDark),
                _buildTaskList(context, isDark),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: _buildFloatingAddButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      color: (isDark ? AppColors.backgroundDark : AppColors.backgroundLight)
          .withOpacity(0.95),
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Missions',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.filter_list,
                      size: 20,
                      color: isDark
                          ? AppColors.textMainDark
                          : AppColors.textMainLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage(
                          "https://lh3.googleusercontent.com/aida-public/AB6AXuC8cNp4p9S10dVV67Ocu6pA2hPZErbqWTgHgdAUGn0CA4y4BT7VJJpsRUWf67jTFvA6Oxt3wcI0Dk6AD2SquLO8RMX5oJOPRSmj7xpeXcuCQAzoL-YGBBaFOIcSRiPdU67QgnwyPF20TDuOxyBvcG8gZzNLc_U0qhllkVaoRE40AULggtrgvwOJU9nH4_SuoGnzj3zWc5zVws0VRdT7gTN5XTHQOMWF9N2Md2IMyZC6PvdjaamVIdDc_34LYL78G9ZvglhtRkrH4bU",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                _buildTab(
                  context,
                  'Active Tasks (4)',
                  isActive: true,
                  isDark: isDark,
                ),
                const SizedBox(width: 12),
                _buildTab(
                  context,
                  'Completed',
                  isActive: false,
                  isDark: isDark,
                ),
                const SizedBox(width: 12),
                _buildTab(
                  context,
                  'Saved Routines',
                  isActive: false,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    String label, {
    required bool isActive,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive
            ? (isDark ? Colors.white : AppColors.textMainLight)
            : (isDark ? AppColors.surfaceDark : Colors.white),
        borderRadius: BorderRadius.circular(30),
        border: isActive
            ? null
            : Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: (isDark ? Colors.white : AppColors.textMainLight)
                      .withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive
              ? (isDark ? AppColors.textMainLight : Colors.white)
              : (isDark ? AppColors.textSubDark : AppColors.textSubLight),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildHighPriorityTask(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      // Removed fixed height to avoid overflow
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorations
          Positioned(
            right: -16,
            top: -16,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.white.withOpacity(0.1)),
              ),
            ),
          ),
          Positioned(
            left: -16,
            bottom: -16,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Allow column to shrink wrap
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.bolt, size: 14, color: AppColors.secondary),
                        SizedBox(width: 4),
                        Text(
                          'High Priority',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Full Body Blitz',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                'Deep Clean Living Room & Kitchen',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24), // Replaced Spacer with fixed spacing

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.timer, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '45m',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Row(
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 18),
                          SizedBox(width: 4),
                          Text(
                            '350 EP',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      color: AppColors.secondary,
                      onPressed: () {
                        context.push(AppRouter.activeSession);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          _buildTaskItem(
            context,
            isDark,
            title: 'Legs & Glutes',
            subtitle: 'Vacuuming Bedroom & Hallway',
            time: '20 min',
            score: '150 EP',
            tag: 'ZONE 2',
            icon: Icons.cleaning_services, // Approximation for vacuum
            iconColor: Colors.purple,
            iconBgColor: Colors.purple.withOpacity(0.1),
            tagColor: Colors.purple,
            tagBgColor: Colors.purple.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          _buildTaskItem(
            context,
            isDark,
            title: 'Upper Body Press',
            subtitle: 'Laundry Loading & Hanging',
            time: '15 min',
            score: '80 EP',
            icon: Icons.local_laundry_service,
            iconColor: Colors.blue,
            iconBgColor: Colors.blue.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          _buildTaskItem(
            context,
            isDark,
            title: 'Cardio Dash',
            subtitle: 'Grocery Run (Heavy Load)',
            time: '45 min',
            score: '200 EP',
            icon: Icons.shopping_bag,
            iconColor: Colors.green,
            iconBgColor: Colors.green.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          _buildTaskItem(
            context,
            isDark,
            title: 'Core Stability',
            subtitle: 'Dishwashing',
            time: '10 min',
            score: '+50 EP',
            scoreColor: Colors.grey,
            icon: Icons.water_drop,
            iconColor: Colors.grey,
            iconBgColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            isCompleted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(
    BuildContext context,
    bool isDark, {
    required String title,
    required String subtitle,
    required String time,
    required String score,
    String? tag,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    Color? tagColor,
    Color? tagBgColor,
    Color? scoreColor,
    bool isCompleted = false,
  }) {
    return Opacity(
      opacity: isCompleted ? 0.6 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ), // End BoxDecoration
        child: InkWell(
          onTap: () {
            if (!isCompleted) {
              context.push(AppRouter.activeSession);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark
                                    ? AppColors.textMainDark
                                    : AppColors.textMainLight,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (tag != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: tagBgColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  color: tagColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          if (isCompleted) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.check, size: 10, color: Colors.green),
                                  SizedBox(width: 2),
                                  Text(
                                    'DONE',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSubDark
                              : AppColors.textSubLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 14,
                                color: isDark
                                    ? AppColors.textSubDark
                                    : AppColors.textSubLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                time,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.textSubDark
                                      : AppColors.textSubLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Row(
                            children: [
                              if (!isCompleted)
                                const Icon(
                                  Icons.local_fire_department,
                                  size: 14,
                                  color: AppColors.secondary,
                                ),
                              const SizedBox(width: 4),
                              Text(
                                score,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: scoreColor ?? AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isCompleted)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 24),
                  )
                else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, color: Colors.grey.shade400, size: 24),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingAddButton(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.add, size: 32, color: Colors.white),
        onPressed: () {
          context.push(AppRouter.createTask);
        },
      ),
    );
  }
}
