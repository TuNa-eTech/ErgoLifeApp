import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';
import 'package:ergo_life_app/blocs/onboarding/onboarding_bloc.dart';
import 'package:ergo_life_app/blocs/onboarding/onboarding_event.dart';
import 'package:ergo_life_app/blocs/onboarding/onboarding_state.dart';

class OnboardingScreen extends StatefulWidget {
  final OnboardingBloc onboardingBloc;
  
  const OnboardingScreen({
    super.key,
    required this.onboardingBloc,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 2; // Changed from 3 to 2

  // --- Page 1 State (Avatar + Name) ---
  final PageController _avatarController = PageController(
    initialPage: 1,
    viewportFraction: 0.45,
  );
  int _currentAvatarIndex = 1;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  bool _isNameValid = false;

  // Local avatar assets (replacing Google URLs)
  final List<String> _avatarEmojis = ['🧑‍💼', '👨‍🚀', '👩‍🎨'];

  // --- Page 2 State (Create Space) ---
  final TextEditingController _houseNameController = TextEditingController();
  final FocusNode _houseNameFocusNode = FocusNode();
  bool _isHouseNameValid = false;

  late OnboardingBloc _onboardingBloc;

  @override
  void initState() {
    super.initState();
    _onboardingBloc = widget.onboardingBloc;
    _nameController.addListener(() {
      setState(() {
        _isNameValid = _nameController.text.trim().isNotEmpty;
      });
    });

    _houseNameController.addListener(() {
      setState(() {
        _isHouseNameValid = _houseNameController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _onboardingBloc.close();
    _pageController.dispose();
    _avatarController.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    _houseNameController.dispose();
    _houseNameFocusNode.dispose();
    super.dispose();
  }

  void _nextPage() {
    // Validate before proceeding
    if (_currentPage == 0 && !_isNameValid) {
      _showError('Vui lòng nhập tên hiển thị');
      return;
    }

    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _createSoloHouse() {
    _onboardingBloc.add(
      CreateSoloHouse(
        displayName: _nameController.text.trim(),
        avatarId: _currentAvatarIndex + 1,
        houseName: '${_nameController.text.trim()}\'s Space',
      ),
    );
  }

  void _showArenaBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildArenaBottomSheet(),
    ).then((_) {
      _houseNameController.clear();
      setState(() => _isHouseNameValid = false);
    });
  }

  void _createArena() {
    // Close bottom sheet first
    Navigator.of(context).pop();

    _onboardingBloc.add(
      CreateArenaHouse(
        displayName: _nameController.text.trim(),
        avatarId: _currentAvatarIndex + 1,
        houseName: _houseNameController.text.trim(),
      ),
    );
  }

  void _showSuccessAndNavigate(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMainLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      Navigator.of(context).pop();
      context.go(AppRouter.home);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textColor = isDark ? AppColors.textMainDark : AppColors.textMainLight;

    return BlocProvider.value(
      value: _onboardingBloc,
      child: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingSuccess) {
            _showSuccessAndNavigate(state.message);
          } else if (state is OnboardingError) {
            _showError(state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is OnboardingLoading;
          return Scaffold(
            backgroundColor: bgColor,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back Button
                            if (_currentPage > 0)
                              _buildCircleButton(
                                isDark: isDark,
                                icon: Icons.arrow_back_ios_new,
                                onTap: _prevPage,
                              )
                            else
                              const SizedBox(width: 40),

                            // Indicators
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(_totalPages, (index) {
                                final isActive = index == _currentPage;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  height: 6,
                                  width: isActive ? 24 : 6,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.secondary
                                        : (isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.2)
                                            : Colors.grey[300]),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                );
                              }),
                            ),

                            // Step Counter
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Step ${_currentPage + 1}/$_totalPages',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // PageView
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          children: [
                            _buildAvatarPage(isDark, textColor),
                            _buildCreateSpacePage(isDark, textColor,
                                isLoading: isLoading),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),

                  // Footer Button
                  if (_currentPage == 0)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              bgColor,
                              bgColor.withValues(alpha: 0.95),
                              bgColor.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isNameValid ? _nextPage : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              disabledBackgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                              shadowColor: AppColors.secondary
                                  .withValues(alpha: 0.3),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // Loading Overlay
                  if (isLoading)
                     Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.5),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                     ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCircleButton({
    required bool isDark,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? Colors.white : AppColors.textMainLight,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // PAGE 1: AVATAR + NAME
  // ═══════════════════════════════════════

  Widget _buildAvatarPage(bool isDark, Color textColor) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  'Choose your avatar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pick one for the leaderboard (optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : const Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 192,
            child: PageView.builder(
              controller: _avatarController,
              onPageChanged: (index) {
                setState(() {
                  _currentAvatarIndex = index;
                });
              },
              itemCount: _avatarEmojis.length,
              itemBuilder: (context, index) {
                final isActive = index == _currentAvatarIndex;
                return Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: Transform.scale(
                      scale: isActive ? 1.1 : 0.8,
                      child: Opacity(
                        opacity: isActive ? 1.0 : 0.4,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 144,
                              height: 144,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                color: isDark
                                    ? AppColors.surfaceDark
                                    : AppColors.surfaceLight,
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: AppColors.secondary,
                                          spreadRadius: 6,
                                          blurRadius: 0,
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  _avatarEmojis[index],
                                  style: const TextStyle(fontSize: 64),
                                ),
                              ),
                            ),
                            if (isActive)
                              Positioned(
                                bottom: -15,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1D2939),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'SELECTED',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  'What should we call you?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C1F18) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: TextField(
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 14),
                          child: Icon(
                            Icons.badge_outlined,
                            color: _nameFocusNode.hasFocus
                                ? AppColors.secondary
                                : const Color(0xFF98A2B3),
                          ),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _isNameValid ? 1.0 : 0.0,
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        hintText: 'Enter your name...',
                        hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // PAGE 2: CREATE SPACE
  // ═══════════════════════════════════════

  Widget _buildCreateSpacePage(bool isDark, Color textColor, {required bool isLoading}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            'Choose Your Journey',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bạn muốn ErgoLife như thế nào?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 40),

          // Personal Space Card
          _buildPersonalSpaceCard(isDark, isLoading: isLoading),

          const SizedBox(height: 24),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'or compete with',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),

          const SizedBox(height: 24),

          // Family Arena Card
          _buildFamilyArenaCard(isDark),

          const SizedBox(height: 24),
          
          // Join Code Button
          Center(
            child: TextButton.icon(
              onPressed: () => _showJoinCodeDialog(context, isDark),
              icon: Icon(Icons.qr_code, color: textColor),
              label: Text(
                'Already have an invite code?',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPersonalSpaceCard(bool isDark, {required bool isLoading}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF5E6), Color(0xFFFFE5CC)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF6A00).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text('🏡', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'MY PERSONAL SPACE',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6A00),
            ),
          ),
          const SizedBox(height: 16),
          _buildBenefit('Focus on yourself', isDark),
          const SizedBox(height: 8),
          _buildBenefit('Track your progress', isDark),
          const SizedBox(height: 8),
          _buildBenefit('Build healthy habits', isDark),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : _createSoloHouse,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6A00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Continue Solo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: Colors.white,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyArenaCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F4FF), Color(0xFFCCE5FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2575FC).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text('🏆', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'FAMILY ARENA',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2575FC),
            ),
          ),
          const SizedBox(height: 16),
          _buildBenefit('Challenge loved ones', isDark),
          const SizedBox(height: 8),
          _buildBenefit('Friendly competition', isDark),
          const SizedBox(height: 8),
          _buildBenefit('Climb leaderboards', isDark),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _showArenaBottomSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2575FC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Create Arena',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(String text, bool isDark) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          size: 16,
          color: isDark ? Colors.white70 : const Color(0xFF667085),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : const Color(0xFF667085),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // ARENA BOTTOM SHEET
  // ═══════════════════════════════════════

  Widget _buildArenaBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            // Trophy icon
            const Text('🏆', style: TextStyle(fontSize: 80)),

            const SizedBox(height: 24),

            // Title
            Text(
              'Create Your Arena',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Give your family competition a name!',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            const SizedBox(height: 32),

            // Input field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F7F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _houseNameFocusNode.hasFocus
                        ? const Color(0xFFFF6A00)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: TextField(
                  controller: _houseNameController,
                  focusNode: _houseNameFocusNode,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. "Nhà Warriors" 💪',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.normal,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Suggestion chips
            Wrap(
              spacing: 8,
              children: [
                _buildSuggestionChip('Team Alpha 🚀'),
                _buildSuggestionChip('The Champions 🏆'),
                _buildSuggestionChip('Fitness Crew 💪'),
              ],
            ),

            const Spacer(),

            // Submit button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isHouseNameValid ? _createArena : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6A00),
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Create Arena',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white),
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

  Widget _buildSuggestionChip(String text) {
    return InkWell(
      onTap: () {
        final nameOnly = text
            .split(' ')
            .sublist(0, text.split(' ').length - 1)
            .join(' ');
        _houseNameController.text = nameOnly;
        setState(() => _isHouseNameValid = true);
      },
      child: Chip(
        label: Text(text),
        backgroundColor: const Color(0xFFFFE5CC),
        labelStyle: const TextStyle(
          color: Color(0xFFFF6A00),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  void _showJoinCodeDialog(BuildContext context, bool isDark) {
    final codeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        title: Text('Join House', style: TextStyle(color: isDark ? AppColors.textMainDark : AppColors.textMainLight)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the 6-digit code shared by your house admin.'),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Invite Code',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
               Navigator.pop(ctx);
               _onboardingBloc.add(
                 JoinHouse(
                   code: codeController.text.trim(),
                   displayName: _nameController.text.trim(),
                   avatarId: _currentAvatarIndex + 1,
                 ),
               );
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}

