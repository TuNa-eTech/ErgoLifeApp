import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import {
  CreateRewardDto,
  UpdateRewardDto,
  GetRewardsQueryDto,
  GetRewardsResponseDto,
  RewardDto,
  DeleteRewardResponseDto,
  RedeemRewardResponseDto,
} from './dto';
import { RedemptionStatus } from '@prisma/client';

@Injectable()
export class RewardsService {
  constructor(private prisma: PrismaService) {}

  async findAll(
    userId: string,
    query: GetRewardsQueryDto,
  ): Promise<GetRewardsResponseDto> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { houseId: true, walletBalance: true },
    });

    if (!user?.houseId) {
      throw new ForbiddenException({
        code: 'FORBIDDEN',
        message: 'You must be in a house to view rewards',
      });
    }

    const where = {
      houseId: user.houseId,
      ...(query.activeOnly !== false && { isActive: true }),
    };

    const rewards = await this.prisma.reward.findMany({
      where,
      include: {
        creator: {
          select: { id: true, displayName: true },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    return {
      rewards: rewards.map((r) => this.mapToRewardDto(r)),
      userBalance: user.walletBalance,
    };
  }

  async create(
    userId: string,
    createRewardDto: CreateRewardDto,
  ): Promise<RewardDto> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { houseId: true },
    });

    if (!user?.houseId) {
      throw new ForbiddenException({
        code: 'FORBIDDEN',
        message: 'You must be in a house to create rewards',
      });
    }

    const reward = await this.prisma.reward.create({
      data: {
        houseId: user.houseId,
        creatorId: userId,
        title: createRewardDto.title,
        cost: createRewardDto.cost,
        icon: createRewardDto.icon,
        description: createRewardDto.description,
      },
      include: {
        creator: {
          select: { id: true, displayName: true },
        },
      },
    });

    return this.mapToRewardDto(reward);
  }

  async update(
    userId: string,
    rewardId: string,
    updateRewardDto: UpdateRewardDto,
  ): Promise<RewardDto> {
    const reward = await this.prisma.reward.findUnique({
      where: { id: rewardId },
      include: {
        house: { select: { createdById: true } },
      },
    });

    if (!reward) {
      throw new NotFoundException({
        code: 'NOT_FOUND',
        message: 'Reward not found',
      });
    }

    // Only creator or house owner can update
    if (reward.creatorId !== userId && reward.house.createdById !== userId) {
      throw new ForbiddenException({
        code: 'FORBIDDEN',
        message: 'Only the creator or house owner can update this reward',
      });
    }

    const updated = await this.prisma.reward.update({
      where: { id: rewardId },
      data: updateRewardDto,
      include: {
        creator: {
          select: { id: true, displayName: true },
        },
      },
    });

    return this.mapToRewardDto(updated);
  }

  async remove(
    userId: string,
    rewardId: string,
  ): Promise<DeleteRewardResponseDto> {
    const reward = await this.prisma.reward.findUnique({
      where: { id: rewardId },
      include: {
        house: { select: { createdById: true } },
      },
    });

    if (!reward) {
      throw new NotFoundException({
        code: 'NOT_FOUND',
        message: 'Reward not found',
      });
    }

    // Only creator or house owner can delete
    if (reward.creatorId !== userId && reward.house.createdById !== userId) {
      throw new ForbiddenException({
        code: 'FORBIDDEN',
        message: 'Only the creator or house owner can delete this reward',
      });
    }

    // Soft delete
    await this.prisma.reward.update({
      where: { id: rewardId },
      data: { isActive: false },
    });

    return { message: 'Reward deleted successfully' };
  }

  async redeem(
    userId: string,
    rewardId: string,
  ): Promise<RedeemRewardResponseDto> {
    // Get user and reward
    const [user, reward] = await Promise.all([
      this.prisma.user.findUnique({
        where: { id: userId },
        select: { id: true, houseId: true, walletBalance: true },
      }),
      this.prisma.reward.findUnique({
        where: { id: rewardId },
        select: {
          id: true,
          houseId: true,
          title: true,
          cost: true,
          isActive: true,
        },
      }),
    ]);

    if (!user?.houseId) {
      throw new ForbiddenException({
        code: 'FORBIDDEN',
        message: 'You must be in a house to redeem rewards',
      });
    }

    if (!reward) {
      throw new NotFoundException({
        code: 'REWARD_NOT_FOUND',
        message: 'Reward not found',
      });
    }

    if (!reward.isActive) {
      throw new NotFoundException({
        code: 'REWARD_NOT_FOUND',
        message: 'This reward is no longer available',
      });
    }

    if (reward.houseId !== user.houseId) {
      throw new ForbiddenException({
        code: 'FORBIDDEN',
        message: 'This reward is not from your house',
      });
    }

    if (user.walletBalance < reward.cost) {
      const needed = reward.cost - user.walletBalance;
      throw new BadRequestException({
        code: 'INSUFFICIENT_BALANCE',
        message: `You need ${needed} more points to redeem this reward`,
      });
    }

    // Execute transaction
    const result = await this.prisma.$transaction(async (tx) => {
      // Deduct points
      const updatedUser = await tx.user.update({
        where: { id: userId },
        data: {
          walletBalance: { decrement: reward.cost },
        },
        select: { walletBalance: true },
      });

      // Create redemption
      const redemption = await tx.redemption.create({
        data: {
          userId,
          rewardId: reward.id,
          houseId: user.houseId!,
          rewardTitle: reward.title,
          pointsSpent: reward.cost,
          status: RedemptionStatus.USED,
        },
      });

      return { redemption, newBalance: updatedUser.walletBalance };
    });

    return {
      redemption: {
        id: result.redemption.id,
        rewardTitle: result.redemption.rewardTitle,
        pointsSpent: result.redemption.pointsSpent,
        status: result.redemption.status,
        redeemedAt: result.redemption.redeemedAt,
      },
      wallet: {
        previousBalance: user.walletBalance,
        pointsSpent: reward.cost,
        newBalance: result.newBalance,
      },
    };
  }

  private mapToRewardDto(reward: {
    id: string;
    title: string;
    cost: number;
    icon: string;
    description: string | null;
    isActive: boolean;
    createdAt: Date;
    creator: { id: string; displayName: string | null };
  }): RewardDto {
    return {
      id: reward.id,
      title: reward.title,
      cost: reward.cost,
      icon: reward.icon,
      description: reward.description,
      creator: {
        id: reward.creator.id,
        displayName: reward.creator.displayName,
      },
      isActive: reward.isActive,
      createdAt: reward.createdAt,
    };
  }
}
