import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from '../../prisma/prisma.service';
import { Activity } from '@prisma/client';

interface ActivityPattern {
  hourly_distribution: Record<number, number>;
  most_active_hour: number;
  typical_start_hour: number;
  last_updated: Date;
}

@Injectable()
export class ActivityPatternService {
  private readonly logger = new Logger(ActivityPatternService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Run daily at midnight to analyze and update user activity patterns
   * This learns when each user typically completes tasks
   */
  @Cron('0 0 * * *', {
    timeZone: 'Asia/Bangkok', // GMT+7
  })
  async analyzeUserActivityPatterns() {
    this.logger.log('Starting daily activity pattern analysis...');

    try {
      const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

      // Get all users who have completed at least one activity
      const users = await this.prisma.user.findMany({
        where: {
          activities: {
            some: {
              completedAt: {
                gte: thirtyDaysAgo,
              },
            },
          },
        },
        include: {
          activities: {
            where: {
              completedAt: {
                gte: thirtyDaysAgo,
                lte: new Date(),
              },
            },
            select: {
              completedAt: true,
            },
          },
        },
      });

      this.logger.log(`Analyzing patterns for ${users.length} active users`);

      let successCount = 0;
      let failureCount = 0;

      for (const user of users) {
        try {
          // Skip users with less than 3 activities (not enough data)
          if (user.activities.length < 3) {
            this.logger.debug(`User ${user.id} has insufficient data (${user.activities.length} activities)`);
            continue;
          }

          const pattern = this.calculateActivityPattern(user.activities);
          const preferredTime = this.calculateOptimalReminderTime(pattern);

          await this.prisma.user.update({
            where: { id: user.id },
            data: {
              activityTimePattern: pattern as any,
              preferredReminderTime: preferredTime,
            },
          });

          successCount++;
          this.logger.debug(
            `Updated pattern for user ${user.id}: optimal time = ${preferredTime.getHours()}:00`,
          );
        } catch (error) {
          failureCount++;
          this.logger.error(`Failed to analyze pattern for user ${user.id}: ${error.message}`);
        }
      }

      this.logger.log(
        `Pattern analysis completed: ${successCount} updated, ${failureCount} failed`,
      );
    } catch (error) {
      this.logger.error(`Pattern analysis job failed: ${error.message}`, error.stack);
    }
  }

  /**
   * Calculate activity pattern from user's activity history
   */
  calculateActivityPattern(activities: Partial<Activity>[]): ActivityPattern {
    const hourlyDistribution: Record<number, number> = {};

    // Count activities by hour
    activities.forEach((activity) => {
      if (activity.completedAt) {
        const hour = new Date(activity.completedAt).getHours();
        hourlyDistribution[hour] = (hourlyDistribution[hour] || 0) + 1;
      }
    });

    // Find most active hour (peak activity time)
    let mostActiveHour = 20; // Default to 20:00 if no data
    let maxCount = 0;

    Object.entries(hourlyDistribution).forEach(([hour, count]) => {
      if (count > maxCount) {
        maxCount = count;
        mostActiveHour = parseInt(hour);
      }
    });

    // Find earliest active hour (typical start of day)
    const typicalStartHour = this.findEarliestActiveHour(hourlyDistribution);

    return {
      hourly_distribution: hourlyDistribution,
      most_active_hour: mostActiveHour,
      typical_start_hour: typicalStartHour,
      last_updated: new Date(),
    };
  }

  /**
   * Find the earliest hour when user is typically active
   * Only considers hours with at least 10% of max activity
   */
  private findEarliestActiveHour(hourlyDistribution: Record<number, number>): number {
    const maxCount = Math.max(...Object.values(hourlyDistribution));
    const threshold = maxCount * 0.1; // 10% threshold

    // Find earliest hour that meets threshold
    for (let hour = 6; hour <= 23; hour++) {
      if ((hourlyDistribution[hour] || 0) >= threshold) {
        return hour;
      }
    }

    return 7; // Default to 7am if no pattern found
  }

  /**
   * Calculate optimal reminder time based on activity pattern
   * Strategy: Send 1 hour before most active time
   */
  calculateOptimalReminderTime(pattern: ActivityPattern): Date {
    const today = new Date();
    const mostActiveHour = pattern.most_active_hour || 20;

    // Send reminder 1 hour before peak activity
    // But not earlier than 7am or later than 21:00
    let reminderHour = mostActiveHour - 1;
    reminderHour = Math.max(7, Math.min(21, reminderHour));

    today.setHours(reminderHour, 0, 0, 0);
    return today;
  }

  /**
   * Get user's preferred reminder time
   * Returns null if no pattern learned yet
   */
  async getUserPreferredTime(userId: string): Promise<Date | null> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { preferredReminderTime: true },
    });

    return user?.preferredReminderTime || null;
  }

  /**
   * Manual trigger to analyze specific user
   * Useful for testing or on-demand analysis
   */
  async analyzeUserPattern(userId: string): Promise<ActivityPattern | null> {
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        activities: {
          where: {
            completedAt: {
              gte: thirtyDaysAgo,
            },
          },
          select: {
            completedAt: true,
          },
        },
      },
    });

    if (!user || user.activities.length < 3) {
      this.logger.warn(`User ${userId} has insufficient activity data`);
      return null;
    }

    const pattern = this.calculateActivityPattern(user.activities);
    const preferredTime = this.calculateOptimalReminderTime(pattern);

    await this.prisma.user.update({
      where: { id: userId },
      data: {
        activityTimePattern: pattern as any,
        preferredReminderTime: preferredTime,
      },
    });

    this.logger.log(`Analyzed pattern for user ${userId}: optimal time = ${preferredTime.getHours()}:00`);
    return pattern;
  }
}
