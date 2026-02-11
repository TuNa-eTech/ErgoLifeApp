import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:ergo_life_app/blocs/gifts/gifts_bloc.dart';
import 'package:ergo_life_app/blocs/gifts/gifts_event.dart';
import 'package:ergo_life_app/blocs/gifts/gifts_state.dart';
import 'package:ergo_life_app/data/models/gift_transaction_model.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';

/// Gift history screen showing sent and received gifts.
class GiftHistoryScreen extends StatefulWidget {
  const GiftHistoryScreen({super.key});

  @override
  State<GiftHistoryScreen> createState() => _GiftHistoryScreenState();
}

class _GiftHistoryScreenState extends State<GiftHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final type = switch (_tabController.index) {
      0 => null,
      1 => 'sent',
      2 => 'received',
      _ => null,
    };
    context.read<GiftsBloc>().add(LoadGiftHistory(type: type));
  }

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
          'Gift History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark
              ? AppColors.textSubDark
              : AppColors.textSubLight,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          dividerColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Sent'),
            Tab(text: 'Received'),
          ],
        ),
      ),
      body: BlocBuilder<GiftsBloc, GiftsState>(
        builder: (context, state) {
          if (state is GiftsLoading) {
            return _buildLoadingState(isDark);
          }

          if (state is GiftHistoryLoaded) {
            if (state.gifts.isEmpty) {
              return _buildEmptyState(isDark);
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                final type = switch (_tabController.index) {
                  0 => null,
                  1 => 'sent',
                  2 => 'received',
                  _ => null,
                };
                context.read<GiftsBloc>().add(LoadGiftHistory(type: type));
              },
              child: AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  itemCount: state.gifts.length,
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _GiftTransactionCard(
                              isDark: isDark,
                              transaction: state.gifts[index],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
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
        children: List.generate(
          5,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              width: double.infinity,
              height: 90,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard_rounded,
            size: 80,
            color: isDark
                ? AppColors.textSubDark.withValues(alpha: 0.3)
                : AppColors.textSubLight.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No gifts yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send your first gift to a family member!',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
            ),
          ),
        ],
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
              onPressed: () =>
                  context.read<GiftsBloc>().add(const LoadGiftHistory()),
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

/// Transaction card — matches TaskCard pattern.
class _GiftTransactionCard extends StatelessWidget {
  final bool isDark;
  final GiftTransactionModel transaction;

  const _GiftTransactionCard({required this.isDark, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimeAgo(transaction.createdAt);

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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Gift icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                transaction.rewardIcon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.rewardName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textMainDark
                          : AppColors.textMainLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        transaction.senderName ?? '?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textSubDark
                              : AppColors.textSubLight,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: AppColors.secondary,
                        ),
                      ),
                      Text(
                        transaction.receiverName ?? '?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textSubDark
                              : AppColors.textSubLight,
                        ),
                      ),
                    ],
                  ),
                  if (transaction.message != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '"${transaction.message}"',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSubDark.withValues(alpha: 0.8)
                            : AppColors.textSubLight.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // EP and time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.stars_rounded,
                        size: 12,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${transaction.pointsSpent}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textSubDark
                        : AppColors.textSubLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
