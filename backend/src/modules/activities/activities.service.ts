import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
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
  constructor(private prisma: PrismaService) {}

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
    const { durationSeconds, metsValue, magicWipePercentage, taskName } = createActivityDto;
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

    // Parse week or use current
    const { weekStart, weekEnd, weekString } = this.getWeekBounds(query.week);

    // Get all members of the house
    const members = await this.prisma.user.findMany({
      where: { houseId: user.houseId },
      select: { id: true, displayName: true, avatarId: true },
    });

    // Get activity aggregates for each member
    const rankings = await Promise.all(
      members.map(async (member) => {
        const agg = await this.prisma.activity.aggregate({
          where: {
            userId: member.id,
            completedAt: {
              gte: weekStart,
              lte: weekEnd,
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

    // Sort by points descending and add rank
    rankings.sort((a, b) => b.weeklyPoints - a.weeklyPoints);
    const rankedResults = rankings.map((r, idx) => ({
      rank: idx + 1,
      ...r,
    }));

    return {
      week: weekString,
      weekStart: weekStart.toISOString(),
      weekEnd: weekEnd.toISOString(),
      rankings: rankedResults,
    };
  }

  async getStats(
    userId: string,
    query: GetStatsQueryDto,
  ): Promise<StatsResponseDto> {
    const { period = 'week' } = query;
    const { startDate, endDate } = this.getPeriodBounds(period);

    const where = {
      userId,
      completedAt: {
        gte: startDate,
        lte: endDate,
      },
    };

    // Get aggregates
    const agg = await this.prisma.activity.aggregate({
      where,
      _sum: {
        pointsEarned: true,
        durationSeconds: true,
      },
      _count: true,
    });

    // Get top tasks
    const topTasks = await this.prisma.activity.groupBy({
      by: ['taskName'],
      where,
      _count: true,
      _sum: { pointsEarned: true },
      orderBy: { _sum: { pointsEarned: 'desc' } },
      take: 5,
    });

    // Estimate calories: Duration(min) × METs × 3.5 × Weight(kg) / 200
    // Using average weight of 70kg and average METs of 3.0
    const totalMinutes = (agg._sum.durationSeconds || 0) / 60;
    const estimatedCalories = Math.round(totalMinutes * 3.0 * 3.5 * 70 / 200);

    // Get streak (simplified: count consecutive days with activity)
    const { current, longest } = await this.calculateStreak(userId);

    return {
      period,
      totalPoints: agg._sum.pointsEarned || 0,
      totalActivities: agg._count,
      totalDuration: agg._sum.durationSeconds || 0,
      estimatedCalories,
      topTasks: topTasks.map((t) => ({
        taskName: t.taskName,
        count: t._count,
        totalPoints: t._sum.pointsEarned || 0,
      })),
      streak: { current, longest },
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
    const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
    const dayNum = d.getUTCDay() || 7;
    d.setUTCDate(d.getUTCDate() + 4 - dayNum);
    const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    return Math.ceil((((d.getTime() - yearStart.getTime()) / 86400000) + 1) / 7);
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

  private async calculateStreak(userId: string): Promise<{ current: number; longest: number }> {
    // Get unique activity dates
    const activities = await this.prisma.activity.findMany({
      where: { userId },
      select: { completedAt: true },
      orderBy: { completedAt: 'desc' },
    });

    if (activities.length === 0) {
      return { current: 0, longest: 0 };
    }

    // Get unique dates (as YYYY-MM-DD strings)
    const uniqueDates = [...new Set(
      activities.map((a) => a.completedAt.toISOString().split('T')[0])
    )].sort().reverse();

    // Calculate current streak
    let current = 0;
    const today = new Date().toISOString().split('T')[0];
    const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
    
    // Start counting from today or yesterday
    let checkDate = uniqueDates[0] === today || uniqueDates[0] === yesterday ? uniqueDates[0] : null;
    
    if (checkDate) {
      for (const date of uniqueDates) {
        if (date === checkDate) {
          current++;
          const prevDate = new Date(checkDate);
          prevDate.setDate(prevDate.getDate() - 1);
          checkDate = prevDate.toISOString().split('T')[0];
        } else {
          break;
        }
      }
    }

    // Calculate longest streak (simplified)
    let longest = current;
    let tempStreak = 1;
    for (let i = 1; i < uniqueDates.length; i++) {
      const prevDate = new Date(uniqueDates[i - 1]);
      prevDate.setDate(prevDate.getDate() - 1);
      if (uniqueDates[i] === prevDate.toISOString().split('T')[0]) {
        tempStreak++;
        longest = Math.max(longest, tempStreak);
      } else {
        tempStreak = 1;
      }
    }

    return { current, longest };
  }
}
