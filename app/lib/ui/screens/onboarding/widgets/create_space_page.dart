import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/ui/screens/onboarding/widgets/personal_space_card.dart';
import 'package:ergo_life_app/ui/screens/onboarding/widgets/family_arena_card.dart';
import 'package:ergo_life_app/l10n/app_localizations.dart';

/// Page 2 of onboarding: Choose between personal space or family arena
class CreateSpacePage extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final bool isLoading;
  final VoidCallback onCreateSoloHouse;
  final VoidCallback onShowArenaBottomSheet;
  final VoidCallback onShowJoinCodeDialog;

  const CreateSpacePage({
    super.key,
    required this.isDark,
    required this.textColor,
    required this.isLoading,
    required this.onCreateSoloHouse,
    required this.onShowArenaBottomSheet,
    required this.onShowJoinCodeDialog,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          // Title
          Text(
            AppLocalizations.of(context)!.chooseYourJourney,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            AppLocalizations.of(context)!.onboardingSubtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
            ),
          ),
          const SizedBox(height: 20),

          // Personal Space Card
          PersonalSpaceCard(
            isDark: isDark,
            isLoading: isLoading,
            onPressed: onCreateSoloHouse,
          ),

          const SizedBox(height: 20),

          // Simple Divider with "OR"
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppLocalizations.of(context)!.or.toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSubDark
                        : AppColors.textSubLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),

          const SizedBox(height: 20),

          // Family Arena Card
          FamilyArenaCard(isDark: isDark, onPressed: onShowArenaBottomSheet),

          const SizedBox(height: 32),

          // Join Code Button
          Center(
            child: OutlinedButton.icon(
              onPressed: onShowJoinCodeDialog,
              icon: Icon(
                Icons.qr_code_scanner,
                size: 20,
                color: isDark ? AppColors.textMainDark : AppColors.primary,
              ),
              label: Text(
                AppLocalizations.of(context)!.haveInviteCode,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isDark ? AppColors.textMainDark : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark
                      ? AppColors.textSubDark.withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.3),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
