import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/core/di/service_locator.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';
import 'package:ergo_life_app/blocs/profile/profile_bloc.dart';
import 'package:ergo_life_app/blocs/profile/profile_event.dart';
import 'package:ergo_life_app/blocs/profile/profile_state.dart';
import 'package:ergo_life_app/blocs/auth/auth_bloc.dart';
import 'package:ergo_life_app/blocs/auth/auth_event.dart';
import 'package:ergo_life_app/blocs/auth/auth_state.dart';
import 'package:ergo_life_app/blocs/house/house_bloc.dart';
import 'package:ergo_life_app/blocs/house/house_event.dart';
import 'package:ergo_life_app/blocs/house/house_state.dart';
import 'package:ergo_life_app/blocs/locale/locale_cubit.dart';
import 'package:ergo_life_app/l10n/app_localizations.dart';
import 'package:ergo_life_app/ui/screens/profile/widgets/house_card.dart';
import 'package:ergo_life_app/ui/screens/profile/widgets/activity_heatmap.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>(
          create: (_) => sl<ProfileBloc>()..add(const LoadProfile()),
        ),
        BlocProvider<AuthBloc>.value(value: sl<AuthBloc>()),
        BlocProvider<HouseBloc>(
          create: (_) => sl<HouseBloc>()..add(const LoadHouse()),
        ),
      ],
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(AppRouter.login);
        }
      },
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'Retry',
                    textColor: Colors.white,
                    onPressed: () =>
                        context.read<ProfileBloc>().add(const LoadProfile()),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileError) {
              return _buildErrorState(context, state.message, isDark);
            }

            if (state is ProfileLoaded) {
              return _buildLoadedState(context, state, isDark);
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: isDark ? Colors.red.shade300 : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.failedToLoadProfile,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<ProfileBloc>().add(const LoadProfile()),
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(
    BuildContext context,
    ProfileLoaded state,
    bool isDark,
  ) {
    final user = state.user;
    final stats = state.stats;

    return Column(
      children: [
        _buildModernHeader(context, user, state.membershipDuration, isDark),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<ProfileBloc>().add(const RefreshProfile());
              await Future.delayed(const Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    _buildUnifiedStatsCard(context, stats, isDark),
                    
                    const SizedBox(height: 20),
                  BlocBuilder<HouseBloc, HouseState>(
                    builder: (context, houseState) {
                      if (houseState is HouseLoading) {
                        return const HouseCard(isLoading: true);
                      } else if (houseState is HouseLoaded) {
                        return HouseCard(
                          house: houseState.house,
                          onRefresh: () {
                            context.read<HouseBloc>().add(const LoadHouse());
                          },
                        );
                      }
                      return const HouseCard();
                    },
                  ),

                    const SizedBox(height: 20),
                    ActivityHeatmap(isDark: isDark, days: 14),

                    const SizedBox(height: 20),
                    _buildSettingsGroup(context, isDark),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernHeader(
    BuildContext context,
    dynamic user,
    String membershipDuration,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 15,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondary, width: 2),
              image: user.avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(user.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
            child: user.avatarUrl == null
                ? Icon(Icons.person, size: 28, color: isDark ? Colors.white54 : Colors.grey.shade400)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.name ?? 'User',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
                Text(
                   AppLocalizations.of(context)!.memberSince(membershipDuration),
                   style: TextStyle(
                     color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
                     fontSize: 12,
                   ),
                ),
              ],
            ),
          ),
          IconButton(
             onPressed: () {
               // Quick edit or share action
             },
             icon: Icon(
               Icons.qr_code_rounded, 
               color: isDark ? AppColors.textSubDark : AppColors.textMainLight
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedStatsCard(BuildContext context, dynamic stats, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildCompactStatItem(
              context,
              AppLocalizations.of(context)!.totalPoints,
              '${stats.totalPoints}',
              Icons.stars_rounded,
              Colors.amber,
              isDark,
            ),
          ),
          _buildVerticalDivider(isDark),
          Expanded(
            child: _buildCompactStatItem(
              context,
              AppLocalizations.of(context)!.activities,
              '${stats.totalActivities}',
              Icons.fitness_center_rounded,
              Colors.blue,
              isDark,
            ),
          ),
          _buildVerticalDivider(isDark),
          Expanded(
            child: _buildCompactStatItem(
              context,
              AppLocalizations.of(context)!.durationStat,
              '${stats.totalMinutes ~/ 60}h',
              Icons.timer_rounded,
              Colors.purple,
              isDark,
            ),
          ),
          _buildVerticalDivider(isDark),
          Expanded(
            child: _buildCompactStatItem(
              context,
              AppLocalizations.of(context)!.bestStreak,
              '${stats.longestStreak}d',
              Icons.local_fire_department_rounded,
              Colors.orange,
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      height: 32,
      width: 1,
      color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2),
    );
  }

  Widget _buildCompactStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
    bool isDark,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
         boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
           _buildSettingsTile(
            context,
            AppLocalizations.of(context)!.editProfile,
            Icons.edit_rounded,
            () {},
            isDark,
          ),
          _buildDivider(isDark),
           _buildSettingsTile(
            context,
            AppLocalizations.of(context)!.settings,
            Icons.settings_rounded,
            () {},
            isDark,
          ),
          _buildDivider(isDark),
           BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              final currentLanguage = locale.languageCode == 'vi'
                  ? AppLocalizations.of(context)!.vietnamese
                  : AppLocalizations.of(context)!.english;
              return _buildSettingsTile(
                context,
                AppLocalizations.of(context)!.language,
                Icons.language_rounded,
                () => _showLanguageDialog(context, locale),
                isDark,
                trailingText: currentLanguage,
              );
            },
          ),
           _buildDivider(isDark),
           _buildSettingsTile(
            context,
            AppLocalizations.of(context)!.logout,
            Icons.logout_rounded,
            () => _showLogoutDialog(context),
            isDark,
            isDestructive: true,
            showChevron: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isDark, {
    bool isDestructive = false,
    String? trailingText,
    bool showChevron = true,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive 
              ? Colors.red.withValues(alpha: 0.1) 
              : AppColors.backgroundLight,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDestructive ? Colors.red : AppColors.textSubLight,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDestructive
              ? Colors.red
              : (isDark ? AppColors.textMainDark : AppColors.textMainLight),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
              ),
            ),
          if (showChevron) ...[
            if (trailingText != null) const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 60,
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
    );
  }
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.logout, color: Colors.red),
          const SizedBox(width: 12),
          Text(AppLocalizations.of(context)!.logout),
        ],
      ),
      content: Text(AppLocalizations.of(context)!.logoutConfirmation),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            context.read<AuthBloc>().add(const AuthSignOutRequested());
          },
          child: Text(
            AppLocalizations.of(context)!.logout,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}

void _showLanguageDialog(BuildContext context, Locale currentLocale) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.language, color: AppColors.secondary),
          const SizedBox(width: 12),
          Text(AppLocalizations.of(context)!.language),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageOption(
            context: context,
            ctx: ctx,
            languageCode: 'en',
            languageName: AppLocalizations.of(context)!.english,
            isSelected: currentLocale.languageCode == 'en',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildLanguageOption(
            context: context,
            ctx: ctx,
            languageCode: 'vi',
            languageName: AppLocalizations.of(context)!.vietnamese,
            isSelected: currentLocale.languageCode == 'vi',
            isDark: isDark,
          ),
        ],
      ),
    ),
  );
}

Widget _buildLanguageOption({
  required BuildContext context,
  required BuildContext ctx,
  required String languageCode,
  required String languageName,
  required bool isSelected,
  required bool isDark,
}) {
  return InkWell(
    onTap: () {
      context.read<LocaleCubit>().setLocale(Locale(languageCode));
      Navigator.pop(ctx);
    },
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.secondary.withValues(alpha: 0.1)
            : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColors.secondary
              : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            languageName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? AppColors.secondary
                  : (isDark ? AppColors.textMainDark : AppColors.textMainLight),
            ),
          ),
          const Spacer(),
          if (isSelected)
            const Icon(Icons.check_circle, color: AppColors.secondary),
        ],
      ),
    ),
  );
}
