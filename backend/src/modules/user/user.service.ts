import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import {
  UpdateProfileDto,
  UserProfileDto,
  OtherUserDto,
  FcmTokenResponseDto,
} from './dto';

@Injectable()
export class UserService {
  constructor(private prisma: PrismaService) {}

  async updateProfile(
    userId: string,
    updateProfileDto: UpdateProfileDto,
  ): Promise<UserProfileDto> {
    const user = await this.prisma.user.update({
      where: { id: userId },
      data: {
        displayName: updateProfileDto.displayName,
        avatarId: updateProfileDto.avatarId,
      },
    });

    return {
      id: user.id,
      displayName: user.displayName,
      avatarId: user.avatarId,
      email: user.email,
      walletBalance: user.walletBalance,
      houseId: user.houseId,
    };
  }

  async updateFcmToken(
    userId: string,
    fcmToken: string,
  ): Promise<FcmTokenResponseDto> {
    await this.prisma.user.update({
      where: { id: userId },
      data: { fcmToken },
    });

    return { message: 'FCM token updated successfully' };
  }

  async getUserById(
    currentUserId: string,
    targetUserId: string,
  ): Promise<OtherUserDto> {
    // Get current user to check their house
    const currentUser = await this.prisma.user.findUnique({
      where: { id: currentUserId },
      select: { houseId: true },
    });

    if (!currentUser || !currentUser.houseId) {
      throw new ForbiddenException(
        'You must be in a house to view other users',
      );
    }

    // Get target user
    const targetUser = await this.prisma.user.findUnique({
      where: { id: targetUserId },
      select: {
        id: true,
        displayName: true,
        avatarId: true,
        walletBalance: true,
        houseId: true,
      },
    });

    if (!targetUser) {
      throw new NotFoundException('User not found');
    }

    // Check if they are in the same house
    if (targetUser.houseId !== currentUser.houseId) {
      throw new ForbiddenException('You can only view users in your house');
    }

    return {
      id: targetUser.id,
      displayName: targetUser.displayName,
      avatarId: targetUser.avatarId,
      walletBalance: targetUser.walletBalance,
    };
  }

  async purchaseStreakFreeze(userId: string): Promise<{
    message: string;
    walletBalance: number;
    streakFreezeCount: number;
  }> {
    const STREAK_FREEZE_COST = 500;
    const MAX_STREAK_FREEZE = 2;

    // Get user with current streak freeze count and wallet balance
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        streakFreezeCount: true,
        walletBalance: true,
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Validation: Check if already at max
    if (user.streakFreezeCount >= MAX_STREAK_FREEZE) {
      throw new ForbiddenException({
        code: 'MAX_FREEZE_REACHED',
        message: `You already have the maximum number of Streak Freezes (${MAX_STREAK_FREEZE})`,
      });
    }

    // Validation: Check if sufficient balance
    if (user.walletBalance < STREAK_FREEZE_COST) {
      throw new ForbiddenException({
        code: 'INSUFFICIENT_POINTS',
        message: `You need ${STREAK_FREEZE_COST} EP to purchase a Streak Freeze. Current balance: ${user.walletBalance} EP`,
      });
    }

    // Perform purchase: Deduct points and add freeze
    const updatedUser = await this.prisma.user.update({
      where: { id: userId },
      data: {
        walletBalance: { decrement: STREAK_FREEZE_COST },
        streakFreezeCount: { increment: 1 },
      },
      select: {
        walletBalance: true,
        streakFreezeCount: true,
      },
    });

    return {
      message: 'Streak Freeze purchased successfully',
      walletBalance: updatedUser.walletBalance,
      streakFreezeCount: updatedUser.streakFreezeCount,
    };
  }
}
