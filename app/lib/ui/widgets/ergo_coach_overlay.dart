import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/data/models/task_model.dart';

/// Overlay widget showing Ergo-Coach animation and tips before starting a task
/// Automatically skips after user has seen it 3 times per task type
class ErgoCoachOverlay extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onReady;
  final VoidCallback onSkip;

  const ErgoCoachOverlay({
    super.key,
    required this.task,
    required this.onReady,
    required this.onSkip,
  });

  @override
  State<ErgoCoachOverlay> createState() => _ErgoCoachOverlayState();
}

class _ErgoCoachOverlayState extends State<ErgoCoachOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _canSkip = false;
  int _viewCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _loadViewCount();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadViewCount() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'ergo_coach_${widget.task.id}_views';
    final count = prefs.getInt(key) ?? 0;

    setState(() {
      _viewCount = count;
      // Auto skip if seen 3+ times
      if (_viewCount >= 3) {
        _canSkip = true;
        // Auto-close after 1 second if already seen 3 times
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            widget.onSkip();
          }
        });
      }
    });

    // Increment view count
    await prefs.setInt(key, count + 1);
  }

  String _getAnimationPath() {
    // Map task category to animation file
    final category = widget.task.category?.toLowerCase() ?? 'default';

    // Map categories to animation files
    final animationMap = {
      'vacuuming': 'assets/animations/ergo_coach/vacuuming.json',
      'mopping': 'assets/animations/ergo_coach/mopping.json',
      'dishwashing': 'assets/animations/ergo_coach/dishwashing.json',
      'toilet cleaning': 'assets/animations/ergo_coach/toilet_cleaning.json',
      'bed making': 'assets/animations/ergo_coach/bed_making.json',
      'laundry': 'assets/animations/ergo_coach/laundry.json',
      'shopping': 'assets/animations/ergo_coach/shopping.json',
      'cooking': 'assets/animations/ergo_coach/cooking.json',
      'trash': 'assets/animations/ergo_coach/trash.json',
      'pet care': 'assets/animations/ergo_coach/pet_care.json',
    };

    // Return mapped animation or use a placeholder
    // For now, we'll use a placeholder until animations are added
    return animationMap[category] ?? '';
  }

  String _getErgoTip() {
    // Ergonomic tips based on task type
    final tips = {
      'vacuuming':
          'Keep your back straight and use your legs to push the vacuum.',
      'mopping': 'Use long strokes and avoid bending at the waist.',
      'dishwashing':
          'Stand with one foot elevated and keep dishes at waist height.',
      'toilet cleaning': 'Kneel on a padded mat instead of bending over.',
      'bed making': 'Bend your knees, not your back when tucking sheets.',
      'laundry': 'Carry baskets at waist height, not on your hip.',
      'shopping': 'Use a cart and distribute weight evenly in bags.',
      'cooking': 'Keep frequently used items at waist level.',
      'trash': 'Bend at the knees when lifting heavy bags.',
      'pet care': 'Squat down to pet level instead of bending over.',
    };

    final category = widget.task.category?.toLowerCase() ?? '';
    return tips[category] ?? 'Maintain good posture and take breaks regularly.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final animationPath = _getAnimationPath();

    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Skip button (top-right)
              if (_canSkip || _viewCount >= 3)
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton.icon(
                    onPressed: widget.onSkip,
                    icon: const Icon(Icons.skip_next, color: Colors.white70),
                    label: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),

              const Spacer(),

              // Title
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.secondary, width: 2),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lightbulb, color: AppColors.secondary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'ERGO-COACH',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Animation Container
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: animationPath.isNotEmpty
                    ? Lottie.asset(
                        animationPath,
                        controller: _controller,
                        onLoaded: (composition) {
                          _controller.duration = composition.duration;
                          _controller.repeat();
                          // Enable skip after animation loads
                          Future.delayed(const Duration(seconds: 2), () {
                            if (mounted) {
                              setState(() => _canSkip = true);
                            }
                          });
                        },
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              size: 64,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Animation Coming Soon',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              const SizedBox(height: 32),

              // Task Name
              Text(
                widget.task.exerciseName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Ergonomic Tip
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.tips_and_updates,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getErgoTip(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Ready Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: widget.onReady,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "I'm Ready!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // View count indicator
              if (_viewCount > 0)
                Text(
                  _viewCount >= 3
                      ? 'You\'ve mastered this! Auto-skipping next time.'
                      : 'View $_viewCount/3 - Skip available after 3 views',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
