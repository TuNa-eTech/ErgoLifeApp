import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { RedemptionStatus } from '@prisma/client';
import {
  GetRedemptionsQueryDto,
  GetRedemptionsResponseDto,
  UseRedemptionResponseDto,
} from './dto';

@Injectable()
export class RedemptionsService {
  constructor(private prisma: PrismaService) {}

  async findAll(
    userId: string,
    query: GetRedemptionsQueryDto,
  ): Promise<GetRedemptionsResponseDto> {
    const { status, page = 1, limit = 20 } = query;
    const skip = (page - 1) * limit;

    // Build where clause
    const where: { userId: string; status?: RedemptionStatus } = { userId };
    if (status && status !== 'all') {
      where.status = status as RedemptionStatus;
    }

    const [redemptions, total] = await Promise.all([
      this.prisma.redemption.findMany({
        where,
        skip,
        take: limit,
        orderBy: { redeemedAt: 'desc' },
      }),
      this.prisma.redemption.count({ where }),
    ]);

    return {
      items: redemptions.map((r) => ({
        id: r.id,
        rewardTitle: r.rewardTitle,
        pointsSpent: r.pointsSpent,
        status: r.status,
        redeemedAt: r.redeemedAt,
        usedAt: r.usedAt,
      })),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async markAsUsed(
    userId: string,
    redemptionId: string,
  ): Promise<UseRedemptionResponseDto> {
    // Get the redemption
    const redemption = await this.prisma.redemption.findUnique({
      where: { id: redemptionId },
      include: {
        house: {
          include: {
            members: { select: { id: true } },
          },
        },
      },
    });

    if (!redemption) {
      throw new NotFoundException({
        code: 'NOT_FOUND',
        message: 'Redemption not found',
      });
    }

    // Check if user is in the same house
    const isMember = redemption.house.members.some((m) => m.id === userId);
    if (!isMember) {
      throw new ForbiddenException({
        code: 'FORBIDDEN',
        message: 'You can only mark redemptions in your house as used',
      });
    }

    // Check if already used
    if (redemption.status === RedemptionStatus.USED) {
      throw new BadRequestException({
        code: 'BAD_REQUEST',
        message: 'This redemption has already been used',
      });
    }

    // Update status
    const updated = await this.prisma.redemption.update({
      where: { id: redemptionId },
      data: {
        status: RedemptionStatus.USED,
        usedAt: new Date(),
      },
    });

    return {
      id: updated.id,
      status: updated.status,
      usedAt: updated.usedAt!,
    };
  }
}
