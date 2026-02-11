import {
  Injectable,
  Logger,
  BadRequestException,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { NotificationType } from '@prisma/client';
import {
  SendGiftDto,
  GetGiftHistoryQueryDto,
  GetGiftCatalogQueryDto,
  GiftCatalogResponseDto,
  GiftRewardDto,
  HouseMemberDto,
  SendGiftResponseDto,
  GiftTransactionDto,
  GiftHistoryResponseDto,
} from './dto';

@Injectable()
export class GiftsService {
  private readonly logger = new Logger(GiftsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly notificationsService: NotificationsService,
  ) {}

  /**
   * Get gift rewards catalog with user balance and house members
   */
  async getCatalog(
    userId: string,
    query: GetGiftCatalogQueryDto,
  ): Promise<GiftCatalogResponseDto> {
    const locale = query.locale || 'vi';

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        walletBalance: true,
        houseId: true,
      },
    });

    if (!user?.houseId) {
      throw new BadRequestException('You must be in a house to view gifts');
    }

    // Fetch active gift rewards with translations
    const rewards = await this.prisma.giftReward.findMany({
      where: { isActive: true },
      include: {
        translations: {
          where: { locale },
        },
      },
      orderBy: [
        { category: 'asc' },
        { sortOrder: 'asc' },
      ],
    });

    // Fallback to 'en' if no translation found for requested locale
    const rewardsWithFallback = await Promise.all(
      rewards.map(async (reward) => {
        let translation = reward.translations[0];
        if (!translation && locale !== 'en') {
          const fallback = await this.prisma.giftRewardTranslation.findUnique({
            where: {
              rewardId_locale: {
                rewardId: reward.id,
                locale: 'en',
              },
            },
          });
          translation = fallback;
        }

        return this.mapToGiftRewardDto(reward, translation);
      }),
    );

    // Fetch house members (excluding current user)
    const houseMembers = await this.prisma.user.findMany({
      where: {
        houseId: user.houseId,
        id: { not: userId },
      },
      select: {
        id: true,
        displayName: true,
        avatarId: true,
      },
    });

    return {
      rewards: rewardsWithFallback,
      userBalance: user.walletBalance,
      houseMembers: houseMembers.map(
        (m): HouseMemberDto => ({
          id: m.id,
          displayName: m.displayName,
          avatarId: m.avatarId,
        }),
      ),
    };
  }

  /**
   * Send a gift to another house member
   */
  async sendGift(
    userId: string,
    dto: SendGiftDto,
  ): Promise<SendGiftResponseDto> {
    // 1. Validate sender
    const sender = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        displayName: true,
        walletBalance: true,
        houseId: true,
      },
    });

    if (!sender?.houseId) {
      throw new BadRequestException('You must be in a house to send gifts');
    }

    // 2. Validate not sending to self
    if (userId === dto.receiverId) {
      throw new BadRequestException('You cannot send a gift to yourself');
    }

    // 3. Validate receiver is in same house
    const receiver = await this.prisma.user.findUnique({
      where: { id: dto.receiverId },
      select: {
        id: true,
        displayName: true,
        houseId: true,
      },
    });

    if (!receiver) {
      throw new NotFoundException('Receiver not found');
    }

    if (receiver.houseId !== sender.houseId) {
      throw new ForbiddenException(
        'Receiver must be in the same house',
      );
    }

    // 4. Validate gift reward exists
    const snapshotLocale = dto.locale || 'vi';
    const giftReward = await this.prisma.giftReward.findUnique({
      where: { id: dto.giftRewardId },
      include: {
        translations: {
          where: { locale: snapshotLocale },
        },
      },
    });

    if (!giftReward || !giftReward.isActive) {
      throw new NotFoundException('Gift reward not found or inactive');
    }

    // 5. Check balance (preliminary — authoritative check inside transaction)
    if (sender.walletBalance < giftReward.cost) {
      throw new BadRequestException(
        `Insufficient balance. Need ${giftReward.cost} EP, have ${sender.walletBalance} EP`,
      );
    }

    // Get reward name for snapshot
    const rewardName =
      giftReward.translations[0]?.name || giftReward.key;

    // 6. Transaction: re-check balance + deduct EP + create gift
    const { giftTransaction, previousBalance } =
      await this.prisma.$transaction(async (tx) => {
        // Re-read sender balance inside transaction for consistency
        const freshSender = await tx.user.findUniqueOrThrow({
          where: { id: userId },
          select: { walletBalance: true },
        });

        if (freshSender.walletBalance < giftReward.cost) {
          throw new BadRequestException(
            `Insufficient balance. Need ${giftReward.cost} EP, have ${freshSender.walletBalance} EP`,
          );
        }

        const prevBalance = freshSender.walletBalance;

        // Deduct points from sender
        await tx.user.update({
          where: { id: userId },
          data: {
            walletBalance: { decrement: giftReward.cost },
          },
        });

        // Create gift transaction
        const giftTx = await tx.giftTransaction.create({
          data: {
            senderId: userId,
            receiverId: dto.receiverId,
            houseId: sender.houseId,
            rewardId: giftReward.id,
            rewardName,
            rewardIcon: giftReward.icon,
            pointsSpent: giftReward.cost,
            message: dto.message || null,
          },
          include: {
            sender: { select: { displayName: true } },
            receiver: { select: { displayName: true } },
          },
        });

        return { giftTransaction: giftTx, previousBalance: prevBalance };
      });

    // 7. Send push notification to receiver (non-blocking)
    this.sendGiftNotification(
      sender.displayName,
      dto.receiverId,
      rewardName,
      giftReward.icon,
      dto.message,
    ).catch((error) => {
      this.logger.error(
        `Failed to send gift notification: ${error.message}`,
      );
    });

    this.logger.log(
      `Gift sent: ${sender.displayName} → ${receiver.displayName} (${rewardName})`,
    );

    return {
      transaction: {
        id: giftTransaction.id,
        senderId: giftTransaction.senderId,
        senderName: giftTransaction.sender.displayName,
        receiverId: giftTransaction.receiverId,
        receiverName: giftTransaction.receiver.displayName,
        rewardName: giftTransaction.rewardName,
        rewardIcon: giftTransaction.rewardIcon,
        pointsSpent: giftTransaction.pointsSpent,
        message: giftTransaction.message,
        createdAt: giftTransaction.createdAt,
      },
      wallet: {
        previousBalance,
        pointsSpent: giftReward.cost,
        newBalance: previousBalance - giftReward.cost,
      },
    };
  }

  /**
   * Get gift history (sent and/or received)
   */
  async getHistory(
    userId: string,
    query: GetGiftHistoryQueryDto,
  ): Promise<GiftHistoryResponseDto> {
    const page = query.page || 1;
    const limit = query.limit || 20;
    const skip = (page - 1) * limit;

    // Build where clause based on filter type
    const where: any = {};
    if (query.type === 'sent') {
      where.senderId = userId;
    } else if (query.type === 'received') {
      where.receiverId = userId;
    } else {
      // Both sent and received
      where.OR = [
        { senderId: userId },
        { receiverId: userId },
      ];
    }

    const [transactions, total] = await Promise.all([
      this.prisma.giftTransaction.findMany({
        where,
        include: {
          sender: { select: { displayName: true } },
          receiver: { select: { displayName: true } },
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      this.prisma.giftTransaction.count({ where }),
    ]);

    return {
      gifts: transactions.map(
        (t): GiftTransactionDto => ({
          id: t.id,
          senderId: t.senderId,
          senderName: t.sender.displayName,
          receiverId: t.receiverId,
          receiverName: t.receiver.displayName,
          rewardName: t.rewardName,
          rewardIcon: t.rewardIcon,
          pointsSpent: t.pointsSpent,
          message: t.message,
          createdAt: t.createdAt,
        }),
      ),
      total,
      hasMore: skip + transactions.length < total,
    };
  }

  // ===== Private Helpers =====

  private mapToGiftRewardDto(
    reward: any,
    translation: any,
  ): GiftRewardDto {
    return {
      id: reward.id,
      key: reward.key,
      category: reward.category,
      icon: reward.icon,
      cost: reward.cost,
      name: translation?.name || reward.key,
      description: translation?.description || null,
    };
  }

  private async sendGiftNotification(
    senderName: string | null,
    receiverId: string,
    rewardName: string,
    rewardIcon: string,
    message?: string,
  ): Promise<void> {
    const title = `${senderName || 'Someone'} sent you a gift! 🎁`;
    const body = message
      ? `${rewardIcon} ${rewardName} — "${message}"`
      : `${rewardIcon} ${rewardName}`;

    await this.notificationsService.createNotification({
      userId: receiverId,
      type: NotificationType.GIFT_RECEIVED,
      title,
      body,
      data: { rewardName, rewardIcon },
    });
  }
}
