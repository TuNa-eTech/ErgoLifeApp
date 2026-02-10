import {
  Injectable,
  Logger,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { NotificationType, NotificationPriority } from '@prisma/client';
import {
  CreateActivityDto,
  CreateActivityResponseDto,
  GetActivitiesQueryDto,
  GetActivitiesResponseDto,
  GetLeaderboardQueryDto,
  LeaderboardResponseDto,
  GetStatsQueryDto,
  StatsResponseDto,
  ActivityDto,
} from './dto';

@Injectable()
export class ActivitiesService {
  private readonly logger = new Logger(ActivitiesService.name);

  constructor(
    private prisma: PrismaService,
    private notificationsService: NotificationsService,
  ) {}

  async create(
    userId: string,
    createActivityDto: CreateActivityDto,
  ): Promise<CreateActivityResponseDto> {
    // Get user with house
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, houseId: true, walletBalance: true },
    });

    if (!user?.houseId) {
      throw new ForbiddenException({
        code: 'FORBIDDEN',
        message: 'You must be in a house to log activities',
      });
    }

    // Calculate points
    const { durationSeconds, metsValue, magicWipePercentage, taskName } =
      createActivityDto;
    const basePoints = (durationSeconds / 60) * metsValue * 10;
    const bonusMultiplier = magicWipePercentage >= 95 ? 1.1 : 1.0;
    const pointsEarned = Math.floor(basePoints * bonusMultiplier);

    // Create activity and update wallet in transaction
    const result = await this.prisma.$transaction(async (tx) => {
      // Create activity
      const activity = await tx.activity.create({
        data: {
          userId,
          houseId: user.houseId!,
          taskName,
          durationSeconds,
          metsValue,
          pointsEarned,
          bonusMultiplier,
        },
      });

      // Update wallet
      const updatedUser = await tx.user.update({
        where: { id: userId },
        data: {
          walletBalance: { increment: pointsEarned },
        },
        select: { walletBalance: true },
      });

      return { activity, newBalance: updatedUser.walletBalance };
    });

    // Update streak AFTER successful activity creation
    const streakUpdate = await this.updateStreakAfterActivity(userId);

    // Send notifications (fire-and-forget, don't block response)
    this.sendActivityNotifications(
      userId,
      user.houseId!,
      taskName,
      pointsEarned,
      durationSeconds,
      streakUpdate,
    ).catch((err) =>
      this.logger.error(
        `Failed to send activity notifications: ${err.message}`,
      ),
    );

    return {
      activity: {
        id: result.activity.id,
        taskName: result.activity.taskName,
        durationSeconds: result.activity.durationSeconds,
        metsValue: result.activity.metsValue,
        pointsEarned: result.activity.pointsEarned,
        bonusMultiplier: result.activity.bonusMultiplier,
        completedAt: result.activity.completedAt,
      },
      wallet: {
        previousBalance: user.walletBalance,
        pointsEarned,
        newBalance: result.newBalance,
      },
      streak: {
        previousStreak: streakUpdate.previousStreak,
        currentStreak: streakUpdate.currentStreak,
        longestStreak: streakUpdate.longestStreak,
        streakFreezeCount: streakUpdate.streakFreezeCount,
        message: streakUpdate.message,
        ...(streakUpdate.info && { info: streakUpdate.info }),
      },
    };
  }

  async findAll(
    userId: string,
    query: GetActivitiesQueryDto,
  ): Promise<GetActivitiesResponseDto> {
    const { page = 1, limit = 20, startDate, endDate } = query;
    const skip = (page - 1) * limit;

    // Build date filter
    const dateFilter: { gte?: Date; lte?: Date } = {};
    if (startDate) dateFilter.gte = new Date(startDate);
    if (endDate) dateFilter.lte = new Date(endDate);

    const where = {
      userId,
      ...(Object.keys(dateFilter).length > 0 && { completedAt: dateFilter }),
    };

    // Get activities and count
    const [activities, total] = await Promise.all([
      this.prisma.activity.findMany({
        where,
        skip,
        take: limit,
        orderBy: { completedAt: 'desc' },
      }),
      this.prisma.activity.count({ where }),
    ]);

    // Calculate summary for the filtered results
    const summaryAgg = await this.prisma.activity.aggregate({
      where,
      _sum: {
        pointsEarned: true,
        durationSeconds: true,
      },
      _count: true,
    });

    return {
      items: activities.map((a) => ({
        id: a.id,
        taskName: a.taskName,
        durationSeconds: a.durationSeconds,
        metsValue: a.metsValue,
        pointsEarned: a.pointsEarned,
        bonusMultiplier: a.bonusMultiplier,
        completedAt: a.completedAt,
      })),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
      summary: {
        totalPoints: summaryAgg._sum.pointsEarned || 0,
        totalDuration: summaryAgg._sum.durationSeconds || 0,
        activityCount: summaryAgg._count,
      },
    };
  }

  async getLeaderboard(
    userId: string,
    query: GetLeaderboardQueryDto,
  ): Promise<LeaderboardResponseDto> {
    const { scope = 'house', limit = 10 } = query;

    // Use month-based date range
    const { monthStart, monthEnd, monthString } = this.getMonthBounds(
      query.year,
      query.month,
    );

    let members: {
      id: string;
      displayName: string | null;
      avatarId: number | null;
    }[] = [];

    if (scope === 'house') {
      // Get user's house
      const user = await this.prisma.user.findUnique({
        where: { id: userId },
        select: { houseId: true },
      });

      if (!user?.houseId) {
        throw new ForbiddenException({
          code: 'FORBIDDEN',
          message: 'You must be in a house to view leaderboard',
        });
      }

      // Get all members of the house
      members = await this.prisma.user.findMany({
        where: { houseId: user.houseId },
        select: { id: true, displayName: true, avatarId: true },
      });
    } else {
      // GLOBAL SCOPE — get top active users in the period
      const activeUserIds = await this.prisma.activity.groupBy({
        by: ['userId'],
        where: {
          completedAt: {
            gte: monthStart,
            lte: monthEnd,
          },
        },
        _sum: { pointsEarned: true },
        orderBy: { _sum: { pointsEarned: 'desc' } },
        take: limit,
      });

      const users = await this.prisma.user.findMany({
        where: { id: { in: activeUserIds.map((u) => u.userId) } },
        select: { id: true, displayName: true, avatarId: true },
      });

      members = users;
    }

    // Get activity aggregates for each member
    const rankings = await Promise.all(
      members.map(async (member) => {
        const agg = await this.prisma.activity.aggregate({
          where: {
            userId: member.id,
            completedAt: {
              gte: monthStart,
              lte: monthEnd,
            },
          },
          _sum: { pointsEarned: true },
          _count: true,
        });

        return {
          user: {
            id: member.id,
            displayName: member.displayName,
            avatarId: member.avatarId,
          },
          weeklyPoints: agg._sum.pointsEarned || 0,
          activityCount: agg._count,
        };
      }),
    );

    // Sort by points descending, apply limit, and add rank
    rankings.sort((a, b) => b.weeklyPoints - a.weeklyPoints);
    const rankedResults = rankings.slice(0, limit).map((r, idx) => ({
      rank: idx + 1,
      ...r,
    }));

    return {
      scope,
      month: monthString,
      monthStart: monthStart.toISOString(),
      monthEnd: monthEnd.toISOString(),
      rankings: rankedResults,
    };
  }

  async getStats(
    userId: string,
    query: GetStatsQueryDto,
  ): Promise<StatsResponseDto> {
    const { period = 'week', taskName, year, month } = query;

    // Determine date range
    let startDate: Date;
    let endDate: Date;

    if (year) {
      // Custom date filter logic
      if (month) {
        // Specific Month in Year
        startDate = new Date(year, month - 1, 1);
        endDate = new Date(year, month, 0, 23, 59, 59, 999);
      } else {
        // Whole Year
        startDate = new Date(year, 0, 1);
        endDate = new Date(year, 11, 31, 23, 59, 59, 999);
      }
    } else {
      // Standard period logic
      const bounds = this.getPeriodBounds(period);
      startDate = bounds.startDate;
      endDate = bounds.endDate;
    }

    const where: any = {
      userId,
      completedAt: {
        gte: startDate,
        lte: endDate,
      },
    };

    if (taskName) {
      where.taskName = taskName;
    }

    // Get aggregates
    const agg = await this.prisma.activity.aggregate({
      where,
      _sum: {
        pointsEarned: true,
        durationSeconds: true,
      },
      _count: true,
    });

    // Get top tasks (only if not filtering by specific task)
    let topTasks: any[] = [];
    if (!taskName) {
      const topTasksRaw = await this.prisma.activity.groupBy({
        by: ['taskName'],
        where,
        _count: true,
        _sum: { pointsEarned: true, durationSeconds: true },
        orderBy: { _sum: { pointsEarned: 'desc' } },
        take: 5,
      });
      topTasks = topTasksRaw;
    } else {
      // If filtering by task, we might want to return just that task as the "top task"
      topTasks = [
        {
          taskName: taskName,
          _count: agg._count,
          _sum: {
            pointsEarned: agg._sum.pointsEarned || 0,
            durationSeconds: agg._sum.durationSeconds || 0,
          },
        },
      ];
    }

    // Estimate calories: Duration(min) × METs × 3.5 × Weight(kg) / 200
    // Using average weight of 70kg and average METs of 3.0
    // Note: If we had METs in aggregate, it would be more accurate.
    // For specific task filter, we could look up the task's METs, but for now using average is acceptable or we should aggregate METs * Duration
    const totalMinutes = (agg._sum.durationSeconds || 0) / 60;
    const estimatedCalories = Math.round((totalMinutes * 3.0 * 3.5 * 70) / 200);

    // Get streak from user (now tracked in real-time)
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { currentStreak: true, longestStreak: true },
    });

    return {
      period: year ? (month ? `${year}-${month}` : `${year}`) : period,
      totalPoints: agg._sum.pointsEarned || 0,
      totalActivities: agg._count,
      totalDuration: agg._sum.durationSeconds || 0,
      estimatedCalories,
      topTasks: topTasks.map((t) => ({
        taskName: t.taskName,
        count: t._count,
        totalPoints: t._sum.pointsEarned || 0,
        totalDuration: t._sum.durationSeconds || 0,
      })),
      streak: {
        current: user?.currentStreak || 0,
        longest: user?.longestStreak || 0,
      },
    };
  }

  private getWeekBounds(weekInput?: string): {
    weekStart: Date;
    weekEnd: Date;
    weekString: string;
  } {
    let targetDate = new Date();

    if (weekInput && /^\d{4}-W\d{2}$/.test(weekInput)) {
      const [year, weekNum] = weekInput.split('-W').map(Number);
      targetDate = this.getDateOfISOWeek(weekNum, year);
    }

    // Get Monday of the week
    const day = targetDate.getDay();
    const diff = targetDate.getDate() - day + (day === 0 ? -6 : 1);
    const weekStart = new Date(targetDate);
    weekStart.setDate(diff);
    weekStart.setHours(0, 0, 0, 0);

    // Get Sunday
    const weekEnd = new Date(weekStart);
    weekEnd.setDate(weekStart.getDate() + 6);
    weekEnd.setHours(23, 59, 59, 999);

    // Format week string
    const year = weekStart.getFullYear();
    const weekNum = this.getISOWeekNumber(weekStart);
    const weekString = `${year}-W${String(weekNum).padStart(2, '0')}`;

    return { weekStart, weekEnd, weekString };
  }

  private getMonthBounds(
    yearInput?: number,
    monthInput?: number,
  ): {
    monthStart: Date;
    monthEnd: Date;
    monthString: string;
  } {
    const now = new Date();
    const year = yearInput ?? now.getFullYear();
    const month = monthInput ?? now.getMonth() + 1; // 1-based

    const monthStart = new Date(year, month - 1, 1, 0, 0, 0, 0);
    const monthEnd = new Date(year, month, 0, 23, 59, 59, 999);
    const monthString = `${year}-${String(month).padStart(2, '0')}`;

    return { monthStart, monthEnd, monthString };
  }

  private getDateOfISOWeek(week: number, year: number): Date {
    const simple = new Date(year, 0, 1 + (week - 1) * 7);
    const dow = simple.getDay();
    const isoWeekStart = simple;
    if (dow <= 4) {
      isoWeekStart.setDate(simple.getDate() - simple.getDay() + 1);
    } else {
      isoWeekStart.setDate(simple.getDate() + 8 - simple.getDay());
    }
    return isoWeekStart;
  }

  private getISOWeekNumber(date: Date): number {
    const d = new Date(
      Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()),
    );
    const dayNum = d.getUTCDay() || 7;
    d.setUTCDate(d.getUTCDate() + 4 - dayNum);
    const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    return Math.ceil(((d.getTime() - yearStart.getTime()) / 86400000 + 1) / 7);
  }

  private getPeriodBounds(period: 'week' | 'month' | 'all'): {
    startDate: Date;
    endDate: Date;
  } {
    const endDate = new Date();
    let startDate = new Date();

    switch (period) {
      case 'week':
        startDate.setDate(endDate.getDate() - 7);
        break;
      case 'month':
        startDate.setMonth(endDate.getMonth() - 1);
        break;
      case 'all':
        startDate = new Date(0); // Beginning of time
        break;
    }

    return { startDate, endDate };
  }

  /**
   * Update user's streak after completing an activity (Duolingo-style)
   * @returns Streak update information including message for UI
   */
  private async updateStreakAfterActivity(userId: string): Promise<{
    previousStreak: number;
    currentStreak: number;
    longestStreak: number;
    streakFreezeCount: number;
    message:
      | 'STREAK_INCREASED'
      | 'STREAK_STARTED'
      | 'STREAK_MAINTAINED'
      | 'STREAK_FREEZE_USED'
      | 'STREAK_FREEZE_BONUS'
      | 'STREAK_RESET';
    info?: string;
  }> {
    const MAX_STREAK_FREEZE = 2;
    const BONUS_FREEZE_AT = 100;

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        currentStreak: true,
        longestStreak: true,
        lastActivityDate: true,
        streakFreezeCount: true,
      },
    });

    const today = new Date();
    today.setUTCHours(0, 0, 0, 0); // Start of day UTC

    const lastActivityDay = user.lastActivityDate
      ? new Date(user.lastActivityDate)
      : null;

    if (lastActivityDay) {
      lastActivityDay.setUTCHours(0, 0, 0, 0);
    }

    let newCurrentStreak = user.currentStreak;
    let newFreezeCount = user.streakFreezeCount;
    let message:
      | 'STREAK_INCREASED'
      | 'STREAK_STARTED'
      | 'STREAK_MAINTAINED'
      | 'STREAK_FREEZE_USED'
      | 'STREAK_FREEZE_BONUS'
      | 'STREAK_RESET';
    let info: string | undefined;
    const previousStreak = user.currentStreak;

    if (!lastActivityDay) {
      // First activity ever
      newCurrentStreak = 1;
      message = 'STREAK_STARTED';
    } else {
      const daysDiff = Math.floor(
        (today.getTime() - lastActivityDay.getTime()) / (1000 * 60 * 60 * 24),
      );

      if (daysDiff === 0) {
        // Same day - no change
        message = 'STREAK_MAINTAINED';

        // Don't update database, return current state
        return {
          previousStreak,
          currentStreak: user.currentStreak,
          longestStreak: user.longestStreak,
          streakFreezeCount: user.streakFreezeCount,
          message,
        };
      } else if (daysDiff === 1) {
        // Next day - increase streak
        newCurrentStreak = user.currentStreak + 1;
        message = 'STREAK_INCREASED';
      } else if (daysDiff === 2 && user.streakFreezeCount > 0) {
        // Missed 1 day BUT has Streak Freeze → Use it!
        newFreezeCount = user.streakFreezeCount - 1;
        newCurrentStreak = user.currentStreak; // Maintain streak
        message = 'STREAK_FREEZE_USED';
        info =
          'You missed yesterday, but your Streak Freeze kept your streak safe! 🛡️';
      } else {
        // Missed day(s) without Freeze → Reset
        newCurrentStreak = 1;
        message = 'STREAK_RESET';
        info = `You missed ${daysDiff - 1}+ days. Streak reset, but you can rebuild it! 💪`;
      }
    }

    // Bonus: Free Freeze at 100 days milestone
    if (
      newCurrentStreak === BONUS_FREEZE_AT &&
      newFreezeCount < MAX_STREAK_FREEZE
    ) {
      newFreezeCount += 1;
      message = 'STREAK_FREEZE_BONUS';
      info = '🎉 100 day streak! Earned 1 FREE Streak Freeze!';
    }

    const newLongestStreak = Math.max(newCurrentStreak, user.longestStreak);

    // Update user streak data
    await this.prisma.user.update({
      where: { id: userId },
      data: {
        currentStreak: newCurrentStreak,
        longestStreak: newLongestStreak,
        lastActivityDate: today,
        streakFreezeCount: newFreezeCount,
      },
    });

    return {
      previousStreak,
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
      streakFreezeCount: newFreezeCount,
      message,
      info,
    };
  }

  /// Milestone thresholds for streak notifications
  private readonly STREAK_MILESTONES = [7, 14, 21, 30, 50, 100, 365];

  /// Milestone messages in Vietnamese
  private getStreakMilestoneMessage(streak: number): {
    title: string;
    body: string;
  } {
    if (streak >= 365) {
      return {
        title: `🏆💎 ${streak} NGÀY! Huyền thoại!`,
        body: 'Một năm kiên trì! Bạn là nguồn cảm hứng cho mọi người! 🌟',
      };
    }
    if (streak >= 100) {
      return {
        title: `🏆🔥 ${streak} ngày! Không tưởng!`,
        body: 'Ba chữ số rồi! Streak của bạn thật đáng ngưỡng mộ! 💯',
      };
    }
    if (streak >= 50) {
      return {
        title: `🏆⭐ ${streak} ngày! Nửa trăm!`,
        body: 'Bạn đã đi được nửa đường đến 100! Cố lên! 🚀',
      };
    }
    if (streak >= 30) {
      return {
        title: `🏆🎉 ${streak} ngày! Một tháng!`,
        body: 'Thói quen đã hình thành! Giữ vững nhé! 💪',
      };
    }
    if (streak >= 21) {
      return {
        title: `🏆✨ ${streak} ngày! 3 tuần rồi!`,
        body: 'Khoa học nói 21 ngày tạo thói quen — bạn làm được rồi! 🧠',
      };
    }
    if (streak >= 14) {
      return {
        title: `🏆🌈 ${streak} ngày! 2 tuần!`,
        body: 'Hai tuần liên tục! Bạn thật kiên định! 🎊',
      };
    }
    return {
      title: `🏆🌱 ${streak} ngày! 1 tuần!`,
      body: 'Tuần đầu tiên hoàn thành! Tiếp tục nhé! 🎉',
    };
  }

  /**
   * Send all notifications after activity completion.
   * Runs fire-and-forget to avoid blocking the API response.
   */
  private async sendActivityNotifications(
    userId: string,
    houseId: string,
    taskName: string,
    pointsEarned: number,
    durationSeconds: number,
    streakUpdate: {
      previousStreak: number;
      currentStreak: number;
      longestStreak: number;
      message: string;
    },
  ): Promise<void> {
    const durationMinutes = Math.round(durationSeconds / 60);

    // 1. ACTIVITY_COMPLETED — save to DB only (user is in-app)
    await this.notificationsService.createNotification({
      userId,
      type: NotificationType.ACTIVITY_COMPLETED,
      priority: NotificationPriority.LOW,
      title: `✅ Hoàn thành ${taskName}!`,
      body: `+${pointsEarned} points • ${durationMinutes} phút`,
      data: { taskName, pointsEarned: String(pointsEarned) },
      actionUrl: 'ergolife://tasks',
      sendPush: false,
    });

    // 2. STREAK_MILESTONE — push notification for important milestones
    if (this.STREAK_MILESTONES.includes(streakUpdate.currentStreak)) {
      const milestone = this.getStreakMilestoneMessage(
        streakUpdate.currentStreak,
      );
      await this.notificationsService.createNotification({
        userId,
        type: NotificationType.STREAK_MILESTONE,
        priority: NotificationPriority.HIGH,
        title: milestone.title,
        body: milestone.body,
        data: {
          streak: String(streakUpdate.currentStreak),
          longestStreak: String(streakUpdate.longestStreak),
        },
        actionUrl: 'ergolife://tasks',
        sendPush: true,
      });
    }

    // 3. STREAK_LOST — notify when a meaningful streak is broken
    if (
      streakUpdate.message === 'STREAK_RESET' &&
      streakUpdate.previousStreak >= 3
    ) {
      await this.notificationsService.createNotification({
        userId,
        type: NotificationType.STREAK_LOST,
        priority: NotificationPriority.HIGH,
        title: `💔 Streak ${streakUpdate.previousStreak} ngày đã mất...`,
        body: 'Đừng bỏ cuộc! Hãy xây dựng streak mới từ hôm nay! 💪',
        data: {
          previousStreak: String(streakUpdate.previousStreak),
        },
        actionUrl: 'ergolife://tasks',
        sendPush: true,
      });
    }

    // 4. HOUSE_ACTIVITY — notify house members (no push, feed only)
    const houseMembers = await this.prisma.user.findMany({
      where: { houseId, id: { not: userId } },
      select: { id: true },
    });

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { displayName: true },
    });
    const displayName = user?.displayName || 'Thành viên';

    if (houseMembers.length > 0) {
      await this.notificationsService.sendBulkNotifications(
        houseMembers.map((m) => m.id),
        {
          type: NotificationType.HOUSE_ACTIVITY,
          priority: NotificationPriority.LOW,
          title: `🏃 ${displayName} vừa tập!`,
          body: `${taskName} • +${pointsEarned} points`,
          data: {
            houseId,
            userId,
            taskName,
            pointsEarned: String(pointsEarned),
          },
          actionUrl: 'ergolife://house',
          sendPush: false,
        },
      );
    }
  }
}
