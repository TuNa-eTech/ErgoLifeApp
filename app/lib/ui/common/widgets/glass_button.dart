import 'dart:ui';
import 'package:flutter/material.dart';

/// A glassmorphic button with blur effect
/// Used in ActiveSessionScreen and can be reused elsewhere
class GlassButton extends StatelessWidget {
  const GlassButton({
    required this.icon,
    this.onTap,
    this.size = 44.0,
    this.iconSize = 24.0,
    this.iconColor = const Color(0xFF0F172A),
    this.backgroundColor,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color iconColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(size / 2),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: iconColor, size: iconSize),
          ),
        ),
      ),
    );
  }
}
