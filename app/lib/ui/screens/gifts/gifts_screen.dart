import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:ergo_life_app/blocs/gifts/gifts_bloc.dart';
import 'package:ergo_life_app/blocs/gifts/gifts_event.dart';
import 'package:ergo_life_app/blocs/gifts/gifts_state.dart';
import 'package:ergo_life_app/data/models/gift_reward_model.dart';
import 'package:ergo_life_app/data/models/house_member_model.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';
import 'package:ergo_life_app/ui/screens/onboarding/widgets/avatar_helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Main gift catalog screen.
class GiftsScreen extends StatelessWidget {
  /// Optional member ID to pre-select when sending a gift.
  final String? preSelectedMemberId;

  const GiftsScreen({super.key, this.preSelectedMemberId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        surfaceTintColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 4,
        title: Text(
          'Gift Shop',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.history_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              tooltip: 'Gift History',
              onPressed: () => context.push(AppRouter.giftHistory),
            ),
          ),
        ],
      ),
      body: BlocConsumer<GiftsBloc, GiftsState>(
        listener: (context, state) {
          if (state is GiftSentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          } else if (state is GiftsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is GiftsLoading) {
            return _buildLoadingState(isDark);
          }

          if (state is GiftCatalogLoaded) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<GiftsBloc>().add(
                  LoadGiftCatalog(
                    locale: Localizations.localeOf(context).languageCode,
                  ),
                );
              },
              child: _GiftCatalogView(
                isDark: isDark,
                rewards: state.rewards,
                userBalance: state.userBalance,
                houseMembers: state.houseMembers,
                preSelectedMemberId: preSelectedMemberId,
              ),
            );
          }

          if (state is GiftsError) {
            return _buildErrorState(context, state.message, isDark);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Balance skeleton
          _buildSkeleton(double.infinity, 100, isDark),
          const SizedBox(height: 24),
          // Category header skeleton
          _buildSkeleton(180, 16, isDark),
          const SizedBox(height: 12),
          // Card skeletons
          _buildSkeleton(double.infinity, 80, isDark),
          const SizedBox(height: 10),
          _buildSkeleton(double.infinity, 80, isDark),
          const SizedBox(height: 10),
          _buildSkeleton(double.infinity, 80, isDark),
          const SizedBox(height: 24),
          _buildSkeleton(180, 16, isDark),
          const SizedBox(height: 12),
          _buildSkeleton(double.infinity, 80, isDark),
          const SizedBox(height: 10),
          _buildSkeleton(double.infinity, 80, isDark),
        ],
      ),
    );
  }

  Widget _buildSkeleton(double width, double height, bool isDark) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: AppColors.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<GiftsBloc>().add(
                LoadGiftCatalog(
                  locale: Localizations.localeOf(context).languageCode,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Catalog view with balance card and categorised rewards.
class _GiftCatalogView extends StatelessWidget {
  final bool isDark;
  final List<GiftRewardModel> rewards;
  final int userBalance;
  final List<HouseMemberModel> houseMembers;
  final String? preSelectedMemberId;

  const _GiftCatalogView({
    required this.isDark,
    required this.rewards,
    required this.userBalance,
    required this.houseMembers,
    this.preSelectedMemberId,
  });

  @override
  Widget build(BuildContext context) {
    final categories = <String, List<GiftRewardModel>>{};
    for (final r in rewards) {
      categories.putIfAbsent(r.category, () => []).add(r);
    }

    return AnimationLimiter(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            _BalanceCard(isDark: isDark, balance: userBalance),
            const SizedBox(height: 24),
            ...categories.entries.expand(
              (entry) => [
                _CategorySection(
                  isDark: isDark,
                  category: entry.key,
                  rewards: entry.value,
                  userBalance: userBalance,
                  houseMembers: houseMembers,
                  preSelectedMemberId: preSelectedMemberId,
                ),
                const SizedBox(height: 16),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

/// Balance card — matches CompactStatsBar pattern.
class _BalanceCard extends StatelessWidget {
  final bool isDark;
  final int balance;

  const _BalanceCard({required this.isDark, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative circle — top‑right
          Positioned(
            top: -25,
            right: -25,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Decorative circle — bottom‑left
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Wallet icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOUR BALANCE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$balance EP',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textMainDark
                              : AppColors.textMainLight,
                        ),
                      ),
                    ],
                  ),
                ),
                // Gift icon
                Text('🎁', style: const TextStyle(fontSize: 32)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Category section header + rewards list.
class _CategorySection extends StatelessWidget {
  final bool isDark;
  final String category;
  final List<GiftRewardModel> rewards;
  final int userBalance;
  final List<HouseMemberModel> houseMembers;
  final String? preSelectedMemberId;

  const _CategorySection({
    required this.isDark,
    required this.category,
    required this.rewards,
    required this.userBalance,
    required this.houseMembers,
    this.preSelectedMemberId,
  });

  (String label, String emoji) get _categoryInfo {
    return switch (category) {
      'PRAISE' => ('PRAISE & RECOGNITION', '🏅'),
      'PRIVILEGE' => ('FAMILY PRIVILEGES', '🎖️'),
      'EXPERIENCE' => ('FUN EXPERIENCES', '🎪'),
      'MOTIVATION' => ('MOTIVATION & SPIRIT', '💫'),
      _ => (category.toUpperCase(), '🎁'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (label, emoji) = _categoryInfo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header — matches QuickTasksSection
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${rewards.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSubDark
                      : AppColors.textSubLight,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Reward cards
        ...rewards.map(
          (reward) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _GiftRewardCard(
              isDark: isDark,
              reward: reward,
              canAfford: userBalance >= reward.cost,
              houseMembers: houseMembers,
              preSelectedMemberId: preSelectedMemberId,
            ),
          ),
        ),
      ],
    );
  }
}

/// Single gift reward card — matches TaskCard.
class _GiftRewardCard extends StatelessWidget {
  final bool isDark;
  final GiftRewardModel reward;
  final bool canAfford;
  final List<HouseMemberModel> houseMembers;
  final String? preSelectedMemberId;

  const _GiftRewardCard({
    required this.isDark,
    required this.reward,
    required this.canAfford,
    required this.houseMembers,
    this.preSelectedMemberId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canAfford && houseMembers.isNotEmpty
              ? () => _showSendGiftSheet(context)
              : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    reward.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                // Title + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textMainDark
                              : AppColors.textMainLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (reward.description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          reward.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSubDark
                                : AppColors.textSubLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // EP cost pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: canAfford
                        ? AppColors.secondary.withValues(alpha: 0.1)
                        : (isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.stars_rounded,
                        size: 14,
                        color: canAfford
                            ? AppColors.secondary
                            : (isDark
                                  ? AppColors.textSubDark
                                  : AppColors.textSubLight),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${reward.cost}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: canAfford
                              ? AppColors.secondary
                              : (isDark
                                    ? AppColors.textSubDark
                                    : AppColors.textSubLight),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSendGiftSheet(BuildContext context) {
    final bloc = context.read<GiftsBloc>();
    final messageController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Pre-select member by ID if provided,
    // otherwise default to first member.
    HouseMemberModel? selectedMember;
    if (preSelectedMemberId != null && houseMembers.isNotEmpty) {
      selectedMember = houseMembers.cast<HouseMemberModel?>().firstWhere(
        (m) => m?.id == preSelectedMemberId,
        orElse: () => houseMembers.first,
      );
    } else if (houseMembers.isNotEmpty) {
      selectedMember = houseMembers.first;
    }
    bool isSending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag indicator
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Gift preview card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.grey.shade800
                            : AppColors.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            reward.icon,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reward.name,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.textMainDark
                                      : AppColors.textMainLight,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${reward.cost} EP',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recipient label
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'SEND TO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Recipient chips
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: houseMembers.map((member) {
                        final isSelected = selectedMember == member;
                        return GestureDetector(
                          onTap: () {
                            setState(
                              () => selectedMember = isSelected ? null : member,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.15)
                                  : (isDark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade200),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Avatar
                                ClipOval(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CachedNetworkImage(
                                      imageUrl: getAvatarUrl(
                                        member.avatarId ?? 1,
                                      ),
                                      fit: BoxFit.cover,
                                      placeholder: (_, _) => Container(
                                        color: isDark
                                            ? Colors.grey.shade800
                                            : Colors.grey.shade200,
                                      ),
                                      errorWidget: (_, _, _) => Icon(
                                        Icons.person,
                                        size: 16,
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (isSelected)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                Text(
                                  member.displayName ?? 'Member',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark
                                              ? AppColors.textMainDark
                                              : AppColors.textMainLight),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Message field
                  TextField(
                    controller: messageController,
                    maxLength: 100,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textMainDark
                          : AppColors.textMainLight,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add a message (optional)',
                      hintStyle: TextStyle(
                        color: isDark
                            ? AppColors.textSubDark
                            : AppColors.textSubLight,
                      ),
                      prefixIcon: Icon(
                        Icons.message_outlined,
                        color: isDark
                            ? AppColors.textSubDark
                            : AppColors.textSubLight,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      counterStyle: TextStyle(
                        color: isDark
                            ? AppColors.textSubDark
                            : AppColors.textSubLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Send button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: BlocListener<GiftsBloc, GiftsState>(
                      bloc: bloc,
                      listener: (context, listenState) {
                        if (listenState is GiftSentSuccess ||
                            listenState is GiftCatalogLoaded) {
                          Navigator.of(context).pop();
                        } else if (listenState is GiftsError) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: ElevatedButton(
                        onPressed: selectedMember != null && !isSending
                            ? () {
                                setState(() => isSending = true);
                                bloc.add(
                                  SendGift(
                                    giftRewardId: reward.id,
                                    receiverId: selectedMember!.id,
                                    message: messageController.text.isNotEmpty
                                        ? messageController.text
                                        : null,
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          disabledForegroundColor: isDark
                              ? AppColors.textSubDark
                              : AppColors.textSubLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: isSending
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.card_giftcard, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Send Gift · ${reward.cost} EP',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
