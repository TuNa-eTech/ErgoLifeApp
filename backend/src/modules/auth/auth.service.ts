import {
  Injectable,
  UnauthorizedException,
  Logger,
  InternalServerErrorException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../../prisma/prisma.service';
import { FirebaseService, FirebaseUserInfo } from '../../firebase';
import { AuthProvider, User } from '@prisma/client';
import { getAvatarUrl } from '../../common/utils/avatar.utils';
import {
  AuthResponseDto,
  UserDto,
  HouseSummaryDto,
  LogoutResponseDto,
} from './dto';
import { HousesService } from '../../modules/houses/houses.service';

export interface JwtPayload {
  sub: string; // User ID
  firebaseUid: string;
  email: string | null;
}

type UserWithHouse = User & {
  house: {
    id: string;
    name: string;
    members: { id: string }[];
  } | null;
};

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly firebaseService: FirebaseService,
    private readonly prismaService: PrismaService,
    private readonly jwtService: JwtService,
    private readonly housesService: HousesService,
  ) {}

  async socialLogin(idToken: string): Promise<AuthResponseDto> {
    // 1. Verify Firebase ID Token
    let firebaseUserInfo: FirebaseUserInfo;
    try {
      const decodedToken = await this.firebaseService.verifyIdToken(idToken);
      firebaseUserInfo = this.firebaseService.extractUserInfo(decodedToken);
    } catch (error) {
      this.logger.error('Invalid Firebase ID token', error);
      throw new UnauthorizedException('Invalid ID token');
    }

    // 2. Determine provider
    const provider = this.mapProvider(firebaseUserInfo.provider);

    // 3. Check if user exists
    const existingUser = await this.prismaService.user.findUnique({
      where: { firebaseUid: firebaseUserInfo.uid },
    });
    const isNewUser = !existingUser;

    // 4. Upsert user in database
    let user: UserWithHouse;
    try {
      user = await this.prismaService.user.upsert({
        where: { firebaseUid: firebaseUserInfo.uid },
        update: {
          email: firebaseUserInfo.email,
          displayName: existingUser?.displayName || firebaseUserInfo.name,
        },
        create: {
          firebaseUid: firebaseUserInfo.uid,
          provider,
          email: firebaseUserInfo.email,
          displayName: firebaseUserInfo.name,
        },
        include: {
          house: {
            include: {
              members: {
                select: { id: true },
              },
            },
          },
        },
      });
    } catch (error) {
      this.logger.error('Failed to upsert user', error);
      throw new InternalServerErrorException('Failed to create or update user');
    }

    // 4.5 Ensure user has a house (Personal House)
    if (!user.houseId) {
      try {
        await this.housesService.createPersonalHouse(user.id);
        // Refresh user data with house
        const updatedUser = await this.prismaService.user.findUnique({
          where: { id: user.id },
          include: {
            house: {
              include: {
                members: {
                  select: { id: true },
                },
              },
            },
          },
        });
        if (updatedUser) {
          user = updatedUser;
        }
      } catch (error) {
        this.logger.error('Failed to create personal house', error);
        // Don't fail login if house creation fails, but log it
      }
    }

    // 5. Generate JWT token
    const payload: JwtPayload = {
      sub: user.id,
      firebaseUid: user.firebaseUid,
      email: user.email,
    };
    const accessToken = this.jwtService.sign(payload);

    // 6. Return response
    return {
      accessToken,
      user: this.mapUserToDto(user),
      isNewUser,
    };
  }

  async getMe(userId: string): Promise<UserDto> {
    const user = await this.prismaService.user.findUnique({
      where: { id: userId },
      include: {
        house: {
          include: {
            members: {
              select: { id: true },
            },
          },
        },
      },
    });

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    return this.mapUserToDto(user);
  }

  async logout(userId: string): Promise<LogoutResponseDto> {
    // Clear FCM token on logout
    await this.prismaService.user.update({
      where: { id: userId },
      data: { fcmToken: null },
    });

    return { message: 'Logged out successfully' };
  }

  /**
   * Delete user account and all associated data.
   * This permanently removes the user from the system.
   */
  async deleteAccount(userId: string): Promise<{ message: string }> {
    // Get user info including Firebase UID
    const user = await this.prismaService.user.findUnique({
      where: { id: userId },
      include: {
        house: {
          include: {
            members: { select: { id: true } },
          },
        },
        housesOwned: {
          include: {
            members: { select: { id: true } },
          },
        },
      },
    });

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    const firebaseUid = user.firebaseUid;

    // Use transaction to delete all data atomically
    await this.prismaService.$transaction(async (tx) => {
      // 1. Delete user's activities
      await tx.activity.deleteMany({
        where: { userId },
      });

      // 2. Delete user's custom tasks
      await tx.customTask.deleteMany({
        where: { userId },
      });

      // 3. Delete user's redemptions
      await tx.redemption.deleteMany({
        where: { userId },
      });

      // 4. Handle houses owned by user
      for (const house of user.housesOwned) {
        if (house.members.length <= 1) {
          // User is the only member, delete house and related data
          await tx.redemption.deleteMany({ where: { houseId: house.id } });
          await tx.activity.deleteMany({ where: { houseId: house.id } });
          await tx.reward.deleteMany({ where: { houseId: house.id } });
          await tx.house.delete({ where: { id: house.id } });
        } else {
          // Transfer ownership to another member
          const newOwner = house.members.find((m) => m.id !== userId);
          if (newOwner) {
            await tx.house.update({
              where: { id: house.id },
              data: { createdById: newOwner.id },
            });
          }
        }
      }

      // 5. Delete rewards created by user (but not redeemed)
      await tx.reward.deleteMany({
        where: {
          creatorId: userId,
          redemptions: { none: {} },
        },
      });

      // 6. Update rewards created by user that have been redeemed
      // Keep them for history but mark as deleted (optional: set to system user)
      // For simplicity, we keep them as-is since redemptions reference the reward

      // 7. Remove user from current house (if not owner of that house)
      if (user.houseId) {
        await tx.user.update({
          where: { id: userId },
          data: { houseId: null },
        });
      }

      // 8. Delete user from database
      await tx.user.delete({
        where: { id: userId },
      });
    });

    // 9. Delete user from Firebase Authentication
    try {
      await this.firebaseService.deleteUser(firebaseUid);
    } catch (error) {
      // Log but don't fail - user is already deleted from database
      this.logger.error(
        `Failed to delete Firebase user ${firebaseUid}, but database deletion succeeded`,
        error,
      );
    }

    this.logger.log(`Successfully deleted account for user: ${userId}`);

    return { message: 'Account deleted successfully' };
  }

  private mapProvider(provider: 'google.com' | 'apple.com'): AuthProvider {
    switch (provider) {
      case 'google.com':
        return AuthProvider.GOOGLE;
      case 'apple.com':
        return AuthProvider.APPLE;
      default:
        return AuthProvider.GOOGLE;
    }
  }

  private mapUserToDto(user: UserWithHouse): UserDto {
    let house: HouseSummaryDto | null = null;
    if (user.house) {
      house = {
        id: user.house.id,
        name: user.house.name,
        memberCount: user.house.members.length,
      };
    }

    return {
      id: user.id,
      firebaseUid: user.firebaseUid,
      provider: user.provider,
      email: user.email,
      displayName: user.displayName,
      avatarId: user.avatarId,
      avatarUrl: getAvatarUrl(user.avatarId),
      houseId: user.houseId,
      walletBalance: user.walletBalance,
      currentStreak: user.currentStreak,
      longestStreak: user.longestStreak,
      streakFreezeCount: user.streakFreezeCount,
      house,
    };
  }
}
