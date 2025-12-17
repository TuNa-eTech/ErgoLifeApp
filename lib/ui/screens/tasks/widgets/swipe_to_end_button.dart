import 'package:flutter/material.dart';

/// Swipe-to-end button widget for ending active session
class SwipeToEndButton extends StatefulWidget {
  const SwipeToEndButton({required this.isDark, this.onComplete, super.key});

  final bool isDark;
  final VoidCallback? onComplete;

  @override
  State<SwipeToEndButton> createState() => _SwipeToEndButtonState();
}

class _SwipeToEndButtonState extends State<SwipeToEndButton> {
  double _swipeOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        return Container(
          height: 64,
          width: maxWidth,
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0xFF1F2937)
                : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: widget.isDark
                  ? Colors.grey.shade800
                  : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [_buildBackgroundText(), _buildSwipeKnob(maxWidth)],
          ),
        );
      },
    );
  }

  Widget _buildBackgroundText() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'SWIPE TO END',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: widget.isDark
                  ? Colors.grey.shade600
                  : Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            size: 16,
            color: widget.isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeKnob(double maxWidth) {
    return Positioned(
      left: _swipeOffset,
      top: 4,
      bottom: 4,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            _swipeOffset += details.delta.dx;
            // Clamp offset
            if (_swipeOffset < 0) _swipeOffset = 0;
            if (_swipeOffset > maxWidth - 64) _swipeOffset = maxWidth - 64;
          });
        },
        onHorizontalDragEnd: (details) {
          if (_swipeOffset > maxWidth * 0.6) {
            // Trigger complete action
            widget.onComplete?.call();
          } else {
            // Reset to start position
            setState(() {
              _swipeOffset = 0;
            });
          }
        },
        child: Container(
          width: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: const Center(
            child: Icon(Icons.stop_circle, color: Colors.red, size: 28),
          ),
        ),
      ),
    );
  }
}
