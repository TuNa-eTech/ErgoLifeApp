import 'package:flutter/material.dart';

/// Custom painter that draws diagonal striped pattern
/// Used in progress bars to create visual interest
class StripedPatternPainter extends CustomPainter {
  const StripedPatternPainter({
    required this.color,
    this.stripeWidth = 10,
    this.gapWidth = 10,
  });

  final Color color;
  final double stripeWidth;
  final double gapWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw diagonal stripes
    final double totalWidth = size.width + size.height;
    final double step = stripeWidth + gapWidth;

    // Save layer to clip strictly to the container
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    for (double x = -size.height; x < totalWidth; x += step) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + stripeWidth, size.height)
        ..lineTo(x + stripeWidth + size.height, 0)
        ..lineTo(x + size.height, 0)
        ..close();
      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
