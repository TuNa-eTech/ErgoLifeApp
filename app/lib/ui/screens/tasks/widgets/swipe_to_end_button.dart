import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';

/// Modern premium swipe-to-end button for ending active session
/// Features a glassmorphism style with smooth interactive feedback
class SwipeToEndButton extends StatefulWidget {
  const SwipeToEndButton({
    required this.isDark,
    this.onComplete,
    this.height = 64.0,
    super.key,
  });

  final bool isDark;
  final VoidCallback? onComplete;
  final double height;

  @override
  State<SwipeToEndButton> createState() => _SwipeToEndButtonState();
}

class _SwipeToEndButtonState extends State<SwipeToEndButton>
    with SingleTickerProviderStateMixin {
  double _dragValue = 0.0;
  bool _isDragging = false;
  static const double _padding = 4.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final knobSize = widget.height - (_padding * 2);
        final maxDrag = maxWidth - knobSize - (_padding * 2);
        final progress = (_dragValue / maxDrag).clamp(0.0, 1.0);

        // Colors derived from theme
        final baseColor = AppColors.error;
        final backgroundColor = widget.isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03);
        final borderColor = widget.isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05);

        return Container(
          height: widget.height,
          width: maxWidth,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(widget.height / 2),
            border: Border.all(color: borderColor),
          ),
          child: Stack(
            children: [
              // 1. Progress Background Fill
              if (progress > 0)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: knobSize + _dragValue + (_padding * 2),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.height / 2),
                      gradient: LinearGradient(
                        colors: [
                          baseColor.withValues(alpha: 0.2),
                          baseColor.withValues(alpha: 0.4 + (progress * 0.4)),
                        ],
                      ),
                    ),
                  ),
                ),

              // 2. Centered Text Label
              Center(
                child: AnimatedOpacity(
                  opacity: (1.0 - (progress * 1.5)).clamp(0.0, 1.0),
                  duration: const Duration(milliseconds: 100),
                  child: Text(
                    'SWIPE TO END SESSION',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: widget.isDark
                          ? AppColors.textSubDark
                          : AppColors.textSubLight,
                    ),
                  ),
                ),
              ),

              // 3. Draggable Knob
              Positioned(
                left: _padding + _dragValue,
                top: _padding,
                bottom: _padding,
                child: GestureDetector(
                  onHorizontalDragStart: (_) =>
                      setState(() => _isDragging = true),
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragValue = (_dragValue + details.delta.dx).clamp(
                        0.0,
                        maxDrag,
                      );
                    });
                  },
                  onHorizontalDragEnd: (_) => _handleDragEnd(maxDrag),
                  onHorizontalDragCancel: () => _handleDragEnd(maxDrag),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    width: knobSize,
                    height: knobSize,
                    transform: Matrix4.identity()
                      ..scale(_isDragging ? 1.1 : 1.0),
                    transformAlignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: progress > 0.8
                          ? baseColor
                          : (widget.isDark ? Colors.white : Colors.white),
                      boxShadow: [
                        BoxShadow(
                          color: baseColor.withValues(alpha: 0.2 * progress),
                          blurRadius: _isDragging ? 16 : 12,
                          spreadRadius: _isDragging ? 4 : 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.stop_rounded,
                        color: progress > 0.8 ? Colors.white : baseColor,
                        size: 24 + (progress * 4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleDragEnd(double maxDrag) {
    setState(() => _isDragging = false);
    if (_dragValue >= maxDrag * 0.7) {
      // Snap to end and trigger
      setState(() => _dragValue = maxDrag);
      widget.onComplete?.call();
    } else {
      // Snap back to start
      setState(() => _dragValue = 0.0);
    }
  }
}
