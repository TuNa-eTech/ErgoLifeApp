import { Test, TestingModule } from '@nestjs/testing';
import { ActivitiesService } from './activities.service';
import { PrismaService } from '../../prisma/prisma.service';
import { ForbiddenException } from '@nestjs/common';

describe('ActivitiesService', () => {
  let service: ActivitiesService;
  let prismaService: PrismaService;

  beforeEach(async () => {
    const mockActivity = {
      id: 'activity-uuid',
      taskName: 'Hút bụi',
      durationSeconds: 1200,
      metsValue: 3.5,
      pointsEarned: 700,
      bonusMultiplier: 1.0,
      completedAt: new Date(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ActivitiesService,
        {
          provide: PrismaService,
          useValue: {
            user: {
              findUnique: jest.fn(),
              update: jest.fn(),
              findMany: jest.fn(),
            },
            activity: {
              create: jest.fn(),
              findMany: jest.fn(),
              count: jest.fn(),
              aggregate: jest.fn(),
              groupBy: jest.fn(),
            },
            $transaction: jest.fn((fn) => fn({
              activity: { create: jest.fn().mockResolvedValue(mockActivity) },
              user: { update: jest.fn().mockResolvedValue({ walletBalance: 1700 }) },
            })),
          },
        },
      ],
    }).compile();

    service = module.get<ActivitiesService>(ActivitiesService);
    prismaService = module.get<PrismaService>(PrismaService);
  });

  describe('create', () => {
    it('should throw ForbiddenException when user not in house', async () => {
      // Arrange
      jest.spyOn(prismaService.user, 'findUnique').mockResolvedValue({ houseId: null } as any);

      // Act & Assert
      await expect(
        service.create('user-uuid', {
          taskName: 'Hút bụi',
          durationSeconds: 600,
          metsValue: 3.5,
          magicWipePercentage: 80,
        }),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should create activity when user in house', async () => {
      // Arrange
      jest.spyOn(prismaService.user, 'findUnique').mockResolvedValue({
        id: 'user-uuid',
        houseId: 'house-uuid',
        walletBalance: 1000,
      } as any);

      // Act
      const result = await service.create('user-uuid', {
        taskName: 'Hút bụi',
        durationSeconds: 1200,
        metsValue: 3.5,
        magicWipePercentage: 80,
      });

      // Assert
      expect(result.activity).toBeDefined();
      expect(result.wallet).toBeDefined();
    });
  });

  describe('findAll', () => {
    it('should return paginated activities with summary', async () => {
      // Arrange
      const activities = [
        { id: '1', taskName: 'Task 1', durationSeconds: 600, metsValue: 3.0, pointsEarned: 300, bonusMultiplier: 1.0, completedAt: new Date() },
      ];
      jest.spyOn(prismaService.activity, 'findMany').mockResolvedValue(activities as any);
      jest.spyOn(prismaService.activity, 'count').mockResolvedValue(1 as any);
      jest.spyOn(prismaService.activity, 'aggregate').mockResolvedValue({
        _sum: { pointsEarned: 300, durationSeconds: 600 },
        _count: 1,
      } as any);

      // Act
      const result = await service.findAll('user-uuid', { page: 1, limit: 20 });

      // Assert
      expect(result.items).toHaveLength(1);
      expect(result.pagination.total).toBe(1);
      expect(result.summary.totalPoints).toBe(300);
    });
  });

  describe('getLeaderboard', () => {
    it('should throw ForbiddenException when user not in house', async () => {
      // Arrange
      jest.spyOn(prismaService.user, 'findUnique').mockResolvedValue({ houseId: null } as any);

      // Act & Assert
      await expect(
        service.getLeaderboard('user-uuid', {}),
      ).rejects.toThrow(ForbiddenException);
    });
  });
});
