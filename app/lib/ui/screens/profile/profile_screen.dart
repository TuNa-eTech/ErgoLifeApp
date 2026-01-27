import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:ergo_life_app/data/models/user_model_extensions.dart';
import 'package:ergo_life_app/ui/screens/profile/widgets/house_card.dart';
import 'package:ergo_life_app/ui/common/common.dart';
import 'package:ergo_life_app/ui/screens/stats/task_stats_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileBloc _profileBloc;
  late final HouseBloc _houseBloc;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize BLoCs but don't add events yet
    _profileBloc = sl<ProfileBloc>();
    _houseBloc = sl<HouseBloc>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // Initial load
      _profileBloc.add(const LoadProfile());
      _houseBloc.add(const LoadHouse());
      _isInitialized = true;
    } else {
      // Refresh when coming back (e.g., from EditProfileScreen)
      _profileBloc.add(const RefreshProfile());
      _houseBloc.add(const LoadHouse());
    }
  }

  @override
  void dispose() {
    // Don't close BLoCs - ProfileScreen is kept alive in StatefulShellRoute
    // Closing them causes "Cannot add events after close" errors
    // when navigating between tabs or coming back from EditProfileScreen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>.value(value: _profileBloc),
        BlocProvider<AuthBloc>.value(value: sl<AuthBloc>()),
        BlocProvider<HouseBloc>.value(value: _houseBloc),
      ],
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
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
              return _buildSkeletonState(context, isDark);
            }

            if (state is ProfileError) {
              return _buildErrorState(context, state.message, isDark);
            }

            if (state is ProfileLoaded) {
              return _buildLoadedState(context, state, isDark);
            }

            return _buildSkeletonState(context, isDark);
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

  Widget _buildSkeletonState(BuildContext context, bool isDark) {
    return Column(
      children: [
        const ProfileHeaderSkeleton(),
        Expanded(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  const StatsCardSkeleton(),
                  const SizedBox(height: 20),
                  const HouseCard(isLoading: true),
                  const SizedBox(height: 20),
                  _buildSettingsGroup(context, isDark),
                ],
              ),
            ),
          ),
        ),
      ],
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
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
              image: getUserAvatarUrl(user) != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(
                        getUserAvatarUrl(user)!,
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
            child: getUserAvatarUrl(user) == null
                ? Icon(
                    Icons.person,
                    size: 28,
                    color: isDark ? Colors.white54 : Colors.grey.shade400,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.name ?? 'User',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedStatsCard(
    BuildContext context,
    dynamic stats,
    bool isDark,
  ) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TaskStatsScreen()),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
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
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      height: 32,
      width: 1,
      color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.grey.withValues(alpha: 0.2),
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
            () => context.push(AppRouter.editProfile),
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
                () => LanguageSelectorBottomSheet.show(context),
                isDark,
                trailingText: currentLanguage,
              );
            },
          ),
          _buildDivider(isDark),
          _buildSettingsTile(
            context,
            AppLocalizations.of(context)!.termsOfService,
            Icons.description_rounded,
            () => context.push(AppRouter.termsOfService),
            isDark,
          ),
          _buildDivider(isDark),
          _buildSettingsTile(
            context,
            AppLocalizations.of(context)!.privacyPolicy,
            Icons.privacy_tip_rounded,
            () => context.push(AppRouter.privacyPolicy),
            isDark,
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
          _buildDivider(isDark),
          // Delete Account - Small and subtle at the bottom
          SizedBox(height: 30),
          _buildDeleteAccountTile(context, isDark),
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

  Widget _buildDeleteAccountTile(BuildContext context, bool isDark) {
    return InkWell(
      onTap: () => _showDeleteAccountDialog(context),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline,
              size: 14,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
            ),
            const SizedBox(width: 6),
            Text(
              AppLocalizations.of(context)!.deleteAccount,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showLogoutDialog(BuildContext context) async {
  final confirmed = await ModernDialog.showConfirmation(
    context,
    title: AppLocalizations.of(context)!.logout,
    message: AppLocalizations.of(context)!.logoutConfirmation,
    confirmText: AppLocalizations.of(context)!.logout,
    cancelText: AppLocalizations.of(context)!.cancel,
    isDestructive: true,
  );

  if (confirmed && context.mounted) {
    context.read<AuthBloc>().add(const AuthSignOutRequested());
  }
}

Future<void> _showDeleteAccountDialog(BuildContext context) async {
  final confirmed = await ModernDialog.showConfirmation(
    context,
    title: AppLocalizations.of(context)!.deleteAccount,
    message: AppLocalizations.of(context)!.deleteAccountConfirmation,
    confirmText: AppLocalizations.of(context)!.deleteAccount,
    cancelText: AppLocalizations.of(context)!.cancel,
    isDestructive: true,
  );

  if (confirmed && context.mounted) {
    context.read<AuthBloc>().add(const AuthDeleteAccountRequested());
  }
}
