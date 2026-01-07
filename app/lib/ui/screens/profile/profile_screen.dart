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
import 'package:ergo_life_app/blocs/locale/locale_cubit.dart';
import 'package:ergo_life_app/l10n/app_localizations.dart';

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
        BlocProvider<HouseBloc>.value(value: sl<HouseBloc>()),
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
          // Navigate to login when logged out
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

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProfileBloc>().add(const RefreshProfile());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [AppColors.backgroundDark, AppColors.surfaceDark]
                      : [AppColors.backgroundLight, AppColors.surfaceLight],
                ),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.secondary, width: 3),
                      image: user.avatarUrl != null
                          ? DecorationImage(
                              image: NetworkImage(user.avatarUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: user.avatarUrl == null
                          ? Colors.grey.shade300
                          : null,
                    ),
                    child: user.avatarUrl == null
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  // Name
                  Text(
                    user.name ?? 'User',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textMainDark
                          : AppColors.textMainLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Level
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.memberSince(state.membershipDuration),
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Stats Cards
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          AppLocalizations.of(context)!.totalPoints,
                          '${stats.totalPoints}',
                          Icons.stars,
                          isDark,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          AppLocalizations.of(context)!.activities,
                          '${stats.totalActivities}',
                          Icons.fitness_center,
                          isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          AppLocalizations.of(context)!.durationStat,
                          '${stats.totalMinutes ~/ 60} hrs',
                          Icons.timer,
                          isDark,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          AppLocalizations.of(context)!.bestStreak,
                          '${stats.longestStreak} days',
                          Icons.local_fire_department,
                          isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // House Section
            // House section removed - not available in ProfileLoaded

            // Settings/Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildActionTile(AppLocalizations.of(context)!.editProfile, Icons.edit, () {
                    // TODO: Navigate to edit profile
                  }, isDark),
                  _buildActionTile(AppLocalizations.of(context)!.settings, Icons.settings, () {
                    // TODO: Navigate to settings
                  }, isDark),
                  // Language Switcher
                  BlocBuilder<LocaleCubit, Locale>(
                    builder: (context, locale) {
                      final currentLanguage = locale.languageCode == 'vi'
                          ? AppLocalizations.of(context)!.vietnamese
                          : AppLocalizations.of(context)!.english;
                      
                      return _buildLanguageTile(
                        AppLocalizations.of(context)!.language,
                        currentLanguage,
                        () => _showLanguageDialog(context, locale),
                        isDark,
                      );
                    },
                  ),
                  _buildActionTile(
                    AppLocalizations.of(context)!.leaveHouse,
                    Icons.exit_to_app,
                    () => _showLeaveHouseDialog(context),
                    isDark,
                    isDestructive: true,
                  ),
                  _buildActionTile(
                    AppLocalizations.of(context)!.logout,
                    Icons.logout,
                    () => _showLogoutDialog(context),
                    isDark,
                    isDestructive: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.secondary, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isDark, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : AppColors.secondary,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive
                ? Colors.red
                : (isDark ? AppColors.textMainDark : AppColors.textMainLight),
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLanguageTile(
    String title,
    String currentValue,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        ),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.language,
          color: AppColors.secondary,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentValue,
              style: TextStyle(
                color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

void _showLeaveHouseDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning, color: Colors.orange),
          SizedBox(width: 12),
          Text('Leave House?'),
        ],
      ),
      content: const Text(
        'You will lose all points and activity history in this house. '
        'Are you sure you want to leave?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            context.read<HouseBloc>().add(const LeaveHouse());
            Navigator.pop(ctx);
            // Navigate to create/join screen
            context.go(AppRouter.joinHouse);
          },
          child: const Text('Leave House', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
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
      content: Text(
        AppLocalizations.of(context)!.logoutConfirmation,
      ),
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
            const Icon(
              Icons.check_circle,
              color: AppColors.secondary,
            ),
        ],
      ),
    ),
  );
}
