import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from '../../prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { NotificationType } from '@prisma/client';

@Injectable()
export class StreakReminderService {
  private readonly logger = new Logger(StreakReminderService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly notificationsService: NotificationsService,
  ) {}

  /**
   * Send personalized streak reminders based on user's activity patterns
   * Runs every hour to check if any user needs reminder at this hour
   * Cron format: second minute hour day month dayOfWeek
   * '0 0 * * * *' = Every hour at :00
   */
  @Cron('0 0 * * * *', {
    timeZone: 'Asia/Bangkok', // GMT+7
  })
  async sendPersonalizedStreakReminders() {
    const now = new Date();
    const currentHour = now.getHours();
    
    this.logger.log(`Checking for personalized reminders at hour: ${currentHour}`);

    try {
      // Find users who should receive reminder at this hour
      const usersToRemind = await this.findUsersForHourlyReminder(currentHour);
      
      this.logger.log(`Found ${usersToRemind.length} users to potentially remind`);

      let sentCount = 0;
      let skippedCount = 0;
      let failureCount = 0;

      for (const user of usersToRemind) {
        try {
          // Skip if user has no FCM token
          if (!user.fcmToken) {
            this.logger.debug(`Skipping user ${user.id} - no FCM token`);
            skippedCount++;
            continue;
          }

          // Skip if user has no current streak AND hasn't been
          // active recently (let ReEngagementService handle them)
          if (user.currentStreak === 0) {
            const sevenDaysAgo = new Date(
              Date.now() - 7 * 24 * 60 * 60 * 1000,
            );
            const isRecentlyLapsed =
              user.lastActivityDate &&
              user.lastActivityDate >= sevenDaysAgo;

            if (!isRecentlyLapsed) {
              this.logger.debug(
                `Skipping user ${user.id} - no streak and not recently active`,
              );
              skippedCount++;
              continue;
            }
          }

          // Skip if user already completed activity today
          if (user.activities.length > 0) {
            this.logger.debug(`Skipping user ${user.id} - already active today`);
            skippedCount++;
            continue;
          }

          // Skip if reminder already sent today
          if (this.wasReminderSentToday(user.lastReminderSentAt)) {
            this.logger.debug(`Skipping user ${user.id} - reminder already sent today`);
            skippedCount++;
            continue;
          }

          // Send personalized reminder
          await this.notificationsService.createNotification({
            userId: user.id,
            type: NotificationType.STREAK_REMINDER,
            title: this.getStreakReminderTitle(user.currentStreak),
            body: this.getStreakReminderBody(user.currentStreak),
            priority: user.currentStreak >= 7 ? 'HIGH' : 'MEDIUM',
            data: {
              streak: String(user.currentStreak),
              longestStreak: String(user.longestStreak),
              type: 'streak_reminder',
              personalized: user.preferredReminderTime ? 'true' : 'false',
            },
            actionUrl: 'ergolife://tasks',
            sendPush: true,
          });

          // Update last reminder sent timestamp
          await this.prisma.user.update({
            where: { id: user.id },
            data: { lastReminderSentAt: now },
          });

          sentCount++;
          this.logger.debug(
            `Sent personalized reminder to user ${user.id} (streak: ${user.currentStreak}, hour: ${currentHour})`,
          );
        } catch (error) {
          failureCount++;
          this.logger.error(`Failed to send reminder to user ${user.id}: ${error.message}`);
        }
      }

      this.logger.log(
        `Hourly reminder job completed: ${sentCount} sent, ${skippedCount} skipped, ${failureCount} failed`,
      );
    } catch (error) {
      this.logger.error(`Hourly reminder job failed: ${error.message}`, error.stack);
    }
  }

  /**
   * Find users who should receive reminder at the current hour
   * Includes both users with learned preferences and fallback users
   */
  private async findUsersForHourlyReminder(currentHour: number) {
    const startOfHour = new Date();
    startOfHour.setMinutes(0, 0, 0);

    const endOfHour = new Date();
    endOfHour.setMinutes(59, 59, 999);

    const startOfToday = this.getStartOfToday();
    const endOfToday = this.getEndOfToday();

    const sevenDaysAgo = new Date(
      Date.now() - 7 * 24 * 60 * 60 * 1000,
    );

    // Build where clause for users to remind.
    // Include active streakers OR recently lapsed users.
    const whereConditions: any = {
      fcmToken: { not: null },
      OR: [
        // Active streakers
        {
          currentStreak: { gt: 0 },
          OR: [] as any[],
        },
        // Recently lapsed (streak=0 but active within 7 days)
        {
          currentStreak: 0,
          lastActivityDate: { gte: sevenDaysAgo },
          OR: [] as any[],
        },
      ],
    };

    // Condition 1: Users with learned preference matching this hour
    const preferenceCondition = {
      preferredReminderTime: {
        gte: startOfHour,
        lte: endOfHour,
      },
    };

    // Add preference condition to both branches
    whereConditions.OR[0].OR.push(preferenceCondition);
    whereConditions.OR[1].OR.push(preferenceCondition);

    // Condition 2: Fallback - users without preference at 20:00
    if (currentHour === 20) {
      const fallback = { preferredReminderTime: null };
      whereConditions.OR[0].OR.push(fallback);
      whereConditions.OR[1].OR.push(fallback);
    }

    return this.prisma.user.findMany({
      where: whereConditions,
      select: {
        id: true,
        fcmToken: true,
        currentStreak: true,
        longestStreak: true,
        lastReminderSentAt: true,
        lastActivityDate: true,
        preferredReminderTime: true,
        activities: {
          where: {
            completedAt: {
              gte: startOfToday,
              lte: endOfToday,
            },
          },
          take: 1,
        },
      },
    });
  }

  /**
   * Check if reminder was already sent today
   */
  private wasReminderSentToday(lastSentAt: Date | null): boolean {
    if (!lastSentAt) return false;

    const today = this.getStartOfToday();
    return lastSentAt >= today;
  }

  /**
   * Get start of today (00:00:00)
   */
  private getStartOfToday(): Date {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    return today;
  }

  /**
   * Get end of today (23:59:59)
   */
  private getEndOfToday(): Date {
    const today = new Date();
    today.setHours(23, 59, 59, 999);
    return today;
  }

  /**
   * Get streak reminder title based on streak count
   */
  private getStreakReminderTitle(streak: number): string {
    // Epic streaks (100+ days)
    if (streak >= 100) {
      const titles = [
        `💯🔥 ${streak} DAYS! Bạn là huyền thoại!`,
        `👑 ${streak} ngày streak - Ai cũng phải ngưỡng mộ!`,
        `🚀 ${streak} DAYS UNSTOPPABLE! Siêu nhân là đây!`,
      ];
      return titles[Math.floor(Math.random() * titles.length)];
    } else if (streak >= 50) {
      const titles = [
        `⭐ ${streak} ngày! Bạn đang làm điều không tưởng!`,
        `🎯 ${streak} DAYS! Kiên trì là vũ khí của người thành công!`,
        `🏆 ${streak} ngày - Đừng để streak tuyệt vời này dứt!`,
      ];
      return titles[Math.floor(Math.random() * titles.length)];
    } else if (streak >= 30) {
      const titles = [
        `🔥 ${streak} ngày! Đã thành thói quen rồi đấy!`,
        `💪 ${streak} DAYS! Đừng phá vỡ kỷ lục của chính mình!`,
        `🌟 ${streak} ngày liên tiếp - Tuyệt vời!`,
      ];
      return titles[Math.floor(Math.random() * titles.length)];
    } else if (streak >= 14) {
      const titles = [
        `🎉 ${streak} ngày! 2 tuần rồi đấy!`,
        `🔥 ${streak} DAYS! Đang lên momentum ấy!`,
        `⚡ ${streak} ngày - Momentum đang lên cao!`,
      ];
      return titles[Math.floor(Math.random() * titles.length)];
    } else if (streak >= 7) {
      const titles = [
        `🌈 ${streak} ngày! 1 tuần rồi đó!`,
        `🎊 ${streak} DAYS! Đã hình thành thói quen tốt!`,
        `🔥 ${streak} ngày - Hãy tiếp tục nào!`,
      ];
      return titles[Math.floor(Math.random() * titles.length)];
    } else {
      const titles = [
        `🌱 ${streak} ngày! Streak đang lớn dần!`,
        `💚 ${streak} DAYS! Mỗi ngày là một bước tiến!`,
        `🔥 ${streak} ngày - Hãy giữ vững nhé!`,
      ];
      return titles[Math.floor(Math.random() * titles.length)];
    }
  }

  /**
   * Get streak reminder body based on streak count with fun and humorous messages
   */
  private getStreakReminderBody(streak: number): string {
    // Super long streaks (50+ days) - Legendary messages
    if (streak >= 50) {
      const messages = [
        "Streak này quý hơn vàng! Đừng để 1 ngày lười biếng phá hỏng tất cả! 💎",
        "Người ta phải mất cả đời mới build được thói quen như bạn đấy! Keep it up! 🚀",
        "Ngưỡng mộ luôn! Giờ nghỉ 1 ngày là tội ác với chính mình rồi đấy! 👏",
        "Bạn đã vượt qua 99% số người rồi, đừng về đích khi sắp chiến thắng! ⚡",
      ];
      return messages[Math.floor(Math.random() * messages.length)];
    }
    
    // Long streaks (30-49 days) - Motivational + humorous
    else if (streak >= 30) {
      const messages = [
        "1 tháng rồi đó! Giờ bạn nghỉ thì streak sẽ khóc đấy 😢",
        "Streak này đẹp quá, đừng để nó mất đi! Giống như crush vậy ấy! 😅",
        "Đã 30 ngày! Bữa giờ bạn còn nhớ ngày 1 như thế nào không? Hay lắm! 🎯",
        "Thói quen đã thành bản năng rồi! Giờ nghỉ sẽ lạ lắm đấy! 💪",
        "Streak dài thế này mà bỏ thì phí cả thanh xuân luôn! 🔥",
      ];
      return messages[Math.floor(Math.random() * messages.length)];
    }
    
    // Medium streaks (14-29 days) - Encouraging
    else if (streak >= 14) {
      const messages = [
        "Wow 2 tuần rồi! Momentum đang cực tốt, đừng dừng lại! 🚀",
        "Streak đang lên dốc! 1 task nhỏ thôi là giữ được streak đẹp này! ⚡",
        "14 ngày = bắt đầu hình thành thói quen! Đây là giai đoạn vàng đấy! ✨",
        "Quá nửa chặng đường tới 1 tháng rồi! Cố lên nào! 💪",
        "Streak đang đẹp lắm! Làm 1 task nhanh để giữ lại nhé! 🎯",
      ];
      return messages[Math.floor(Math.random() * messages.length)];
    }    
    // One week streaks (7-13 days) - Playful
    else if (streak >= 7) {
      const messages = [
        "1 tuần rồi đó! Hãy chứng minh bạn không chỉ may mắn! 😄",
        "7 ngày liên tiếp! Bạn có biết 21 ngày sẽ thành thói quen không? Cố lên! 🌟",
        "Streak 1 tuần! Giờ nghỉ thì hơi phí đấy nhỉ? 🤔",
        "Chỉ 1 task nhỏ thôi là giữ được tuần liên tiếp này! Easy peasy! 😎",
        "1 tuần! Giữ streak dài hơn thời gian bạn nhớ crush đấy! 😅",
      ];
      return messages[Math.floor(Math.random() * messages.length)];
    }
    
    // Early streaks (1-6 days) - Gentle encouragement
    else {
      const messages = [
        "Streak đang lớn dần! Mỗi ngày là 1 chiến thắng nhỏ! 🌱",
        "Hành trình nghìn dặm bắt đầu từ 1 bước nhỏ! Bạn đang làm tốt lắm! 💚",
        "Đừng để streak nhỏ này dứt! Nó sẽ lớn thành cây to đấy! 🌳",
        "Mỗi ngày complete = 1 viên gạch xây nền móng thói quen! Keep going! 🧱",
        "Streak mới nhưng đầy tiềm năng! Hôm nay làm nhanh task nhé! ⚡",
        "Bắt đầu tuyệt vời rồi đấy! Đừng để 3 ngày trở thành 0 nhé! 💪",
      ];
      return messages[Math.floor(Math.random() * messages.length)];
    }
  }

  /**
   * Manual trigger for testing (can be called from admin endpoint)
   */
  async triggerManualStreakReminder(userId: string) {
    this.logger.log(`Manual streak reminder triggered for user ${userId}`);

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        fcmToken: true,
        currentStreak: true,
        longestStreak: true,
      },
    });

    if (!user) {
      throw new Error('User not found');
    }

    if (!user.fcmToken) {
      throw new Error('User has no FCM token');
    }

    await this.notificationsService.createNotification({
      userId: user.id,
      type: NotificationType.STREAK_REMINDER,
      title: this.getStreakReminderTitle(user.currentStreak),
      body: this.getStreakReminderBody(user.currentStreak),
      priority: 'HIGH',
      data: {
        streak: String(user.currentStreak),
        manual: 'true',
      },
      actionUrl: 'ergolife://tasks',
      sendPush: true,
    });

    this.logger.log(`Manual streak reminder sent to user ${userId}`);
  }
}
