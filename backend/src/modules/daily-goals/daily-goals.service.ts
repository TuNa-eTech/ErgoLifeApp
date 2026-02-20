import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import {
  UpdateGoalSettingsDto,
  DailyGoalResponseDto,
  GoalSettingsResponseDto,
} from './dto';

/// Default goal settings for new users.
const DEFAULT_TARGET_EP = 500;
const DEFAULT_TARGET_DURATION = 30;
const DEFAULT_TARGET_ACTIVITIES = 2;

@Injectable()
export class DailyGoalsService {
  private readonly logger = new Logger(DailyGoalsService.name);

  constructor(private prisma: PrismaService) {}

  /// Get or create today's daily goal for a user.
  async getTodayGoal(userId: string): Promise<DailyGoalResponseDto> {
    const today = this.getTodayDate();

    let goal = await this.prisma.dailyGoal.findUnique({
      where: { userId_date: { userId, date: today } },
    });

    if (!goal) {
      const settings = await this.getOrCreateSettings(userId);
      goal = await this.prisma.dailyGoal.create({
        data: {
          userId,
          date: today,
          targetEp: settings.targetEp,
          targetDuration: settings.targetDuration,
          targetActivities: settings.targetActivities,
        },
      });
      this.logger.log(`Created daily goal for user ${userId}`);
    }

    return this.toResponseDto(goal);
  }

  /// Get user's goal settings, or return defaults.
  async getGoalSettings(userId: string): Promise<GoalSettingsResponseDto> {
    const settings = await this.getOrCreateSettings(userId);
    return {
      targetEp: settings.targetEp,
      targetDuration: settings.targetDuration,
      targetActivities: settings.targetActivities,
    };
  }

  /// Update user's default goal settings.
  async updateGoalSettings(
    userId: string,
    dto: UpdateGoalSettingsDto,
  ): Promise<GoalSettingsResponseDto> {
    const settings = await this.prisma.userGoalSettings.upsert({
      where: { userId },
      update: {
        ...(dto.targetEp !== undefined && { targetEp: dto.targetEp }),
        ...(dto.targetDuration !== undefined && {
          targetDuration: dto.targetDuration,
        }),
        ...(dto.targetActivities !== undefined && {
          targetActivities: dto.targetActivities,
        }),
      },
      create: {
        userId,
        targetEp: dto.targetEp ?? DEFAULT_TARGET_EP,
        targetDuration: dto.targetDuration ?? DEFAULT_TARGET_DURATION,
        targetActivities: dto.targetActivities ?? DEFAULT_TARGET_ACTIVITIES,
      },
    });

    return {
      targetEp: settings.targetEp,
      targetDuration: settings.targetDuration,
      targetActivities: settings.targetActivities,
    };
  }

  /// Update daily goal progress after an activity is completed.
  /// Called by ActivitiesService.create() — fire-and-forget.
  async updateProgress(
    userId: string,
    earnedEp: number,
    durationMinutes: number,
  ): Promise<void> {
    try {
      const today = this.getTodayDate();

      // Get or create today's goal
      let goal = await this.prisma.dailyGoal.findUnique({
        where: { userId_date: { userId, date: today } },
      });

      if (!goal) {
        const settings = await this.getOrCreateSettings(userId);
        goal = await this.prisma.dailyGoal.create({
          data: {
            userId,
            date: today,
            targetEp: settings.targetEp,
            targetDuration: settings.targetDuration,
            targetActivities: settings.targetActivities,
          },
        });
      }

      // Increment progress
      const newEp = goal.currentEp + earnedEp;
      const newDuration = goal.currentDuration + durationMinutes;
      const newActivities = goal.currentActivities + 1;

      // Check if all 3 rings are closed
      const isPerfectDay =
        newEp >= goal.targetEp &&
        newDuration >= goal.targetDuration &&
        newActivities >= goal.targetActivities;

      const wasPerfectDay = goal.isPerfectDay;

      await this.prisma.dailyGoal.update({
        where: { id: goal.id },
        data: {
          currentEp: newEp,
          currentDuration: newDuration,
          currentActivities: newActivities,
          isPerfectDay,
          completedAt:
            isPerfectDay && !wasPerfectDay ? new Date() : goal.completedAt,
        },
      });

      if (isPerfectDay && !wasPerfectDay) {
        this.logger.log(`🎉 Perfect Day for user ${userId}!`);
      }
    } catch (error) {
      // Fire-and-forget: log error but don't break the activity flow
      this.logger.error(
        `Failed to update daily goal for user ${userId}`,
        error,
      );
    }
  }

  /// Get daily goal history for a date range.
  async getHistory(
    userId: string,
    from?: string,
    to?: string,
  ): Promise<DailyGoalResponseDto[]> {
    const today = new Date();
    const defaultFrom = new Date(today);
    defaultFrom.setDate(defaultFrom.getDate() - 30);

    const startDate = from ? new Date(from) : defaultFrom;
    const endDate = to ? new Date(to) : today;

    const goals = await this.prisma.dailyGoal.findMany({
      where: {
        userId,
        date: {
          gte: startDate,
          lte: endDate,
        },
      },
      orderBy: { date: 'desc' },
    });

    return goals.map((goal) => this.toResponseDto(goal));
  }

  /// Get or create default settings for a user.
  private async getOrCreateSettings(userId: string) {
    let settings = await this.prisma.userGoalSettings.findUnique({
      where: { userId },
    });

    if (!settings) {
      settings = await this.prisma.userGoalSettings.create({
        data: {
          userId,
          targetEp: DEFAULT_TARGET_EP,
          targetDuration: DEFAULT_TARGET_DURATION,
          targetActivities: DEFAULT_TARGET_ACTIVITIES,
        },
      });
    }

    return settings;
  }

  /// Get today's date as midnight UTC.
  private getTodayDate(): Date {
    const now = new Date();
    return new Date(
      Date.UTC(now.getFullYear(), now.getMonth(), now.getDate()),
    );
  }

  /// Convert Prisma model to response DTO with progress ratios.
  private toResponseDto(goal: any): DailyGoalResponseDto {
    return {
      id: goal.id,
      date: goal.date.toISOString().split('T')[0],
      targetEp: goal.targetEp,
      targetDuration: goal.targetDuration,
      targetActivities: goal.targetActivities,
      currentEp: goal.currentEp,
      currentDuration: goal.currentDuration,
      currentActivities: goal.currentActivities,
      isPerfectDay: goal.isPerfectDay,
      completedAt: goal.completedAt?.toISOString(),
      epProgress: goal.targetEp > 0 ? goal.currentEp / goal.targetEp : 0,
      durationProgress:
        goal.targetDuration > 0
          ? goal.currentDuration / goal.targetDuration
          : 0,
      activitiesProgress:
        goal.targetActivities > 0
          ? goal.currentActivities / goal.targetActivities
          : 0,
    };
  }
}
