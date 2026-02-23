import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class AdminBadgesService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    const badges = await this.prisma.badgeDefinition.findMany({
      include: {
        translations: true,
        _count: { select: { userBadges: true } },
      },
      orderBy: { sortOrder: 'asc' },
    });
    return badges;
  }

  async findOne(id: string) {
    const badge = await this.prisma.badgeDefinition.findUnique({
      where: { id },
      include: {
        translations: true,
        _count: { select: { userBadges: true } },
      },
    });
    if (!badge) throw new NotFoundException('Badge not found');
    return badge;
  }

  async create(dto: {
    code: string;
    category: string;
    icon: string;
    color?: string;
    sortOrder?: number;
    conditionType: string;
    conditionValue: number;
    rarity?: string;
    translations: { locale: string; name: string; description?: string }[];
  }) {
    return this.prisma.badgeDefinition.create({
      data: {
        code: dto.code,
        category: dto.category,
        icon: dto.icon,
        color: dto.color || '#FF6A00',
        sortOrder: dto.sortOrder || 0,
        conditionType: dto.conditionType,
        conditionValue: dto.conditionValue,
        rarity: dto.rarity || 'COMMON',
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
      color?: string;
      sortOrder?: number;
      conditionType?: string;
      conditionValue?: number;
      rarity?: string;
      isActive?: boolean;
      translations?: {
        locale: string;
        name: string;
        description?: string;
      }[];
    },
  ) {
    const { translations, ...data } = dto;

    const badge = await this.prisma.badgeDefinition.update({
      where: { id },
      data,
    });

    if (translations && translations.length > 0) {
      for (const t of translations) {
        await this.prisma.badgeTranslation.upsert({
          where: {
            badgeId_locale: { badgeId: id, locale: t.locale },
          },
          update: { name: t.name, description: t.description },
          create: {
            badgeId: id,
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
    await this.prisma.badgeDefinition.delete({ where: { id } });
    return { message: 'Badge deleted' };
  }

  async getStats() {
    const [total, active, unlocks] = await Promise.all([
      this.prisma.badgeDefinition.count(),
      this.prisma.badgeDefinition.count({
        where: { isActive: true },
      }),
      this.prisma.userBadge.count(),
    ]);

    const topBadges = await this.prisma.userBadge.groupBy({
      by: ['badgeId'],
      _count: { id: true },
      orderBy: { _count: { id: 'desc' } },
      take: 10,
    });

    return { total, active, totalUnlocks: unlocks, topBadges };
  }
}
