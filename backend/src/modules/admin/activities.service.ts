import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class AdminActivitiesService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(
    page: number,
    limit: number,
    userId?: string,
    houseId?: string,
    from?: string,
    to?: string,
  ) {
    const where: any = {};
    if (userId) where.userId = userId;
    if (houseId) where.houseId = houseId;
    if (from || to) {
      where.completedAt = {};
      if (from) where.completedAt.gte = new Date(from);
      if (to) where.completedAt.lte = new Date(to);
    }

    const [data, total] = await Promise.all([
      this.prisma.activity.findMany({
        where,
        include: {
          user: {
            select: {
              id: true,
              displayName: true,
              email: true,
            },
          },
          house: { select: { id: true, name: true } },
        },
        orderBy: { completedAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.activity.count({ where }),
    ]);

    return {
      data,
      meta: {
        total,
        page,
        limit,
        pages: Math.ceil(total / limit),
      },
    };
  }
}
