import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from '../../prisma/prisma.service';
import { NotificationsService } from './notifications.service';
import { NotificationType, NotificationPriority } from '@prisma/client';

@Injectable()
export class LeaderboardNotificationService {
  private readonly logger = new Logger(
    LeaderboardNotificationService.name,
  );

  constructor(
    private readonly prisma: PrismaService,
    private readonly notificationsService: NotificationsService,
  ) {}

  /**
   * Check leaderboard rank changes daily at 21:00 (Asia/Bangkok).
   * Compares current monthly points rank vs stored rank.
   */
  @Cron('0 21 * * *', { timeZone: 'Asia/Bangkok' })
  async checkLeaderboardChanges(): Promise<void> {
    this.logger.log('Starting daily leaderboard rank check');

    try {
      // Get all non-personal houses
      const houses = await this.prisma.house.findMany({
        where: { isPersonal: false },
        include: {
          members: {
            select: {
              id: true,
              displayName: true,
              leaderboardRank: true,
            },
          },
        },
      });

      let totalNotifications = 0;

      for (const house of houses) {
        if (house.members.length < 2) continue;

        // Calculate current month's point totals per member
        const startOfMonth = new Date();
        startOfMonth.setDate(1);
        startOfMonth.setHours(0, 0, 0, 0);

        const memberPoints = await this.prisma.activity.groupBy({
          by: ['userId'],
          where: {
            houseId: house.id,
            completedAt: { gte: startOfMonth },
          },
          _sum: { pointsEarned: true },
        });

        // Build sorted rank list
        const pointsMap = new Map(
          memberPoints.map((mp) => [
            mp.userId,
            mp._sum.pointsEarned || 0,
          ]),
        );

        const rankedMembers = house.members
          .map((m) => ({
            ...m,
            points: pointsMap.get(m.id) || 0,
          }))
          .sort((a, b) => b.points - a.points);

        // Assign rank (1-based) and notify changes
        for (let i = 0; i < rankedMembers.length; i++) {
          const member = rankedMembers[i];
          const newRank = i + 1;
          const oldRank = member.leaderboardRank;

          // Update stored rank
          await this.prisma.user.update({
            where: { id: member.id },
            data: { leaderboardRank: newRank },
          });

          // Skip if no previous rank or rank unchanged
          if (oldRank === null || oldRank === newRank) continue;

          const rankImproved = newRank < oldRank;

          await this.notificationsService.createNotification({
            userId: member.id,
            type: NotificationType.LEADERBOARD_CHANGE,
            priority: rankImproved
              ? NotificationPriority.MEDIUM
              : NotificationPriority.LOW,
            title: rankImproved
              ? `📈 Bạn đã lên hạng ${newRank}!`
              : `📉 Bạn tụt xuống hạng ${newRank}`,
            body: rankImproved
              ? `Từ #${oldRank} → #${newRank} trong house ${house.name} 🎉`
              : `Hãy tập nhiều hơn để lấy lại vị trí trong ${house.name}! 💪`,
            data: {
              houseId: house.id,
              oldRank: String(oldRank),
              newRank: String(newRank),
            },
            actionUrl: 'ergolife://house',
            sendPush: rankImproved,
          });

          totalNotifications++;
        }
      }

      this.logger.log(
        `Leaderboard check completed: ${totalNotifications} rank change notifications sent`,
      );
    } catch (error) {
      this.logger.error(
        `Leaderboard check failed: ${error.message}`,
        error.stack,
      );
    }
  }
}
