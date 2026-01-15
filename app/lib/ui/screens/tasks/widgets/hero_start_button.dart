import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';

/// Enhanced START button with ripple effects and animations
class HeroStartButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color primaryColor;
  final Color secondaryColor;

  const HeroStartButton({
    super.key,
    required this.onTap,
    this.primaryColor = AppColors.secondary,
    this.secondaryColor = const Color(0xFFFF8C00),
  });

  @override
  State<HeroStartButton> createState() => _HeroStartButtonState();
}

class _HeroStartButtonState extends State<HeroStartButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Ripple animation (triggered on press)
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _rippleController.forward(from: 0.0);

    // Small delay for visual feedback
    Future.delayed(const Duration(milliseconds: 150), widget.onTap);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _rippleController]),
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.95 : _pulseAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ripple effect
                if (_rippleAnimation.value > 0.0)
                  Container(
                    width: 180 + (_rippleAnimation.value * 60),
                    height: 180 + (_rippleAnimation.value * 60),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.primaryColor.withValues(
                          alpha: 0.5 * (1 - _rippleAnimation.value),
                        ),
                        width: 3,
                      ),
                    ),
                  ),
                // Main button
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [widget.primaryColor, widget.secondaryColor],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.primaryColor.withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: widget.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 60,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        size: 80,
                        color: Colors.white.withValues(
                          alpha: _isPressed ? 0.8 : 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'START',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withValues(
                            alpha: _isPressed ? 0.8 : 1.0,
                          ),
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Shimmer effect on hover
                if (!_isPressed)
                  Positioned(
                    top: 30,
                    left: 50,
                    child: Container(
                      width: 80,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.3),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
