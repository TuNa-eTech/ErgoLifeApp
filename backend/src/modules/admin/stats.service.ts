import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class AdminStatsService {
  constructor(private prisma: PrismaService) {}

  async getDashboardStats() {
    const now = new Date();
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(now.getDate() - 7);
    const fourteenDaysAgo = new Date();
    fourteenDaysAgo.setDate(now.getDate() - 14);

    // Current totals
    const [totalUsers, totalHouses, totalActivities, activeUsers] =
      await Promise.all([
        this.prisma.user.count(),
        this.prisma.house.count(),
        this.prisma.activity.count(),
        this.prisma.user.count({
          where: { lastActivityDate: { gte: sevenDaysAgo } },
        }),
      ]);

    // Previous period totals (7–14 days ago) for trend calculation
    const [prevUsers, prevHouses, prevActivities, prevActiveUsers] =
      await Promise.all([
        this.prisma.user.count({
          where: { createdAt: { lt: sevenDaysAgo } },
        }),
        this.prisma.house.count({
          where: { createdAt: { lt: sevenDaysAgo } },
        }),
        this.prisma.activity.count({
          where: { completedAt: { lt: sevenDaysAgo } },
        }),
        this.prisma.user.count({
          where: {
            lastActivityDate: {
              gte: fourteenDaysAgo,
              lt: sevenDaysAgo,
            },
          },
        }),
      ]);

    return {
      totalUsers,
      totalHouses,
      totalActivities,
      activeUsers,
      trends: {
        users: this.calcTrendPercent(totalUsers, prevUsers),
        houses: this.calcTrendPercent(totalHouses, prevHouses),
        activities: this.calcTrendPercent(
          totalActivities,
          prevActivities,
        ),
        activeUsers: this.calcTrendPercent(activeUsers, prevActiveUsers),
      },
    };
  }

  async getGrowthStats() {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const users = await this.prisma.user.findMany({
      where: { createdAt: { gte: thirtyDaysAgo } },
      select: { createdAt: true },
      orderBy: { createdAt: 'asc' },
    });

    const dailyCounts: Record<string, number> = {};
    users.forEach((u) => {
      const date = u.createdAt.toISOString().split('T')[0];
      dailyCounts[date] = (dailyCounts[date] || 0) + 1;
    });

    return Object.entries(dailyCounts).map(([date, count]) => ({
      date,
      count,
    }));
  }

  async getActivityStats(days = 7) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const activities = await this.prisma.activity.findMany({
      where: { completedAt: { gte: startDate } },
      select: { completedAt: true },
      orderBy: { completedAt: 'asc' },
    });

    const dailyCounts: Record<string, number> = {};

    // Pre-fill all days with 0
    for (let i = 0; i < days; i++) {
      const d = new Date();
      d.setDate(d.getDate() - (days - 1 - i));
      dailyCounts[d.toISOString().split('T')[0]] = 0;
    }

    activities.forEach((a) => {
      const date = a.completedAt.toISOString().split('T')[0];
      dailyCounts[date] = (dailyCounts[date] || 0) + 1;
    });

    return Object.entries(dailyCounts).map(([date, count]) => ({
      date,
      count,
    }));
  }

  async getHouseDistribution() {
    const [personal, group, totalMembers, totalGroupHouses] =
      await Promise.all([
        this.prisma.house.count({ where: { isPersonal: true } }),
        this.prisma.house.count({ where: { isPersonal: false } }),
        this.prisma.user.count({ where: { houseId: { not: null } } }),
        this.prisma.house.count({ where: { isPersonal: false } }),
      ]);

    const avgMembers =
      totalGroupHouses > 0
        ? Math.round((totalMembers / totalGroupHouses) * 10) / 10
        : 0;

    return {
      distribution: [
        { name: 'Personal', value: personal },
        { name: 'Group', value: group },
      ],
      avgMembers,
      total: personal + group,
    };
  }

  async getRecentEvents(limit = 10) {
    const [recentUsers, recentActivities, recentRedemptions] =
      await Promise.all([
        this.prisma.user.findMany({
          take: limit,
          orderBy: { createdAt: 'desc' },
          select: {
            id: true,
            displayName: true,
            email: true,
            createdAt: true,
          },
        }),
        this.prisma.activity.findMany({
          take: limit,
          orderBy: { completedAt: 'desc' },
          select: {
            id: true,
            taskName: true,
            pointsEarned: true,
            completedAt: true,
            user: { select: { displayName: true } },
          },
        }),
        this.prisma.redemption.findMany({
          take: limit,
          orderBy: { redeemedAt: 'desc' },
          select: {
            id: true,
            rewardTitle: true,
            pointsSpent: true,
            redeemedAt: true,
            user: { select: { displayName: true } },
          },
        }),
      ]);

    // Merge and sort all events by timestamp
    const events = [
      ...recentUsers.map((u) => ({
        type: 'user_registered' as const,
        description: `${u.displayName || u.email || 'Unknown'} registered`,
        userName: u.displayName || u.email || 'Unknown',
        timestamp: u.createdAt.toISOString(),
      })),
      ...recentActivities.map((a) => ({
        type: 'activity_completed' as const,
        description: `${a.user.displayName || 'User'} completed "${a.taskName}" (+${a.pointsEarned}pts)`,
        userName: a.user.displayName || 'User',
        timestamp: a.completedAt.toISOString(),
      })),
      ...recentRedemptions.map((r) => ({
        type: 'redemption' as const,
        description: `${r.user.displayName || 'User'} redeemed "${r.rewardTitle}" (-${r.pointsSpent}pts)`,
        userName: r.user.displayName || 'User',
        timestamp: r.redeemedAt.toISOString(),
      })),
    ];

    events.sort(
      (a, b) =>
        new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime(),
    );

    return events.slice(0, limit);
  }

  async getStreakStats() {
    const users = await this.prisma.user.findMany({
      select: { currentStreak: true },
    });

    const ranges = [
      { range: '0', min: 0, max: 0 },
      { range: '1-3', min: 1, max: 3 },
      { range: '4-7', min: 4, max: 7 },
      { range: '8-14', min: 8, max: 14 },
      { range: '15-30', min: 15, max: 30 },
      { range: '30+', min: 31, max: Infinity },
    ];

    const distribution = ranges.map(({ range, min, max }) => ({
      range,
      count: users.filter(
        (u) => u.currentStreak >= min && u.currentStreak <= max,
      ).length,
    }));

    const streaks = users.map((u) => u.currentStreak);
    const avgStreak =
      streaks.length > 0
        ? Math.round(
            (streaks.reduce((a, b) => a + b, 0) / streaks.length) * 10,
          ) / 10
        : 0;
    const maxStreak =
      streaks.length > 0 ? Math.max(...streaks) : 0;

    return { distribution, avgStreak, maxStreak };
  }

  async getLeaderboardPreview(limit = 5) {
    const activities = await this.prisma.activity.groupBy({
      by: ['userId'],
      _sum: { pointsEarned: true },
      orderBy: { _sum: { pointsEarned: 'desc' } },
      take: limit,
    });

    const userIds = activities.map((a) => a.userId);
    const users = await this.prisma.user.findMany({
      where: { id: { in: userIds } },
      select: { id: true, displayName: true, avatarId: true },
    });

    const userMap = new Map(users.map((u) => [u.id, u]));

    return activities.map((a, index) => {
      const user = userMap.get(a.userId);
      return {
        rank: index + 1,
        userId: a.userId,
        displayName: user?.displayName || 'Unknown',
        avatarId: user?.avatarId || null,
        totalPoints: a._sum.pointsEarned || 0,
      };
    });
  }

  /// Calculates the percentage change between current and previous
  /// values. Returns 0 if the previous value is 0.
  private calcTrendPercent(current: number, previous: number): number {
    if (previous === 0) return current > 0 ? 100 : 0;
    return Math.round(((current - previous) / previous) * 1000) / 10;
  }
}
