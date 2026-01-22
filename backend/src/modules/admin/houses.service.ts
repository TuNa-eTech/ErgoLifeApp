
import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class AdminHousesService {
  constructor(private prisma: PrismaService) {}

  async findAll(page: number = 1, limit: number = 20, search?: string) {
    const skip = (page - 1) * limit;
    
    const where: any = {};
    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { inviteCode: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [houses, total] = await Promise.all([
      this.prisma.house.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
            createdBy: {
                select: { displayName: true, email: true }
            },
            _count: {
                select: { members: true }
            }
        }
      }),
      this.prisma.house.count({ where }),
    ]);

    return {
      data: houses,
      meta: {
        total,
        page,
        limit,
        pages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(id: string) {
    const house = await this.prisma.house.findUnique({
      where: { id },
      include: {
        createdBy: true,
        members: {
            take: 10 // Limit members preview
        },
        _count: {
            select: { members: true, activities: true, rewards: true }
        }
      },
    });

    if (!house) {
      throw new NotFoundException(`House with ID ${id} not found`);
    }

    return house;
  }
}
