import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';

/// Avatar URL generator - same logic as AvatarSelector
String getAvatarUrl(int avatarId) {
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

/// Build avatar item widget
Widget buildAvatarItem({
  required int avatarId,
  required bool isSelected,
  required bool isDark,
  required VoidCallback onTap,
}) {
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
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: getAvatarUrl(avatarId),
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                child: Icon(
                  Icons.person,
                  size: 24,
                  color: isDark ? Colors.white54 : Colors.grey.shade400,
                ),
              ),
            ),
            if (isSelected)
              Container(
                color: AppColors.secondary.withValues(alpha: 0.3),
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
