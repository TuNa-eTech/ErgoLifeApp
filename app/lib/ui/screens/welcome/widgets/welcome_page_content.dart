import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';

/// A single page/slide in the Welcome screen with staggered
/// entrance animations and a subtle floating illustration.
class WelcomePageContent extends StatefulWidget {
  final String imagePath;
  final String title;
  final String description;
  final bool isDark;

  const WelcomePageContent({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.isDark,
  });

  @override
  State<WelcomePageContent> createState() => _WelcomePageContentState();
}

class _WelcomePageContentState extends State<WelcomePageContent>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _floatController;

  late final Animation<double> _imageOpacity;
  late final Animation<Offset> _imageSlide;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _descOpacity;
  late final Animation<Offset> _descSlide;

  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Image: 0.0 → 0.5
    _imageOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );
    _imageSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0, 0.5, curve: Curves.easeOutCubic),
          ),
        );

    // Title: 0.25 → 0.7
    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.25, 0.7, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.25, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    // Description: 0.45 → 0.9
    _descOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.45, 0.9, curve: Curves.easeOut),
      ),
    );
    _descSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.45, 0.9, curve: Curves.easeOutCubic),
          ),
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
    _startAnimations();
  }

  void _startAnimations() {
    if (_reduceMotion) {
      _entranceController.value = 1.0;
      return;
    }
    _entranceController.forward();
    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark
        ? AppColors.textMainDark
        : AppColors.textMainLight;
    final subColor = widget.isDark
        ? AppColors.textSubDark
        : AppColors.textSubLight;

    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = (screenWidth * 0.6).clamp(200.0, 260.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Floating illustration
          SlideTransition(
            position: _imageSlide,
            child: FadeTransition(
              opacity: _imageOpacity,
              child: AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  final floatOffset = _reduceMotion
                      ? 0.0
                      : (_floatController.value - 0.5) * 10;
                  return Transform.translate(
                    offset: Offset(0, floatOffset),
                    child: child,
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    widget.imagePath,
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Title — clean, solid color
          SlideTransition(
            position: _titleSlide,
            child: FadeTransition(
              opacity: _titleOpacity,
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Description
          SlideTransition(
            position: _descSlide,
            child: FadeTransition(
              opacity: _descOpacity,
              child: Text(
                widget.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: subColor,
                  height: 1.6,
                ),
              ),
            ),
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
