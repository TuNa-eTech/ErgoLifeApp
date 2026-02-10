import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/core/di/service_locator.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';
import 'package:ergo_life_app/data/services/storage_service.dart';
import 'package:ergo_life_app/l10n/app_localizations.dart';

import 'package:ergo_life_app/ui/screens/welcome/widgets/welcome_page_content.dart';
import 'package:ergo_life_app/ui/screens/welcome/widgets/welcome_page_indicator.dart';

/// Welcome introduction screen shown to first-time users.
///
/// Displays 4 slides explaining the app's core features
/// with clean animations and a professional layout.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 4;

  late final AnimationController _bottomController;
  late final Animation<double> _bottomOpacity;
  late final Animation<Offset> _bottomSlide;

  @override
  void initState() {
    super.initState();

    _bottomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _bottomOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _bottomController,
        curve: const Interval(0, 0.8, curve: Curves.easeOut),
      ),
    );

    _bottomSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _bottomController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      _bottomController.value = 1.0;
    } else {
      _bottomController.forward();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bottomController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeWelcome();
    }
  }

  Future<void> _completeWelcome() async {
    await sl<StorageService>().setHasSeenWelcome();
    if (!mounted) return;
    context.go(AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final l10n = AppLocalizations.of(context)!;

    final pages = [
      WelcomePageContent(
        imagePath: 'assets/images/welcome_slide_1.png',
        title: l10n.welcomeTitle1,
        description: l10n.welcomeDesc1,
        isDark: isDark,
      ),
      WelcomePageContent(
        imagePath: 'assets/images/welcome_slide_2.png',
        title: l10n.welcomeTitle2,
        description: l10n.welcomeDesc2,
        isDark: isDark,
      ),
      WelcomePageContent(
        imagePath: 'assets/images/welcome_slide_3.png',
        title: l10n.welcomeTitle3,
        description: l10n.welcomeDesc3,
        isDark: isDark,
      ),
      WelcomePageContent(
        imagePath: 'assets/images/welcome_slide_4.png',
        title: l10n.welcomeTitle4,
        description: l10n.welcomeDesc4,
        isDark: isDark,
      ),
    ];

    final isLastPage = _currentPage == _totalPages - 1;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isLastPage)
                    SizedBox(
                      height: 44,
                      child: TextButton(
                        onPressed: _completeWelcome,
                        child: Text(
                          l10n.skip,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSubDark
                                : AppColors.textSubLight,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page view
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: pages,
              ),
            ),

            // Bottom section: indicators + CTA
            SlideTransition(
              position: _bottomSlide,
              child: FadeTransition(
                opacity: _bottomOpacity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
                  child: Column(
                    children: [
                      WelcomePageIndicator(
                        currentPage: _currentPage,
                        totalPages: _totalPages,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isLastPage ? l10n.getStarted : l10n.next,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top bar with subtle progress line and skip button.
class _TopBar extends StatelessWidget {
  final double progress;
  final bool isLastPage;
  final bool isDark;
  final String skipLabel;
  final VoidCallback onSkip;

  const _TopBar({
    required this.progress,
    required this.isLastPage,
    required this.isDark,
    required this.skipLabel,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          // Subtle progress bar — single solid color
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: 3,
              child: Stack(
                children: [
                  Container(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Skip button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isLastPage)
                SizedBox(
                  height: 44,
                  child: TextButton(
                    onPressed: onSkip,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Text(
                      skipLabel,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSubDark
                            : AppColors.textSubLight,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
