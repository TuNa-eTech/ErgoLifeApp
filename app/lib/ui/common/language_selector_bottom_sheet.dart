import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/blocs/locale/locale_cubit.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';

/// Reusable language selector bottom sheet.
///
/// Displays available languages in a modal bottom sheet with:
/// - Clean Material Design 3 style
/// - Selected state indicator
/// - Smooth animations
/// - Dark mode support
class LanguageSelectorBottomSheet extends StatelessWidget {
  const LanguageSelectorBottomSheet({super.key});

  /// Shows the language selector bottom sheet.
  ///
  /// Returns `true` if a language was selected, `false` otherwise.
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LanguageSelectorBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocale = Localizations.localeOf(context).languageCode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                children: [
                  Icon(
                    Icons.language_rounded,
                    size: 24,
                    color: isDark ? Colors.white : AppColors.textMainLight,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Select Language',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textMainLight,
                    ),
                  ),
                ],
              ),
            ),

            // Language options
            _LanguageOption(
              languageCode: 'en',
              languageName: 'English',
              languageNativeName: 'English',
              flag: '🇬🇧',
              isSelected: currentLocale == 'en',
              isDark: isDark,
              onTap: () async {
                await context.read<LocaleCubit>().setLocale(const Locale('en'));
                if (context.mounted) Navigator.of(context).pop(true);
              },
            ),

            _LanguageOption(
              languageCode: 'vi',
              languageName: 'Vietnamese',
              languageNativeName: 'Tiếng Việt',
              flag: '🇻🇳',
              isSelected: currentLocale == 'vi',
              isDark: isDark,
              onTap: () async {
                await context.read<LocaleCubit>().setLocale(const Locale('vi'));
                if (context.mounted) Navigator.of(context).pop(true);
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Single language option in the selector.
class _LanguageOption extends StatelessWidget {
  final String languageCode;
  final String languageName;
  final String languageNativeName;
  final String flag;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.languageCode,
    required this.languageName,
    required this.languageNativeName,
    required this.flag,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                      ? AppColors.primary.withOpacity(0.15)
                      : AppColors.primary.withOpacity(0.08))
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              // Flag
              Text(flag, style: const TextStyle(fontSize: 32)),

              const SizedBox(width: 16),

              // Language names
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageNativeName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textMainLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      languageName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white60 : AppColors.textSubLight,
                      ),
                    ),
                  ],
                ),
              ),

              // Selected indicator
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 16, color: Colors.white),
                )
              else
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.3)
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
