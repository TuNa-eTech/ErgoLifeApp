import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { GiftRewardCategory } from '@prisma/client';

@Injectable()
export class AdminGiftRewardsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.giftReward.findMany({
      include: {
        translations: true,
        _count: { select: { transactions: true } },
      },
      orderBy: { sortOrder: 'asc' },
    });
  }

  async findOne(id: string) {
    const reward = await this.prisma.giftReward.findUnique({
      where: { id },
      include: {
        translations: true,
        _count: { select: { transactions: true } },
      },
    });
    if (!reward) {
      throw new NotFoundException('Gift reward not found');
    }
    return reward;
  }

  async create(dto: {
    key: string;
    category: string;
    icon: string;
    cost: number;
    sortOrder?: number;
    translations: {
      locale: string;
      name: string;
      description?: string;
    }[];
  }) {
    return this.prisma.giftReward.create({
      data: {
        key: dto.key,
        category: dto.category as any,
        icon: dto.icon,
        cost: dto.cost,
        sortOrder: dto.sortOrder || 0,
        translations: {
          create: dto.translations,
        },
      },
      include: { translations: true },
    });
  }

  async update(
    id: string,
    dto: {
      category?: string;
      icon?: string;
      cost?: number;
      sortOrder?: number;
      isActive?: boolean;
      translations?: {
        locale: string;
        name: string;
        description?: string;
      }[];
    },
  ) {
    const { translations, category, ...rest } = dto;

    const data: any = { ...rest };
    if (category) {
      data.category = category as GiftRewardCategory;
    }

    await this.prisma.giftReward.update({
      where: { id },
      data,
    });

    if (translations && translations.length > 0) {
      for (const t of translations) {
        await this.prisma.giftRewardTranslation.upsert({
          where: {
            rewardId_locale: {
              rewardId: id,
              locale: t.locale,
            },
          },
          update: { name: t.name, description: t.description },
          create: {
            rewardId: id,
            locale: t.locale,
            name: t.name,
            description: t.description,
          },
        });
      }
    }

    return this.findOne(id);
  }

  async remove(id: string) {
    await this.prisma.giftReward.delete({ where: { id } });
    return { message: 'Gift reward deleted' };
  }

  async getTransactions(page: number, limit: number) {
    const [data, total] = await Promise.all([
      this.prisma.giftTransaction.findMany({
        include: {
          sender: {
            select: {
              id: true,
              displayName: true,
              email: true,
            },
          },
          receiver: {
            select: {
              id: true,
              displayName: true,
              email: true,
            },
          },
          house: { select: { id: true, name: true } },
        },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.giftTransaction.count(),
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
