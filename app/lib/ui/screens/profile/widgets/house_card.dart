import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/core/navigation/app_router.dart';
import 'package:ergo_life_app/data/models/house_model.dart';

/// Professional house card component for profile screen
class HouseCard extends StatelessWidget {
  final HouseModel? house;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const HouseCard({
    super.key,
    this.house,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingSkeleton(context);
    }

    if (house == null) {
      return _buildEmptyState(context);
    }

    return _buildHouseCard(context);
  }

  Widget _buildHouseCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayPoints = _calculateTodayPoints();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push(AppRouter.houseDetail),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.home_filled,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          house!.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          house!.isPersonal ? 'Personal House' : 'Team House',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  )
                ],
              ),
              
              const SizedBox(height: 20),

              // 2. Stats Block (Grouped)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context, 
                      '${house!.memberCount}', 
                      'Members', 
                      Icons.people_outline_rounded,
                      isDark,
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                    _buildStatItem(
                      context, 
                      '$todayPoints', 
                      'Today Pts', 
                      Icons.stars_outlined,
                      isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. Action Buttons
              Row(
                children: [
                   Expanded(
                    child: _buildPrimaryButton(
                      context, 
                      'Invite Member', 
                      Icons.person_add_outlined,
                      () => context.push(AppRouter.inviteMembers),
                      isDark,
                    ),
                   ),
                   if (house!.isPersonal) ...[
                     const SizedBox(width: 12),
                     Expanded(
                        child: _buildSecondaryButton(
                          context, 
                          'Join House', 
                          Icons.login_rounded,
                          () => context.push(AppRouter.joinHouse),
                          isDark,
                        ),
                     ),
                   ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, IconData icon, bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isDark ? AppColors.textSubDark : AppColors.textSubLight),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
              ),
            ),
          ],
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
    );
  }

  Widget _buildPrimaryButton(BuildContext context, String label, IconData icon, VoidCallback onTap, bool isDark) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, String label, IconData icon, VoidCallback onTap, bool isDark) {
    return OutlinedButton(
      onPressed: onTap,
       style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? Colors.white : AppColors.textMainLight,
        side: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: isDark ? Colors.white70 : AppColors.textSubLight),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      // Padding handled by parent
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.home_work_outlined, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Join a House',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Compete with friends & stay motivated',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                   onPressed: () => context.push(AppRouter.createHouse),
                   style: FilledButton.styleFrom(
                     backgroundColor: AppColors.secondary,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                   ),
                   child: const Text('Create'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                   onPressed: () => context.push(AppRouter.joinHouse),
                   style: OutlinedButton.styleFrom(
                     foregroundColor: AppColors.secondary,
                     side: const BorderSide(color: AppColors.secondary),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                   ),
                   child: const Text('Join'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
      ),
       child: Center(
         child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary),
       ),
    );
  }


  /// Calculate today's total points from all members
  /// Note: This is a placeholder - real implementation would need daily stats from backend
  int _calculateTodayPoints() {
    if (house?.members == null) return 0;

    // For now, just return a sum of weekly points divided by 7
    // TODO: Replace with actual daily stats when backend endpoint is available
    final weeklyTotal = house!.members!.fold<int>(
      0,
      (sum, member) => sum + member.weeklyPoints,
    );

    return (weeklyTotal / 7).round();
  }
}
