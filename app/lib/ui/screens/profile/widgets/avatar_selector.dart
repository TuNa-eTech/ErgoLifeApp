import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';

/// Avatar Selector Bottom Sheet
/// Displays a grid of available avatars for user selection
class AvatarSelector extends StatelessWidget {
  final int? currentAvatarId;
  final Function(int) onAvatarSelected;

  const AvatarSelector({
    super.key,
    this.currentAvatarId,
    required this.onAvatarSelected,
  });

  /// Total number of avatars available (6 styles x 10 variations = 60)
  static const int totalAvatars = 60;

  /// Get avatar URL from avatar ID with multiple DiceBear styles
  /// - avatarId 1-10: lorelei (cute illustrated girls)
  /// - avatarId 11-20: fun-emoji (colorful emoji style)
  /// - avatarId 21-30: adventurer (playful characters)
  /// - avatarId 31-40: notionists (notion-style avatars)
  /// - avatarId 41-50: big-smile (happy faces)
  /// - avatarId 51-60: avataaars (classic cartoon style)
  static String getAvatarUrl(int avatarId) {
    // Determine style based on avatarId range
    String style;
    int seed;

    if (avatarId <= 10) {
      style = 'lorelei';
      seed = avatarId;
    } else if (avatarId <= 20) {
      style = 'fun-emoji';
      seed = avatarId - 10;
    } else if (avatarId <= 30) {
      style = 'adventurer';
      seed = avatarId - 20;
    } else if (avatarId <= 40) {
      style = 'notionists';
      seed = avatarId - 30;
    } else if (avatarId <= 50) {
      style = 'big-smile';
      seed = avatarId - 40;
    } else {
      style = 'avataaars';
      seed = avatarId - 50;
    }

    return 'https://api.dicebear.com/7.x/$style/png?seed=avatar$seed';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.7,
          minHeight: 400,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Choose Avatar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textMainDark
                            : AppColors.textMainLight,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: isDark
                        ? AppColors.textSubDark
                        : AppColors.textSubLight,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Avatar Grid with Style Sections
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildStyleSection(
                    context,
                    'Lorelei - Cute Girls',
                    1,
                    10,
                    isDark,
                    Colors.pink.shade300,
                  ),
                  const SizedBox(height: 20),
                  _buildStyleSection(
                    context,
                    'Fun Emoji - Colorful',
                    11,
                    20,
                    isDark,
                    Colors.orange.shade300,
                  ),
                  const SizedBox(height: 20),
                  _buildStyleSection(
                    context,
                    'Adventurer - Playful',
                    21,
                    30,
                    isDark,
                    Colors.purple.shade300,
                  ),
                  const SizedBox(height: 20),
                  _buildStyleSection(
                    context,
                    'Notionists - Clean',
                    31,
                    40,
                    isDark,
                    Colors.blue.shade300,
                  ),
                  const SizedBox(height: 20),
                  _buildStyleSection(
                    context,
                    'Big Smile - Happy',
                    41,
                    50,
                    isDark,
                    Colors.green.shade300,
                  ),
                  const SizedBox(height: 20),
                  _buildStyleSection(
                    context,
                    'Avataaars - Classic',
                    51,
                    60,
                    isDark,
                    Colors.indigo.shade300,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleSection(
    BuildContext context,
    String title,
    int startId,
    int endId,
    bool isDark,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Style header
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Avatar grid for this style
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: endId - startId + 1,
          itemBuilder: (context, index) {
            final avatarId = startId + index;
            final isSelected = avatarId == currentAvatarId;

            return _AvatarItem(
              avatarId: avatarId,
              isSelected: isSelected,
              isDark: isDark,
              onTap: () => onAvatarSelected(avatarId),
            );
          },
        ),
      ],
    );
  }
}

/// Individual Avatar Item
class _AvatarItem extends StatelessWidget {
  final int avatarId;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _AvatarItem({
    required this.avatarId,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? AppColors.secondary
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: ClipOval(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                AvatarSelector.getAvatarUrl(avatarId),
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: isDark ? Colors.white54 : Colors.grey.shade400,
                    ),
                  );
                },
              ),
              if (isSelected)
                Container(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
