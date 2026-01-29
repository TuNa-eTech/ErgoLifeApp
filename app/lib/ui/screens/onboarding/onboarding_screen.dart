import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/l10n/app_localizations.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';
import 'package:ergo_life_app/blocs/onboarding/onboarding_bloc.dart';
import 'package:ergo_life_app/blocs/onboarding/onboarding_event.dart';
import 'package:ergo_life_app/blocs/onboarding/onboarding_state.dart';

// Widgets
import 'package:ergo_life_app/ui/screens/onboarding/widgets/onboarding_header.dart';
import 'package:ergo_life_app/ui/screens/onboarding/widgets/onboarding_footer_button.dart';
import 'package:ergo_life_app/ui/screens/onboarding/widgets/avatar_page.dart';
import 'package:ergo_life_app/ui/screens/onboarding/widgets/create_space_page.dart';
import 'package:ergo_life_app/ui/screens/onboarding/widgets/arena_bottom_sheet.dart';
import 'package:ergo_life_app/ui/screens/onboarding/widgets/join_code_dialog.dart';
import 'package:ergo_life_app/ui/screens/onboarding/widgets/success_dialog.dart';

/// Onboarding screen with avatar selection, name input, and space creation
class OnboardingScreen extends StatefulWidget {
  final OnboardingBloc onboardingBloc;

  /// Initial name from Apple/Google Sign-In (if available)
  final String? initialName;

  /// Email from Apple/Google Sign-In (used as fallback for name)
  final String? email;

  const OnboardingScreen({
    super.key,
    required this.onboardingBloc,
    this.initialName,
    this.email,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 2;

  // Page 1: Avatar + Name
  late int _selectedAvatarId;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  bool _isNameValid = false;

  static const int totalAvatars = 60;

  // Page 2: Create Space
  final TextEditingController _houseNameController = TextEditingController();
  final FocusNode _houseNameFocusNode = FocusNode();
  bool _isHouseNameValid = false;

  // Flow tracking
  String? _pendingJoinCode;
  String? _pendingHouseName;
  String? _pendingFlowType; // 'solo', 'arena', or 'join'

  late OnboardingBloc _onboardingBloc;

  @override
  void initState() {
    super.initState();
    _onboardingBloc = widget.onboardingBloc;
    _selectedAvatarId =
        DateTime.now().millisecondsSinceEpoch % totalAvatars + 1;

    // Pre-fill name from Sign-In data (Apple/Google)
    _prefillName();

    _nameController.addListener(() {
      setState(() => _isNameValid = _nameController.text.trim().isNotEmpty);
    });
    _houseNameController.addListener(() {
      setState(
        () => _isHouseNameValid = _houseNameController.text.trim().isNotEmpty,
      );
    });
  }

  /// Pre-fills the name field from Sign-In data.
  /// Priority: initialName > email local part
  void _prefillName() {
    String? prefillValue;

    // Try to use the display name from Sign-In
    if (widget.initialName != null && widget.initialName!.trim().isNotEmpty) {
      prefillValue = widget.initialName!.trim();
    }
    // Fallback: extract local part from email (part before @)
    else if (widget.email != null && widget.email!.contains('@')) {
      prefillValue = widget.email!.split('@').first;
    }

    if (prefillValue != null && prefillValue.isNotEmpty) {
      _nameController.text = prefillValue;
      _isNameValid = true;
    }
  }

  @override
  void dispose() {
    _onboardingBloc.close();
    _pageController.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    _houseNameController.dispose();
    _houseNameFocusNode.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0 && !_isNameValid) {
      _showError(AppLocalizations.of(context)!.pleaseEnterDisplayName);
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
    _pendingFlowType = 'solo';
    _pendingHouseName = '${_nameController.text.trim()}\'s Space';
    _onboardingBloc.add(
      UpdateProfile(
        displayName: _nameController.text.trim(),
        avatarId: _selectedAvatarId,
      ),
    );
  }

  void _showArenaBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ArenaBottomSheet(
        houseNameController: _houseNameController,
        houseNameFocusNode: _houseNameFocusNode,
        isHouseNameValid: _isHouseNameValid,
        onCreateArena: _createArena,
      ),
    ).then((_) {
      _houseNameController.clear();
      setState(() => _isHouseNameValid = false);
    });
  }

  void _createArena() {
    Navigator.of(context).pop();
    _pendingFlowType = 'arena';
    _pendingHouseName = _houseNameController.text.trim();
    _onboardingBloc.add(
      UpdateProfile(
        displayName: _nameController.text.trim(),
        avatarId: _selectedAvatarId,
      ),
    );
  }

  void _showJoinCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => JoinCodeDialog(
        nameController: _nameController,
        selectedAvatarId: _selectedAvatarId,
        onJoin: (displayName, avatarId, code) {
          _pendingFlowType = 'join';
          _pendingJoinCode = code;
          _onboardingBloc.add(
            UpdateProfile(displayName: displayName, avatarId: avatarId),
          );
        },
      ),
    );
  }

  void _showSuccessAndNavigate(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessDialog(message: message),
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
          if (state is OnboardingProfileUpdated) {
            // After profile update, proceed with flow
            if (_pendingFlowType == 'solo' && _pendingHouseName != null) {
              _onboardingBloc.add(
                CreateSoloHouse(houseName: _pendingHouseName!),
              );
            } else if (_pendingFlowType == 'arena' &&
                _pendingHouseName != null) {
              _onboardingBloc.add(
                CreateArenaHouse(houseName: _pendingHouseName!),
              );
            } else if (_pendingFlowType == 'join' && _pendingJoinCode != null) {
              _onboardingBloc.add(JoinHouse(code: _pendingJoinCode!));
            }
            _pendingFlowType = null;
            _pendingHouseName = null;
            _pendingJoinCode = null;
          } else if (state is OnboardingSuccess) {
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
                      // Header with indicators
                      OnboardingHeader(
                        currentPage: _currentPage,
                        totalPages: _totalPages,
                        isDark: isDark,
                        onBackPressed: _currentPage > 0 ? _prevPage : null,
                      ),

                      // Pages
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (index) {
                            setState(() => _currentPage = index);
                          },
                          children: [
                            // Page 1: Avatar
                            AvatarPage(
                              isDark: isDark,
                              textColor: textColor,
                              selectedAvatarId: _selectedAvatarId,
                              totalAvatars: totalAvatars,
                              nameController: _nameController,
                              nameFocusNode: _nameFocusNode,
                              isNameValid: _isNameValid,
                              onAvatarSelected: (avatarId) {
                                setState(() => _selectedAvatarId = avatarId);
                              },
                            ),

                            // Page 2: Create Space
                            CreateSpacePage(
                              isDark: isDark,
                              textColor: textColor,
                              isLoading: isLoading,
                              onCreateSoloHouse: _createSoloHouse,
                              onShowArenaBottomSheet: _showArenaBottomSheet,
                              onShowJoinCodeDialog: _showJoinCodeDialog,
                            ),
                          ],
                        ),
                      ),

                      // Footer spacing (only on first page where button shows)
                      SizedBox(height: _currentPage == 0 ? 100 : 0),
                    ],
                  ),

                  // Footer Button (only on first page)
                  if (_currentPage == 0)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: OnboardingFooterButton(
                        isEnabled: _isNameValid,
                        onPressed: _nextPage,
                        backgroundColor: bgColor,
                      ),
                    ),

                  // Loading Overlay
                  if (isLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.5),
                        child: const Center(child: CircularProgressIndicator()),
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
}
