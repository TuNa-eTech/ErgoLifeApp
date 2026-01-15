import 'dart:math';
import 'package:flutter/material.dart';

/// Animated floating particles background effect
class AnimatedParticles extends StatefulWidget {
  final int particleCount;
  final Color color;
  final double minSize;
  final double maxSize;

  const AnimatedParticles({
    super.key,
    this.particleCount = 30,
    this.color = Colors.white,
    this.minSize = 2,
    this.maxSize = 6,
  });

  @override
  State<AnimatedParticles> createState() => _AnimatedParticlesState();
}

class _AnimatedParticlesState extends State<AnimatedParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeParticles();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  void _initializeParticles() {
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(
        Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size:
              widget.minSize +
              _random.nextDouble() * (widget.maxSize - widget.minSize),
          speed: 0.0001 + _random.nextDouble() * 0.0003,
          opacity: 0.1 + _random.nextDouble() * 0.4,
          phase: _random.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlesPainter(
            particles: _particles,
            progress: _controller.value,
            color: widget.color,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final double phase;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.phase,
  });
}

class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final Color color;

  ParticlesPainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final offsetY = (particle.y + particle.speed * progress) % 1.0;
      final wobble = sin((progress * 2 * pi) + particle.phase) * 0.02;

      final position = Offset(
        (particle.x + wobble) * size.width,
        offsetY * size.height,
      );

      final paint = Paint()
        ..color = color.withValues(alpha: particle.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) => true;
}
