import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';
import 'dart:ui'; // For ImageFilter

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  // --- Page 1 State (Avatar) ---
  final PageController _avatarController = PageController(initialPage: 1, viewportFraction: 0.45);
  int _currentAvatarIndex = 1;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  bool _isNameValid = false;
  final List<String> _avatars = [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAPW5wBYWeCZYhmHGlLw8SqWfvyv26QyDSkT7Z0d4sQOtRpvHxKTfCK4aRVUfxYrzVknR_rQGorZakQXvFJCONBOyvFYSW0tsu-oO1Egjh4-BXtZH8ohKCCobggwneep1v39ZH0eJBBH_f_3psVX_lRBUqA3OzIgHSMto9w9MMoL7ShTF4vcflUj5bIXgiSQrZEC7ctrGxSNJMlzD1s7tviaX4NuGHQTFm6xH_mgN9MJaj50_7FBW7IohrhwEWeXK4BfpX-dmvzyfE',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBtW0gd-cMzpNJMcECXteyrCW5t4UFpL3Nem97o9UqjWhV1KG1hMpoqwGE0Qt5QkLTXKR90zjIVQ1a3L0TGXJ8Kd5NHNxy5EmQ__0KG0KxGXD_BNpKH3NifBLi-aHVBn6F3FS48mylD5HunAWt9earoN5b4Wm79IJU2BPYBkg-oylv2cbBbSYuJLZFOQiByP_8x1YTL66C0t7IbZVHok8JCEVEzb8vgk583NYH0tob4wOE15jiy0e4RsooiXod7IZVlO9S8_gWpmlc',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBNeyeNkoPMHHLqdKk5vApdnqsFDKEQgmc9wddF1wX4kDsJsrDKhYQXD8jRdtZw29NMscCs5fR_Yz9a5IWM_MnwBclg87ct7kUgavaXTfEZezPxHg62MjhIvF5xj6HWW9GVIy808cEhuibMN5KNed6XuWnFXh0wRvBj5mm_ra4CTKLRGlqXvCht10HTLC-VmYX7Z4qJ6Ug_wFBI8HeYruyp2WolZincMUmZxHBBcjNpc1zRN8VFDJlXSefKwtcVyB3_vuTsCoK57r8',
  ];

  // --- Page 2 State (Sync Bio) ---
  bool _isAppleHealthEnabled = true;
  bool _isGarminEnabled = false;
  bool _isGoogleFitEnabled = false;

  // --- Page 3 State (Mode) ---
  String _playMode = 'shared';

  // Colors
  static const Color primaryColor = Color(0xFFFF6A00);
  static const Color lightBg = Color(0xFFF8F7F5);
  static const Color darkBg = Color(0xFF23170F);
  static const Color textMainLight = Color(0xFF181410);

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {
        _isNameValid = _nameController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _avatarController.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Finish onboarding
      context.go(AppRouter.home);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
       // Optional: Navigate back to Splash or just do nothing?
       // Usually Back from first step exits app or goes to splash?
       // For now, allow pop if possible or stay.
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? darkBg : lightBg;
    final textColor = isDark ? Colors.white : textMainLight;

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true, // Allow layout to adjust for keyboard
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // --- Unified Header ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        const SizedBox(width: 40), // Spacer placeholder

                      // Indicators (Dots)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_totalPages, (index) {
                          final isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: isActive ? 24 : 6,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? primaryColor
                                  : (isDark ? Colors.white.withOpacity(0.2) : Colors.grey[300]),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),

                      // Step Pill / Skip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Step ${_currentPage + 1}/$_totalPages',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- PageView ---
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // Disable swipe to enforce validation/flow if needed, or allow it. Designing for flow, let's keep it swipeable? No, let's use button control for strict flow.
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      _buildAvatarPage(isDark, textColor),
                      _buildSyncBioPage(isDark, textColor),
                      _buildChooseModePage(isDark, textColor),
                    ],
                  ),
                ),
                
                 // Space for Fixed Footer
                 const SizedBox(height: 100),
              ],
            ),

            // --- Unified Footer ---
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
                      bgColor.withOpacity(0.95),
                      bgColor.withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
                child: SizedBox(
                   height: 56,
                   child: ElevatedButton(
                     onPressed: _nextPage,
                     style: ElevatedButton.styleFrom(
                       backgroundColor: primaryColor,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(30),
                       ),
                       elevation: 8,
                       shadowColor: primaryColor.withOpacity(0.3),
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Text(
                           _currentPage == _totalPages - 1 ? 'Start Journey' : 'Continue',
                           style: const TextStyle(
                             fontSize: 18,
                             fontWeight: FontWeight.bold,
                             color: Colors.white,
                           ),
                         ),
                         const SizedBox(width: 8),
                         const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                       ],
                     ),
                   ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Shared Widgets ---

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
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Icon(
          icon,
           size: 18,
           color: isDark ? Colors.white : const Color(0xFF181410),
        ),
      ),
    );
  }

  // --- Page 1: Avatar Selection Content ---

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
                  'Choose your fighter',
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
                  'Pick your avatar for the leaderboard',
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
              itemCount: _avatars.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _avatarController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_avatarController.position.haveDimensions) {
                      value = _avatarController.page! - index;
                      value = (1 - (value.abs() * 0.4)).clamp(0.0, 1.0);
                    } else {
                      value = (index == 1) ? 1.0 : 0.6;
                    }
                    final isActive = index == _currentAvatarIndex;
                    return Center(
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
                                   border: Border.all(color: Colors.white, width: 4),
                                    boxShadow: isActive ? [
                                      BoxShadow(color: primaryColor, spreadRadius: 6, blurRadius: 0),
                                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                                    ] : [],
                                   image: DecorationImage(image: NetworkImage(_avatars[index]), fit: BoxFit.cover),
                                 ),
                               ),
                               if (isActive)
                                 Positioned(
                                  bottom: -15,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1D2939),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text('SELECTED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                 ),
                             ],
                           ),
                         ),
                      ),
                    );
                  },
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
                  "Bạn muốn 'võ sĩ' này được gọi là gì?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C1F18) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Center(
                    child: TextField(
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: textColor),
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                           padding: const EdgeInsets.only(left: 20, right: 14),
                           child: Icon(Icons.badge_outlined, color: _nameFocusNode.hasFocus ? primaryColor : const Color(0xFF98A2B3)),
                        ),
                        suffixIcon: Padding(
                           padding: const EdgeInsets.only(right: 20),
                           child: AnimatedOpacity(
                             duration: const Duration(milliseconds: 200),
                             opacity: _isNameValid ? 1.0 : 0.0,
                             child: const Icon(Icons.check_circle, color: Colors.green),
                           ),
                        ),
                        hintText: 'Enter display name...',
                        hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 20),
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

  // --- Page 2: Sync Bio Content ---

  Widget _buildSyncBioPage(bool isDark, Color textColor) {
    final cardColor = isDark ? const Color(0xFF2C221B) : Colors.white;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
           // Hero Section
           Stack(
             alignment: Alignment.center,
             children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: primaryColor.withOpacity(0.2), shape: BoxShape.circle),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                     color: isDark ? const Color(0xFF262626) : Colors.white,
                     shape: BoxShape.circle,
                     boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
                  ),
                  child: const Icon(Icons.monitor_heart_outlined, color: primaryColor, size: 48),
                ),
             ],
           ),
           const SizedBox(height: 24),
           Text( 'Sync Your Bio-Data', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: textColor)),
           const SizedBox(height: 12),
           Text( 'Hãy cho tôi thấy những nỗ lực thầm lặng của bạn. Kết nối để tính điểm công bằng nhất!', textAlign: TextAlign.center,
             style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
           ),
           const SizedBox(height: 32),
           _buildSyncItem(isDark: isDark, cardColor: cardColor, icon: Icons.favorite, title: 'Apple Health', subtitle: 'Syncs steps, heart rate', value: _isAppleHealthEnabled, onChanged: (v) => setState(() => _isAppleHealthEnabled = v)),
           const SizedBox(height: 16),
           _buildSyncItem(isDark: isDark, cardColor: cardColor, icon: Icons.watch, title: 'Garmin Connect', subtitle: 'Syncs workouts, sleep', value: _isGarminEnabled, onChanged: (v) => setState(() => _isGarminEnabled = v)),
           const SizedBox(height: 16),
           _buildSyncItem(isDark: isDark, cardColor: cardColor, icon: Icons.directions_run, title: 'Google Fit', subtitle: 'Syncs general activity', value: _isGoogleFitEnabled, onChanged: (v) => setState(() => _isGoogleFitEnabled = v)),
        ],
      ),
    );
  }

  Widget _buildSyncItem({
    required bool isDark, required Color cardColor, required IconData icon, required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
             width: 48, height: 48,
             decoration: BoxDecoration(color: isDark ? const Color(0xFF262626) : const Color(0xFFF5F2F0), shape: BoxShape.circle),
             child: Icon(icon, color: isDark ? Colors.white : const Color(0xFF181410), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF181410))),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: primaryColor,
          ),
        ],
      ),
    );
  }

  // --- Page 3: Choose Mode Content ---

  Widget _buildChooseModePage(bool isDark, Color textColor) {
    final cardColor = isDark ? const Color(0xFF2C241E) : Colors.white;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
           const SizedBox(height: 20),
           Text('Chọn chế độ chơi', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: textColor)),
           const SizedBox(height: 12),
           Text('Bạn đã sẵn sàng cho đấu trường việc nhà chưa?', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey[500])),
           const SizedBox(height: 32),
           _buildModeCard(isDark: isDark, bgColor: cardColor, mode: 'solo', icon: Icons.person, title: 'Tạo Nhà Của Tôi', subtitle: 'Chế độ Solo: Tự hoàn thiện bản thân theo cách riêng.'),
           const SizedBox(height: 16),
           _buildModeCard(isDark: isDark, bgColor: cardColor, mode: 'shared', icon: Icons.diversity_3, title: 'Tạo Nhà Chung', subtitle: 'Chế độ Đấu trường: Cạnh tranh cùng người thân.', hasInput: true),
           const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildModeCard({ required bool isDark, required Color bgColor, required String mode, required IconData icon, required String title, required String subtitle, bool hasInput = false}) {
    final bool isSelected = _playMode == mode;
    final Color textColor = isDark ? Colors.white : const Color(0xFF181410);

    return GestureDetector(
      onTap: () => setState(() => _playMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? const Color(0xFF2C241E) : Colors.white) : bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? primaryColor : Colors.transparent, width: 2),
          boxShadow: [
             if (isSelected) BoxShadow(color: primaryColor.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))
             else BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                   width: 48, height: 48,
                   decoration: BoxDecoration(
                      color: isSelected ? primaryColor : (isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFF2F4F7)),
                      borderRadius: BorderRadius.circular(12),
                   ),
                   child: Icon(icon, size: 24, color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[600])),
                ),
                if (isSelected) const Icon(Icons.check_circle, color: primaryColor),
              ],
            ),
             const SizedBox(height: 16),
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                 const SizedBox(height: 4),
                 Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
               ],
             ),
             if (hasInput && isSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                     decoration: BoxDecoration(color: isDark ? Colors.black.withOpacity(0.2) : const Color(0xFFF8F7F5), borderRadius: BorderRadius.circular(8)),
                     child: TextField(
                       style: TextStyle(color: textColor),
                       decoration: InputDecoration(
                         hintText: 'Đặt tên cho Đấu Trường...',
                         hintStyle: TextStyle(color: Colors.grey[400]),
                         border: InputBorder.none,
                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                         suffixIcon: const Icon(Icons.edit, color: primaryColor, size: 20),
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
