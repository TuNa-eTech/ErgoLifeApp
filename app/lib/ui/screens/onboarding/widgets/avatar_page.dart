import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/ui/screens/onboarding/widgets/avatar_helpers.dart';

/// Page 1 of onboarding: Avatar selection and name input
class AvatarPage extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final int selectedAvatarId;
  final int totalAvatars;
  final TextEditingController nameController;
  final FocusNode nameFocusNode;
  final bool isNameValid;
  final Function(int avatarId) onAvatarSelected;

  const AvatarPage({
    super.key,
    required this.isDark,
    required this.textColor,
    required this.selectedAvatarId,
    required this.totalAvatars,
    required this.nameController,
    required this.nameFocusNode,
    required this.isNameValid,
    required this.onAvatarSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  'Choose your avatar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pick one for the leaderboard (optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : const Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Avatar Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 360,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C1F18) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: totalAvatars,
                  itemBuilder: (context, index) {
                    final avatarId = index + 1;
                    final isSelected = avatarId == selectedAvatarId;
                    return buildAvatarItem(
                      avatarId: avatarId,
                      isSelected: isSelected,
                      isDark: isDark,
                      onTap: () => onAvatarSelected(avatarId),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  'What should we call you?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  focusNode: nameFocusNode,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.badge_outlined,
                      color: nameFocusNode.hasFocus
                          ? AppColors.secondary
                          : Theme.of(
                              context,
                            ).iconTheme.color?.withValues(alpha: 0.5),
                    ),
                    suffixIcon: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isNameValid ? 1.0 : 0.0,
                      child: const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                      ),
                    ),
                    hintText: 'Enter your name...',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
