import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';

/// Social sign-in button component.
class SocialButton extends StatefulWidget {
  final bool isDark;
  final Widget icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.isDark,
    required this.icon,
    required this.label,
    this.isPrimary = false,
    required this.onPressed,
  });

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 52,
        decoration: BoxDecoration(
          color: widget.isPrimary
              ? AppColors.primary
              : (widget.isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: widget.isPrimary
              ? null
              : Border.all(
                  color: widget.isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.shade200,
                  width: 1.5,
                ),
          boxShadow: [
            if (!widget.isDark && !_isPressed)
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.icon,
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.isPrimary
                      ? Colors.white
                      : (widget.isDark
                            ? Colors.white
                            : AppColors.textMainLight),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
