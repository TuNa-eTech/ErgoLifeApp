import 'dart:math';
import 'package:flutter/material.dart';

/// Animated hero task icon with breathing effect and rotating gradient ring
class HeroTaskIcon extends StatefulWidget {
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final double size;

  const HeroTaskIcon({
    super.key,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    this.size = 120,
  });

  @override
  State<HeroTaskIcon> createState() => _HeroTaskIconState();
}

class _HeroTaskIconState extends State<HeroTaskIcon>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Breathing animation (scale + opacity)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // Ring rotation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(_rotationController);

    // Glow pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 20, end: 35).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _breathingController,
        _rotationController,
        _pulseController,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: widget.size + 40,
            height: widget.size + 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rotating gradient ring
                Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: CustomPaint(
                    size: Size(widget.size + 40, widget.size + 40),
                    painter: GradientRingPainter(
                      primaryColor: widget.primaryColor,
                      secondaryColor: widget.secondaryColor,
                      progress: _breathingController.value,
                    ),
                  ),
                ),
                // Pulsing glow
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.primaryColor.withValues(
                          alpha: 0.4 * _opacityAnimation.value,
                        ),
                        blurRadius: _pulseAnimation.value,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: widget.secondaryColor.withValues(
                          alpha: 0.3 * _opacityAnimation.value,
                        ),
                        blurRadius: _pulseAnimation.value + 10,
                        offset: const Offset(5, 5),
                      ),
                    ],
                  ),
                ),
                // Main icon container
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [widget.primaryColor, widget.secondaryColor],
                    ),
                  ),
                  child: Center(
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: Icon(
                        widget.icon,
                        size: widget.size * 0.46,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for the rotating gradient ring
class GradientRingPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final double progress;

  GradientRingPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..shader = SweepGradient(
        colors: [
          primaryColor.withValues(alpha: 0.0),
          primaryColor.withValues(alpha: 0.6),
          secondaryColor.withValues(alpha: 0.8),
          primaryColor.withValues(alpha: 0.6),
          primaryColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius - 2, paint);

    // Add a subtle inner ring
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = primaryColor.withValues(alpha: 0.2 + progress * 0.2);

    canvas.drawCircle(center, radius - 8, innerPaint);
  }

  @override
  bool shouldRepaint(GradientRingPainter oldDelegate) => true;
}
