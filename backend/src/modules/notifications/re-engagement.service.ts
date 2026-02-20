import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { PrismaService } from '../../prisma/prisma.service';
import { NotificationsService } from './notifications.service';
import { NotificationType } from '@prisma/client';

/// Progressive messaging tiers based on idle duration.
interface MessageTier {
  minDays: number;
  maxDays: number;
  priority: 'LOW' | 'MEDIUM' | 'HIGH';
  getTitleAndBody: (
    userName: string,
    idleDays: number,
    socialProof?: string,
  ) => { title: string; body: string };
}

@Injectable()
export class ReEngagementService {
  private readonly logger = new Logger(ReEngagementService.name);

  /// Minimum days between re-engagement pushes for a user.
  private readonly FREQUENCY_CAP_DAYS = 3;

  /// Stop sending after this many idle days (respect user).
  private readonly MAX_IDLE_DAYS = 30;

  /// Message tiers — progressive urgency.
  private readonly tiers: MessageTier[] = [
    {
      minDays: 2,
      maxDays: 3,
      priority: 'MEDIUM',
      getTitleAndBody: (_name, days) => {
        const messages = [
          {
            title: `💚 Hôm nay nghỉ ngơi à?`,
            body: 'Chỉ 5 phút thôi cũng đủ để giữ thói quen nhé!',
          },
          {
            title: `🌱 ${days} ngày rồi chưa tập!`,
            body: 'Một bài tập nhỏ hôm nay sẽ giúp bạn cảm thấy tốt hơn!',
          },
          {
            title: `⏰ Đã ${days} ngày trôi qua...`,
            body: 'Quay lại tập nhanh 1 bài nhé, body sẽ cảm ơn bạn!',
          },
        ];
        return messages[Math.floor(Math.random() * messages.length)];
      },
    },
    {
      minDays: 4,
      maxDays: 7,
      priority: 'MEDIUM',
      getTitleAndBody: (_name, days) => {
        const messages = [
          {
            title: `💪 ${days} ngày rồi đấy!`,
            body: 'Bạn đã từng kiên trì lắm mà! Quay lại nào!',
          },
          {
            title: `🔄 Đã gần 1 tuần...`,
            body: 'Streak cũ đã mất, nhưng streak mới bắt đầu từ HÔM NAY!',
          },
          {
            title: `📈 Mọi người đang tập chăm lắm!`,
            body: 'Đừng để mình bị bỏ lại phía sau nhé! 1 task thôi!',
          },
        ];
        return messages[Math.floor(Math.random() * messages.length)];
      },
    },
    {
      minDays: 8,
      maxDays: 14,
      priority: 'HIGH',
      getTitleAndBody: (_name, days, socialProof) => {
        const messages = [
          {
            title: `🔥 ${days} ngày không tập!`,
            body:
              socialProof ||
              'Bạn bè đang tập chăm lắm! Quay lại để không thua nhé!',
          },
          {
            title: `😢 ErgoLife nhớ bạn quá!`,
            body: 'Chỉ cần 1 session ngắn thôi là quay lại guồng rồi!',
          },
          {
            title: `🏃 Mọi người đang vượt mặt bạn!`,
            body:
              socialProof ||
              'Đừng để khoảng cách xa thêm. Quay lại hôm nay! 💪',
          },
        ];
        return messages[Math.floor(Math.random() * messages.length)];
      },
    },
    {
      minDays: 15,
      maxDays: 30,
      priority: 'HIGH',
      getTitleAndBody: (_name, _days) => {
        const messages = [
          {
            title: `🎁 Chào mừng trở lại!`,
            body: 'Quay lại tập hôm nay — mọi thứ vẫn đang chờ bạn!',
          },
          {
            title: `💎 Bạn có biết mình đã bỏ lỡ gì không?`,
            body: 'Nhiều thành tích đang chờ bạn mở khóa! Quay lại nào!',
          },
        ];
        return messages[Math.floor(Math.random() * messages.length)];
      },
    },
  ];

  constructor(
    private readonly prisma: PrismaService,
    private readonly notificationsService: NotificationsService,
  ) {}

  /**
   * Check for idle users daily at 10:00 Asia/Bangkok.
   * Sends progressive re-engagement notifications.
   */
  @Cron('0 10 * * *', { timeZone: 'Asia/Bangkok' })
  async sendReEngagementNotifications(): Promise<void> {
    this.logger.log('Starting daily re-engagement check');

    try {
      const now = new Date();
      const minIdleDate = new Date(
        now.getTime() - this.MAX_IDLE_DAYS * 24 * 60 * 60 * 1000,
      );
      const maxIdleDate = new Date(
        now.getTime() - 2 * 24 * 60 * 60 * 1000,
      );

      // Find users who haven't been active for 2-30 days
      const idleUsers = await this.prisma.user.findMany({
        where: {
          fcmToken: { not: null },
          lastActivityDate: {
            gte: minIdleDate,
            lte: maxIdleDate,
          },
        },
        select: {
          id: true,
          displayName: true,
          fcmToken: true,
          lastActivityDate: true,
          lastReminderSentAt: true,
          houseId: true,
        },
      });

      this.logger.log(
        `Found ${idleUsers.length} idle users (2-${this.MAX_IDLE_DAYS} days)`,
      );

      let sentCount = 0;
      let skippedCount = 0;

      for (const user of idleUsers) {
        try {
          // Frequency cap: skip if reminded within last N days
          if (this.wasRecentlyReminded(user.lastReminderSentAt)) {
            skippedCount++;
            continue;
          }

          const idleDays = this.getIdleDays(user.lastActivityDate!);
          const tier = this.getTierForIdleDays(idleDays);

          if (!tier) {
            skippedCount++;
            continue;
          }

          // Get social proof for 8-14 day lapsed users
          let socialProof: string | undefined;
          if (idleDays >= 8 && user.houseId) {
            socialProof = await this.getSocialProof(
              user.houseId,
              user.id,
            );
          }

          const { title, body } = tier.getTitleAndBody(
            user.displayName || 'bạn',
            idleDays,
            socialProof,
          );

          await this.notificationsService.createNotification({
            userId: user.id,
            type: NotificationType.RE_ENGAGEMENT,
            priority: tier.priority,
            title,
            body,
            data: {
              idleDays: String(idleDays),
              tier: `${tier.minDays}-${tier.maxDays}`,
            },
            actionUrl: 'ergolife://tasks',
            sendPush: true,
          });

          // Update last reminder timestamp
          await this.prisma.user.update({
            where: { id: user.id },
            data: { lastReminderSentAt: new Date() },
          });

          sentCount++;
        } catch (error) {
          this.logger.error(
            `Failed to send re-engagement to ${user.id}: ${error.message}`,
          );
        }
      }

      this.logger.log(
        `Re-engagement completed: ${sentCount} sent, ${skippedCount} skipped`,
      );
    } catch (error) {
      this.logger.error(
        `Re-engagement job failed: ${error.message}`,
        error.stack,
      );
    }
  }

  /// Check if user was reminded within the frequency cap.
  private wasRecentlyReminded(
    lastSentAt: Date | null,
  ): boolean {
    if (!lastSentAt) return false;

    const capMs =
      this.FREQUENCY_CAP_DAYS * 24 * 60 * 60 * 1000;
    return Date.now() - lastSentAt.getTime() < capMs;
  }

  /// Calculate idle days from last activity.
  private getIdleDays(lastActivityDate: Date): number {
    const ms = Date.now() - lastActivityDate.getTime();
    return Math.floor(ms / (24 * 60 * 60 * 1000));
  }

  /// Find the matching tier for idle days.
  private getTierForIdleDays(
    idleDays: number,
  ): MessageTier | undefined {
    return this.tiers.find(
      (t) => idleDays >= t.minDays && idleDays <= t.maxDays,
    );
  }

  /// Generate social proof message from housemates' activity.
  private async getSocialProof(
    houseId: string,
    userId: string,
  ): Promise<string | undefined> {
    try {
      const sevenDaysAgo = new Date(
        Date.now() - 7 * 24 * 60 * 60 * 1000,
      );

      const recentActivity = await this.prisma.activity.findFirst(
        {
          where: {
            houseId,
            userId: { not: userId },
            completedAt: { gte: sevenDaysAgo },
          },
          include: {
            user: { select: { displayName: true } },
          },
          orderBy: { completedAt: 'desc' },
        },
      );

      if (recentActivity) {
        const name =
          recentActivity.user.displayName || 'Thành viên';
        return `${name} vừa tập ${recentActivity.taskName}! Bạn không muốn thua chứ? 💪`;
      }

      return undefined;
    } catch {
      return undefined;
    }
  }
}
