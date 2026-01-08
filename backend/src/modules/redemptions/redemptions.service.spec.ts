import { Test, TestingModule } from '@nestjs/testing';
import { RedemptionsService } from './redemptions.service';
import { PrismaService } from '../../prisma/prisma.service';
import {
  ForbiddenException,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { RedemptionStatus } from '@prisma/client';

describe('RedemptionsService', () => {
  let service: RedemptionsService;
  let prismaService: PrismaService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RedemptionsService,
        {
          provide: PrismaService,
          useValue: {
            redemption: {
              findMany: jest.fn(),
              findUnique: jest.fn(),
              count: jest.fn(),
              update: jest.fn(),
            },
          },
        },
      ],
    }).compile();

    service = module.get<RedemptionsService>(RedemptionsService);
    prismaService = module.get<PrismaService>(PrismaService);
  });

  describe('findAll', () => {
    it('should return paginated redemptions', async () => {
      // Arrange
      const redemptions = [
        {
          id: '1',
          rewardTitle: 'Reward 1',
          pointsSpent: 500,
          status: RedemptionStatus.PENDING,
          redeemedAt: new Date(),
          usedAt: null,
        },
      ];
      jest
        .spyOn(prismaService.redemption, 'findMany')
        .mockResolvedValue(redemptions as any);
      jest.spyOn(prismaService.redemption, 'count').mockResolvedValue(1 as any);

      // Act
      const result = await service.findAll('user-uuid', { page: 1, limit: 20 });

      // Assert
      expect(result.items).toHaveLength(1);
      expect(result.pagination.total).toBe(1);
    });

    it('should filter by status', async () => {
      // Arrange
      jest.spyOn(prismaService.redemption, 'findMany').mockResolvedValue([]);
      jest.spyOn(prismaService.redemption, 'count').mockResolvedValue(0 as any);

      // Act
      await service.findAll('user-uuid', { status: 'PENDING' });

      // Assert
      expect(prismaService.redemption.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { userId: 'user-uuid', status: 'PENDING' },
        }),
      );
    });
  });

  describe('markAsUsed', () => {
    it('should mark redemption as used when user in same house', async () => {
      // Arrange
      jest.spyOn(prismaService.redemption, 'findUnique').mockResolvedValue({
        id: 'redemption-uuid',
        status: RedemptionStatus.PENDING,
        house: {
          members: [{ id: 'user-uuid' }, { id: 'other-user' }],
        },
      } as any);
      jest.spyOn(prismaService.redemption, 'update').mockResolvedValue({
        id: 'redemption-uuid',
        status: RedemptionStatus.USED,
        usedAt: new Date(),
      } as any);

      // Act
      const result = await service.markAsUsed('user-uuid', 'redemption-uuid');

      // Assert
      expect(result.status).toBe(RedemptionStatus.USED);
      expect(result.usedAt).toBeDefined();
    });

    it('should throw BadRequestException when already used', async () => {
      // Arrange
      jest.spyOn(prismaService.redemption, 'findUnique').mockResolvedValue({
        id: 'redemption-uuid',
        status: RedemptionStatus.USED,
        house: { members: [{ id: 'user-uuid' }] },
      } as any);

      // Act & Assert
      await expect(
        service.markAsUsed('user-uuid', 'redemption-uuid'),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw ForbiddenException when user not in house', async () => {
      // Arrange
      jest.spyOn(prismaService.redemption, 'findUnique').mockResolvedValue({
        id: 'redemption-uuid',
        status: RedemptionStatus.PENDING,
        house: {
          members: [{ id: 'other-user-1' }, { id: 'other-user-2' }],
        },
      } as any);

      // Act & Assert
      await expect(
        service.markAsUsed('user-uuid', 'redemption-uuid'),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw NotFoundException when redemption not found', async () => {
      // Arrange
      jest
        .spyOn(prismaService.redemption, 'findUnique')
        .mockResolvedValue(null as any);

      // Act & Assert
      await expect(
        service.markAsUsed('user-uuid', 'non-existent'),
      ).rejects.toThrow(NotFoundException);
    });
  });
});
