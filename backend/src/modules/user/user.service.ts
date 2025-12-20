import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { UpdateProfileDto, UserProfileDto, OtherUserDto, FcmTokenResponseDto } from './dto';

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
      throw new ForbiddenException('You must be in a house to view other users');
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
}
