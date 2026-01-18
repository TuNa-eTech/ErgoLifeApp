import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';
import 'package:ergo_life_app/blocs/auth/auth_bloc.dart';
import 'package:ergo_life_app/blocs/auth/auth_event.dart';
import 'package:ergo_life_app/blocs/onboarding/onboarding_bloc.dart';
import 'package:ergo_life_app/blocs/onboarding/onboarding_event.dart';
import 'package:ergo_life_app/blocs/onboarding/onboarding_state.dart';

/// Build individual avatar item helper
/// Extract this to avoid multi-line string issues
Widget buildAvatarItem({
  required int avatarId,
  required bool isSelected,
  required bool isDark,
  required VoidCallback onTap,
  required String Function(int) getAvatarUrl,
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
