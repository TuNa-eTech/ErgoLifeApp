import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { RedemptionStatus } from '@prisma/client';

@Injectable()
export class AdminRedemptionsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(
    page: number,
    limit: number,
    status?: string,
    userId?: string,
  ) {
    const where: any = {};
    if (status) where.status = status;
    if (userId) where.userId = userId;

    const [data, total] = await Promise.all([
      this.prisma.redemption.findMany({
        where,
        include: {
          user: {
            select: {
              id: true,
              displayName: true,
              email: true,
            },
          },
          reward: {
            select: {
              id: true,
              title: true,
              cost: true,
              icon: true,
            },
          },
          house: { select: { id: true, name: true } },
        },
        orderBy: { redeemedAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.redemption.count({ where }),
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

  async updateStatus(id: string, status: string) {
    const redemption = await this.prisma.redemption.findUnique({
      where: { id },
    });

    if (!redemption) {
      throw new NotFoundException('Redemption not found');
    }

    const data: any = {
      status: status as RedemptionStatus,
    };

    if (status === 'USED') {
      data.usedAt = new Date();
    }

    return this.prisma.redemption.update({
      where: { id },
      data,
      include: {
        user: {
          select: {
            id: true,
            displayName: true,
          },
        },
        reward: {
          select: { id: true, title: true },
        },
      },
    });
  }
}
