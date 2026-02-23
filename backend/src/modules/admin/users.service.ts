import {
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { FirebaseService } from '../../firebase';

@Injectable()
export class AdminUsersService {
  private readonly logger = new Logger(AdminUsersService.name);

  constructor(
    private prisma: PrismaService,
    private firebaseService: FirebaseService,
  ) {}

  async findAll(page: number = 1, limit: number = 20, search?: string) {
    const skip = (page - 1) * limit;

    const where: any = {};
    if (search) {
      where.OR = [
        { email: { contains: search, mode: 'insensitive' } },
        { displayName: { contains: search, mode: 'insensitive' } },
        { firebaseUid: { contains: search } },
      ];
    }

    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.user.count({ where }),
    ]);

    return {
      data: users,
      meta: {
        total,
        page,
        limit,
        pages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      include: {
        housesOwned: true,
        house: true,
        _count: {
          select: { activities: true, redemptions: true },
        },
      },
    });

    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }

    return user;
  }

  /// Permanently deletes a user and all associated data.
  async deleteUser(id: string): Promise<{ message: string }> {
    const user = await this.prisma.user.findUnique({
      where: { id },
      include: {
        housesOwned: {
          include: {
            members: { select: { id: true } },
          },
        },
      },
    });

    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }

    const firebaseUid = user.firebaseUid;

    await this.prisma.$transaction(async (tx) => {
      // 1. Delete notifications (onDelete: Cascade exists but
      //    we delete explicitly for clarity)
      await tx.notification.deleteMany({ where: { userId: id } });

      // 2. Delete badges
      await tx.userBadge.deleteMany({ where: { userId: id } });

      // 3. Delete daily goals & goal settings
      await tx.dailyGoal.deleteMany({ where: { userId: id } });
      await tx.userGoalSettings.deleteMany({ where: { userId: id } });

      // 4. Delete gift transactions (sent & received)
      await tx.giftTransaction.deleteMany({
        where: { OR: [{ senderId: id }, { receiverId: id }] },
      });

      // 5. Delete activities
      await tx.activity.deleteMany({ where: { userId: id } });

      // 6. Delete custom tasks
      await tx.customTask.deleteMany({ where: { userId: id } });

      // 7. Delete redemptions
      await tx.redemption.deleteMany({ where: { userId: id } });

      // 8. Handle houses owned by user
      for (const house of user.housesOwned) {
        if (house.members.length <= 1) {
          // User is the only member — delete house and its data
          await tx.redemption.deleteMany({
            where: { houseId: house.id },
          });
          await tx.activity.deleteMany({
            where: { houseId: house.id },
          });
          await tx.giftTransaction.deleteMany({
            where: { houseId: house.id },
          });
          await tx.reward.deleteMany({
            where: { houseId: house.id },
          });
          await tx.house.delete({ where: { id: house.id } });
        } else {
          // Transfer ownership to another member
          const newOwner = house.members.find(
            (m) => m.id !== id,
          );
          if (newOwner) {
            await tx.house.update({
              where: { id: house.id },
              data: { createdById: newOwner.id },
            });
          }
        }
      }

      // 9. Delete rewards created by user (unredeemed only)
      await tx.reward.deleteMany({
        where: {
          creatorId: id,
          redemptions: { none: {} },
        },
      });

      // 10. Remove from current house
      if (user.houseId) {
        await tx.user.update({
          where: { id },
          data: { houseId: null },
        });
      }

      // 11. Delete the user record
      await tx.user.delete({ where: { id } });
    });

    // 12. Delete Firebase account
    try {
      await this.firebaseService.deleteUser(firebaseUid);
    } catch (error) {
      this.logger.error(
        `Failed to delete Firebase user ${firebaseUid}`,
        error,
      );
    }

    this.logger.log(`Admin deleted user: ${id}`);
    return { message: 'User deleted successfully' };
  }
}
