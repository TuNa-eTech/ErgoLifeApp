import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class AdminStatsService {
  constructor(private prisma: PrismaService) {}

  async getDashboardStats() {
    const totalUsers = await this.prisma.user.count();
    const totalHouses = await this.prisma.house.count();
    const totalActivities = await this.prisma.activity.count();

    // Active users in last 7 days
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const activeUsers = await this.prisma.user.count({
      where: {
        lastActivityDate: {
          gte: sevenDaysAgo,
        },
      },
    });

    return {
      totalUsers,
      totalHouses,
      totalActivities,
      activeUsers,
    };
  }

  async getGrowthStats() {
    // Group users by creation date (simple version: last 30 days)
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const users = await this.prisma.user.findMany({
      where: {
        createdAt: {
          gte: thirtyDaysAgo,
        },
      },
      select: {
        createdAt: true,
      },
      orderBy: {
        createdAt: 'asc',
      },
    });

    // Process in memory for simplicity (or use raw query for DB grouping)
    // We'll return raw list for frontend to group or simple daily counts
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
}
