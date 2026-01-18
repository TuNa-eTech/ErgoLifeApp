import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/ui/screens/onboarding/widgets/circle_button.dart';

/// Header widget for onboarding screens with navigation and progress indicators
class OnboardingHeader extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool isDark;
  final VoidCallback? onBackPressed;

  const OnboardingHeader({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.isDark,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          if (currentPage > 0 && onBackPressed != null)
            CircleButton(
              isDark: isDark,
              icon: Icons.arrow_back_ios_new,
              onTap: onBackPressed!,
            )
          else
            const SizedBox(width: 40),

          // Indicators
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(totalPages, (index) {
              final isActive = index == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: isActive ? 24 : 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.secondary
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.grey[300]),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),

          // Step Counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Step ${currentPage + 1}/$totalPages',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
