import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';

class RankScreen extends StatelessWidget {
  const RankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine theme mode for manual adjustments
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Main Scrollable Content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                _buildHeader(context, isDark),
                _buildPodium(context, isDark),
                _buildRunnersUp(context, isDark),
              ],
            ),
          ),
          // Gradient fade at bottom of list if needed or just padding
          // Floating Invite Button
          Positioned(bottom: 24, right: 24, child: _buildInviteButton(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
      child: Column(
        children: [
          // Top Row: Title & Search
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COMPETITION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: isDark
                          ? AppColors.textSubDark
                          : AppColors.textSubLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Leaderboard 🏆',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textMainDark
                          : AppColors.textMainLight,
                    ),
                  ),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1D2939).withOpacity(0.08),
                      offset: const Offset(0, 8),
                      blurRadius: 30,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.search),
                  color: isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight,
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Filter Toggle
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Friends',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    child: Text(
                      'Global',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSubDark
                            : AppColors.textSubLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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

  Widget _buildPodium(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Rank 2 (Left)
          Expanded(
            child: _buildPodiumItem(
              context,
              rank: 2,
              name: 'Alex K.',
              score: '2,150',
              avatar: '😎',
              color: Colors.grey,
              height: 140, // Reduced visual height relative to center
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 12),
          // Rank 1 (Center)
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -16), // Lift up slightly
              child: _buildPodiumItem(
                context,
                rank: 1,
                name: 'Sarah M.',
                score: '2,480',
                avatar: '🦊',
                color: AppColors.secondary,
                height: 170, // Tallest
                isDark: isDark,
                showCrown: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Rank 3 (Right)
          Expanded(
            child: _buildPodiumItem(
              context,
              rank: 3,
              name: 'Mike R.',
              score: '1,920',
              avatar: '🏋️',
              color: Colors.orange.shade300,
              height: 140, // Same as Rank 2
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    BuildContext context, {
    required int rank,
    required String name,
    required String score,
    required String avatar,
    required Color color,
    required double height,
    required bool isDark,
    bool showCrown = false,
  }) {
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark
        ? Colors.grey.shade800
        : Colors.white.withOpacity(0.5);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown for Rank 1
        if (showCrown)
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Icon(
              Icons.emoji_events,
              color: AppColors.secondary,
              size: 28,
            ),
          ),

        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Background Glow (Simulated with simple shadow/decoration for now)

            // Card
            Container(
              height: height,
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 24,
                left: 8,
                right: 8,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: showCrown ? AppColors.secondary : borderColor,
                  width: showCrown ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1D2939).withOpacity(0.08),
                    offset: const Offset(0, 8),
                    blurRadius: 30,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Avatar Space
                  const Spacer(),
                  // Name
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textMainDark
                          : AppColors.textMainLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Score
                  Text(
                    score,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.secondary,
                    ),
                  ),
                  if (showCrown) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'LEADER',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Floating Avatar
            Positioned(
              top: -24,
              child: Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(0.2), color.withOpacity(0.8)],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(avatar, style: const TextStyle(fontSize: 28)),
                ),
              ),
            ),

            // Rank Badge
            if (!showCrown)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    rank.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildRunnersUp(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Runners up',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildListItem(
            context,
            isDark,
            4,
            'Minh (You)',
            '1,240',
            'Rising fast',
            isMe: true,
          ),
          const SizedBox(height: 12),
          _buildListItem(
            context,
            isDark,
            5,
            'David Kim',
            '1,100',
            'Consistent',
            initials: 'DK',
            avatarColor: Colors.purple.shade100,
            textColor: Colors.purple,
          ),
          const SizedBox(height: 12),
          _buildListItem(
            context,
            isDark,
            6,
            'Jenny Lee',
            '1,050',
            'On fire 🔥',
            initials: 'JL',
            avatarColor: Colors.blue.shade100,
            textColor: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildListItem(
            context,
            isDark,
            7,
            'Marcus P.',
            '980',
            '',
            initials: 'MP',
            avatarColor: Colors.green.shade100,
            textColor: Colors.green,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    bool isDark,
    int rank,
    String name,
    String score,
    String status, {
    bool isMe = false,
    String? initials,
    Color? avatarColor,
    Color? textColor,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: isMe
            ? const Border(
                left: BorderSide(color: AppColors.secondary, width: 4),
              )
            : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D2939).withOpacity(0.08),
            offset: const Offset(0, 8),
            blurRadius: 30,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 30,
            child: Text(
              rank.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          if (isMe)
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.secondary, width: 2),
                    image: const DecorationImage(
                      image: NetworkImage(
                        "https://lh3.googleusercontent.com/aida-public/AB6AXuC8cNp4p9S10dVV67Ocu6pA2hPZErbqWTgHgdAUGn0CA4y4BT7VJJpsRUWf67jTFvA6Oxt3wcI0Dk6AD2SquLO8RMX5oJOPRSmj7xpeXcuCQAzoL-YGBBaFOIcSRiPdU67QgnwyPF20TDuOxyBvcG8gZzNLc_U0qhllkVaoRE40AULggtrgvwOJU9nH4_SuoGnzj3zWc5zVws0VRdT7gTN5XTHQOMWF9N2Md2IMyZC6PvdjaamVIdDc_34LYL78G9ZvglhtRkrH4bU",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'YOU',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: avatarColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                initials ?? '',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMe ? 16 : 14,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
                if (status.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isMe)
                          const Icon(
                            Icons.arrow_drop_up,
                            color: Colors.green,
                            size: 16,
                          ),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSubDark
                                : AppColors.textSubLight,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: isMe
                      ? AppColors.secondary
                      : (isDark
                            ? AppColors.textMainDark
                            : AppColors.textMainLight),
                ),
              ),
              const Text(
                'EP',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSubLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInviteButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 8),
            blurRadius: 20,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Material(
        color: AppColors.textMainLight,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 20, 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Invite',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
