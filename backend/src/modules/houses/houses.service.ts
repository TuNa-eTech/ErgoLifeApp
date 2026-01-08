import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import {
  CreateHouseDto,
  HouseDto,
  HouseMemberDto,
  InviteDto,
  HousePreviewDto,
  LeaveHouseResponseDto,
} from './dto';

const MAX_HOUSE_MEMBERS = 4;
const APP_DEEP_LINK_BASE = 'https://ergolife.app/join';
const INVITE_CODE_LENGTH = 6;
const INVITE_CODE_CHARS = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // No I, O, 0, 1 to avoid confusion

// Generate a short, user-friendly invite code
function generateShortCode(length: number = INVITE_CODE_LENGTH): string {
  let code = '';
  for (let i = 0; i < length; i++) {
    code += INVITE_CODE_CHARS.charAt(
      Math.floor(Math.random() * INVITE_CODE_CHARS.length),
    );
  }
  return code;
}

@Injectable()
export class HousesService {
  constructor(private prisma: PrismaService) {}

  async create(
    userId: string,
    createHouseDto: CreateHouseDto,
  ): Promise<HouseDto> {
    // Check if user is already in a house
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { houseId: true },
    });

    if (user?.houseId) {
      throw new ConflictException({
        code: 'ALREADY_IN_HOUSE',
        message: 'You are already a member of another house',
      });
    }

    // Create house and update user in a transaction
    const house = await this.prisma.$transaction(async (tx) => {
      // Generate a unique short invite code
      let inviteCode: string;
      let isUnique = false;
      let attempts = 0;
      const maxAttempts = 10;

      while (!isUnique && attempts < maxAttempts) {
        inviteCode = generateShortCode();
        const existing = await tx.house.findUnique({
          where: { inviteCode },
        });
        isUnique = !existing;
        attempts++;
      }

      if (!isUnique) {
        throw new Error('Failed to generate unique invite code');
      }

      // Create the house with custom invite code
      const newHouse = await tx.house.create({
        data: {
          name: createHouseDto.name,
          createdById: userId,
          inviteCode: inviteCode!,
        },
        include: {
          members: {
            select: {
              id: true,
              displayName: true,
              avatarId: true,
              walletBalance: true,
            },
          },
        },
      });

      // Add user to the house
      await tx.user.update({
        where: { id: userId },
        data: { houseId: newHouse.id },
      });

      // Fetch updated house with member
      return tx.house.findUnique({
        where: { id: newHouse.id },
        include: {
          members: {
            select: {
              id: true,
              displayName: true,
              avatarId: true,
              walletBalance: true,
            },
          },
        },
      });
    });

    if (!house) {
      throw new Error('Failed to create house');
    }

    return this.mapToHouseDto(house);
  }

  async getMyHouse(userId: string): Promise<HouseDto> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { houseId: true },
    });

    if (!user?.houseId) {
      throw new NotFoundException({
        code: 'NOT_FOUND',
        message: 'You are not a member of any house',
      });
    }

    const house = await this.prisma.house.findUnique({
      where: { id: user.houseId },
      include: {
        members: {
          select: {
            id: true,
            displayName: true,
            avatarId: true,
            walletBalance: true,
          },
        },
      },
    });

    if (!house) {
      throw new NotFoundException({
        code: 'NOT_FOUND',
        message: 'House not found',
      });
    }

    return this.mapToHouseDto(house);
  }

  async getInvite(userId: string): Promise<InviteDto> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        house: {
          select: { inviteCode: true },
        },
      },
    });

    if (!user?.house) {
      throw new NotFoundException({
        code: 'NOT_FOUND',
        message: 'You are not a member of any house',
      });
    }

    return {
      inviteCode: user.house.inviteCode,
      deepLink: `${APP_DEEP_LINK_BASE}/${user.house.inviteCode}`,
    };
  }

  async join(userId: string, inviteCode: string): Promise<HouseDto> {
    // Check if user is already in a house
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        house: {
          select: { inviteCode: true },
        },
      },
    });

    if (user?.houseId) {
      // Check if trying to join own house
      if (user.house?.inviteCode === inviteCode) {
        throw new ConflictException({
          code: 'ALREADY_MEMBER',
          message: 'You are already a member of this house',
        });
      }
      throw new ConflictException({
        code: 'ALREADY_IN_HOUSE',
        message: 'You are already a member of another house',
      });
    }

    // Find house by invite code
    const house = await this.prisma.house.findUnique({
      where: { inviteCode },
      include: {
        members: {
          select: {
            id: true,
            displayName: true,
            avatarId: true,
          },
        },
      },
    });

    if (!house) {
      throw new NotFoundException({
        code: 'INVALID_INVITE',
        message: 'Invite code is invalid or expired',
      });
    }

    // Check if house is full
    if (house.members.length >= MAX_HOUSE_MEMBERS) {
      throw new ConflictException({
        code: 'HOUSE_FULL',
        message: `This house has reached the maximum of ${MAX_HOUSE_MEMBERS} members`,
      });
    }

    // Add user to house
    await this.prisma.user.update({
      where: { id: userId },
      data: { houseId: house.id },
    });

    // Fetch updated house
    const updatedHouse = await this.prisma.house.findUnique({
      where: { id: house.id },
      include: {
        members: {
          select: {
            id: true,
            displayName: true,
            avatarId: true,
            walletBalance: true,
          },
        },
      },
    });

    if (!updatedHouse) {
      throw new Error('Failed to fetch updated house');
    }

    return this.mapToHouseDto(updatedHouse);
  }

  async leave(userId: string): Promise<LeaveHouseResponseDto> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        house: {
          include: {
            members: { select: { id: true } },
          },
        },
      },
    });

    if (!user?.house) {
      throw new NotFoundException({
        code: 'NOT_FOUND',
        message: 'You are not a member of any house',
      });
    }

    const isLastMember = user.house.members.length === 1;
    const houseId = user.house.id;

    await this.prisma.$transaction(async (tx) => {
      // Remove user from house and reset wallet
      await tx.user.update({
        where: { id: userId },
        data: {
          houseId: null,
          walletBalance: 0,
        },
      });

      // If last member, delete the house and all related data
      if (isLastMember) {
        // Delete redemptions first (due to FK)
        await tx.redemption.deleteMany({
          where: { houseId },
        });
        // Delete rewards
        await tx.reward.deleteMany({
          where: { houseId },
        });
        // Delete activities
        await tx.activity.deleteMany({
          where: { houseId },
        });
        // Delete house
        await tx.house.delete({
          where: { id: houseId },
        });
      }
    });

    return {
      message: 'Successfully left the house',
      houseDeleted: isLastMember,
    };
  }

  async preview(inviteCode: string): Promise<HousePreviewDto> {
    const house = await this.prisma.house.findUnique({
      where: { inviteCode },
      include: {
        members: {
          select: { avatarId: true },
        },
      },
    });

    if (!house) {
      throw new NotFoundException({
        code: 'INVALID_INVITE',
        message: 'Invite code is invalid or expired',
      });
    }

    return {
      name: house.name,
      memberCount: house.members.length,
      isFull: house.members.length >= MAX_HOUSE_MEMBERS,
      memberAvatars: house.members.map((m) => m.avatarId),
    };
  }

  private mapToHouseDto(house: {
    id: string;
    name: string;
    inviteCode: string;
    createdById: string;
    createdAt: Date;
    members: {
      id: string;
      displayName: string | null;
      avatarId: number | null;
      walletBalance?: number;
    }[];
  }): HouseDto {
    return {
      id: house.id,
      name: house.name,
      inviteCode: house.inviteCode,
      createdBy: house.createdById,
      members: house.members.map((m) => ({
        id: m.id,
        displayName: m.displayName,
        avatarId: m.avatarId,
        walletBalance: m.walletBalance,
      })),
      memberCount: house.members.length,
      createdAt: house.createdAt,
    };
  }
}
