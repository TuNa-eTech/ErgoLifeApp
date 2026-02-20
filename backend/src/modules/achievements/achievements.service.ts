import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { NotificationType } from '@prisma/client';
import { BadgeResponseDto, BadgeListResponseDto } from './dto';

@Injectable()
export class AchievementsService {
  private readonly logger = new Logger(AchievementsService.name);

  constructor(private readonly prisma: PrismaService) {}

  /// Get all badges with earned/locked status for a user
  async getAllBadges(
    userId: string,
    locale: string = 'vi',
  ): Promise<BadgeListResponseDto> {
    const [badges, userBadges, stats] = await Promise.all([
      this.prisma.badgeDefinition.findMany({
        where: { isActive: true },
        include: {
          translations: { where: { locale } },
        },
        orderBy: { sortOrder: 'asc' },
      }),
      this.prisma.userBadge.findMany({
        where: { userId },
        select: { badgeId: true, unlockedAt: true },
      }),
      this.getUserStats(userId),
    ]);

    const earnedMap = new Map(
      userBadges.map((ub) => [ub.badgeId, ub.unlockedAt]),
    );

    const badgeResponses: BadgeResponseDto[] = badges.map((badge) => {
      const translation = badge.translations[0];
      const isEarned = earnedMap.has(badge.id);
      const currentValue = this.getCurrentValue(
        badge.conditionType,
        stats,
      );
      const progress = Math.min(
        currentValue / badge.conditionValue,
        1.0,
      );

      return {
        id: badge.id,
        code: badge.code,
        category: badge.category,
        icon: badge.icon,
        color: badge.color,
        rarity: badge.rarity,
        name: translation?.name ?? badge.code,
        description: translation?.description,
        isEarned,
        progress,
        unlockedAt: earnedMap.get(badge.id),
        conditionType: badge.conditionType,
        conditionValue: badge.conditionValue,
        currentValue,
      };
    });

    return {
      badges: badgeResponses,
      earnedCount: userBadges.length,
      totalCount: badges.length,
    };
  }

  /// Get only earned badges for a user
  async getMyBadges(
    userId: string,
    locale: string = 'vi',
  ): Promise<BadgeResponseDto[]> {
    const userBadges = await this.prisma.userBadge.findMany({
      where: { userId },
      include: {
        badge: {
          include: {
            translations: { where: { locale } },
          },
        },
      },
      orderBy: { unlockedAt: 'desc' },
    });

    return userBadges.map((ub) => {
      const badge = ub.badge;
      const translation = badge.translations[0];
      return {
        id: badge.id,
        code: badge.code,
        category: badge.category,
        icon: badge.icon,
        color: badge.color,
        rarity: badge.rarity,
        name: translation?.name ?? badge.code,
        description: translation?.description,
        isEarned: true,
        progress: 1.0,
        unlockedAt: ub.unlockedAt,
        conditionType: badge.conditionType,
        conditionValue: badge.conditionValue,
        currentValue: badge.conditionValue,
      };
    });
  }

  /// Evaluate all badge conditions and award new badges.
  /// Called fire-and-forget after each activity.
  async evaluateAndAward(userId: string): Promise<string[]> {
    try {
      const [badges, existingBadgeIds, stats] =
        await Promise.all([
          this.prisma.badgeDefinition.findMany({
            where: { isActive: true },
          }),
          this.prisma.userBadge
            .findMany({
              where: { userId },
              select: { badgeId: true },
            })
            .then((ubs) => new Set(ubs.map((ub) => ub.badgeId))),
          this.getUserStats(userId),
        ]);

      const newlyAwarded: string[] = [];

      for (const badge of badges) {
        if (existingBadgeIds.has(badge.id)) {
          continue;
        }

        const currentValue = this.getCurrentValue(
          badge.conditionType,
          stats,
        );

        if (currentValue >= badge.conditionValue) {
          await this.prisma.userBadge.create({
            data: { userId, badgeId: badge.id },
          });
          newlyAwarded.push(badge.code);

          // Send notification
          await this.prisma.notification
            .create({
              data: {
                userId,
                type: NotificationType.BADGE_UNLOCKED,
                title: `🏅 Badge Unlocked!`,
                body: `You earned the "${badge.code}" badge!`,
                data: {
                  badgeId: badge.id,
                  badgeCode: badge.code,
                  rarity: badge.rarity,
                },
              },
            })
            .catch((err) =>
              this.logger.warn(
                `Failed to create badge notification: ${err.message}`,
              ),
            );
        }
      }

      if (newlyAwarded.length > 0) {
        this.logger.log(
          `User ${userId} earned badges: ${newlyAwarded.join(', ')}`,
        );
      }

      return newlyAwarded;
    } catch (error) {
      this.logger.error(
        `Badge evaluation failed for user ${userId}: ${error.message}`,
      );
      return [];
    }
  }

  /// Aggregate user stats for badge condition evaluation
  private async getUserStats(userId: string) {
    const [user, activityAgg, perfectDays, latestActivity] =
      await Promise.all([
        this.prisma.user.findUnique({
          where: { id: userId },
          select: {
            currentStreak: true,
            longestStreak: true,
          },
        }),
        this.prisma.activity.aggregate({
          where: { userId },
          _sum: { pointsEarned: true },
          _count: { id: true },
        }),
        this.prisma.dailyGoal.count({
          where: { userId, isPerfectDay: true },
        }),
        this.prisma.activity.findFirst({
          where: { userId },
          orderBy: { completedAt: 'desc' },
          select: { pointsEarned: true },
        }),
      ]);

    return {
      currentStreak: user?.currentStreak ?? 0,
      longestStreak: user?.longestStreak ?? 0,
      totalEp: activityAgg._sum.pointsEarned ?? 0,
      totalActivities: activityAgg._count.id ?? 0,
      perfectDays,
      latestSessionEp: latestActivity?.pointsEarned ?? 0,
    };
  }

  /// Map conditionType to current progress value
  private getCurrentValue(
    conditionType: string,
    stats: Awaited<ReturnType<typeof this.getUserStats>>,
  ): number {
    switch (conditionType) {
      case 'streak':
        return Math.max(
          stats.currentStreak,
          stats.longestStreak,
        );
      case 'total_ep':
        return stats.totalEp;
      case 'total_activities':
        return stats.totalActivities;
      case 'perfect_days':
        return stats.perfectDays;
      case 'single_session_ep':
        return stats.latestSessionEp;
      default:
        return 0;
    }
  }
}
