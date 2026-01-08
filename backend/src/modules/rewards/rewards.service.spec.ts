import { Test, TestingModule } from '@nestjs/testing';
import { RewardsService } from './rewards.service';
import { PrismaService } from '../../prisma/prisma.service';
import {
  ForbiddenException,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';

describe('RewardsService', () => {
  let service: RewardsService;
  let prismaService: PrismaService;

  const mockReward = {
    id: 'reward-uuid',
    title: 'Test Reward',
    cost: 1000,
    icon: 'gift',
    description: 'Test description',
    isActive: true,
    createdAt: new Date(),
    creator: { id: 'creator-uuid', displayName: 'Creator' },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RewardsService,
        {
          provide: PrismaService,
          useValue: {
            user: {
              findUnique: jest.fn(),
              update: jest.fn(),
            },
            reward: {
              findMany: jest.fn(),
              findUnique: jest.fn(),
              create: jest.fn(),
              update: jest.fn(),
            },
            redemption: {
              create: jest.fn(),
            },
            $transaction: jest.fn((fn) =>
              fn({
                user: {
                  update: jest.fn().mockResolvedValue({ walletBalance: 1000 }),
                },
                redemption: {
                  create: jest.fn().mockResolvedValue({
                    id: 'redemption-uuid',
                    rewardTitle: 'Test Reward',
                    pointsSpent: 1000,
                    status: 'PENDING',
                    redeemedAt: new Date(),
                  }),
                },
              }),
            ),
          },
        },
      ],
    }).compile();

    service = module.get<RewardsService>(RewardsService);
    prismaService = module.get<PrismaService>(PrismaService);
  });

  describe('findAll', () => {
    it('should return rewards list with user balance', async () => {
      // Arrange
      jest.spyOn(prismaService.user, 'findUnique').mockResolvedValue({
        houseId: 'house-uuid',
        walletBalance: 2000,
      } as any);
      jest
        .spyOn(prismaService.reward, 'findMany')
        .mockResolvedValue([mockReward] as any);

      // Act
      const result = await service.findAll('user-uuid', { activeOnly: true });

      // Assert
      expect(result.rewards).toHaveLength(1);
      expect(result.userBalance).toBe(2000);
    });

    it('should throw ForbiddenException when user not in house', async () => {
      // Arrange
      jest
        .spyOn(prismaService.user, 'findUnique')
        .mockResolvedValue({ houseId: null } as any);

      // Act & Assert
      await expect(service.findAll('user-uuid', {})).rejects.toThrow(
        ForbiddenException,
      );
    });
  });

  describe('create', () => {
    it('should create reward when user in house', async () => {
      // Arrange
      jest
        .spyOn(prismaService.user, 'findUnique')
        .mockResolvedValue({ houseId: 'house-uuid' } as any);
      jest
        .spyOn(prismaService.reward, 'create')
        .mockResolvedValue(mockReward as any);

      // Act
      const result = await service.create('user-uuid', {
        title: 'New Reward',
        cost: 1000,
        icon: 'gift',
      });

      // Assert
      expect(result.title).toBe('Test Reward');
    });

    it('should throw ForbiddenException when user not in house', async () => {
      // Arrange
      jest
        .spyOn(prismaService.user, 'findUnique')
        .mockResolvedValue({ houseId: null } as any);

      // Act & Assert
      await expect(
        service.create('user-uuid', {
          title: 'New Reward',
          cost: 1000,
          icon: 'gift',
        }),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('update', () => {
    it('should allow creator to update reward', async () => {
      // Arrange
      jest.spyOn(prismaService.reward, 'findUnique').mockResolvedValue({
        ...mockReward,
        creatorId: 'user-uuid',
        house: { createdById: 'other-user' },
      } as any);
      jest.spyOn(prismaService.reward, 'update').mockResolvedValue({
        ...mockReward,
        title: 'Updated Title',
      } as any);

      // Act
      const result = await service.update('user-uuid', 'reward-uuid', {
        title: 'Updated Title',
      });

      // Assert
      expect(result.title).toBe('Updated Title');
    });

    it('should throw ForbiddenException for other members', async () => {
      // Arrange
      jest.spyOn(prismaService.reward, 'findUnique').mockResolvedValue({
        ...mockReward,
        creatorId: 'creator-uuid',
        house: { createdById: 'owner-uuid' },
      } as any);

      // Act & Assert
      await expect(
        service.update('random-user', 'reward-uuid', { title: 'X' }),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw NotFoundException when reward not found', async () => {
      // Arrange
      jest
        .spyOn(prismaService.reward, 'findUnique')
        .mockResolvedValue(null as any);

      // Act & Assert
      await expect(
        service.update('user-uuid', 'reward-uuid', { title: 'X' }),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('redeem', () => {
    it('should redeem reward with sufficient balance', async () => {
      // Arrange
      jest.spyOn(prismaService.user, 'findUnique').mockResolvedValue({
        id: 'user-uuid',
        houseId: 'house-uuid',
        walletBalance: 2000,
      } as any);
      jest.spyOn(prismaService.reward, 'findUnique').mockResolvedValue({
        id: 'reward-uuid',
        houseId: 'house-uuid',
        title: 'Test Reward',
        cost: 1000,
        isActive: true,
      } as any);

      // Act
      const result = await service.redeem('user-uuid', 'reward-uuid');

      // Assert
      expect(result.redemption.pointsSpent).toBe(1000);
      expect(result.wallet.newBalance).toBe(1000);
    });

    it('should throw BadRequestException with insufficient balance', async () => {
      // Arrange
      jest.spyOn(prismaService.user, 'findUnique').mockResolvedValue({
        id: 'user-uuid',
        houseId: 'house-uuid',
        walletBalance: 500,
      } as any);
      jest.spyOn(prismaService.reward, 'findUnique').mockResolvedValue({
        id: 'reward-uuid',
        houseId: 'house-uuid',
        title: 'Test Reward',
        cost: 1000,
        isActive: true,
      } as any);

      // Act & Assert
      await expect(service.redeem('user-uuid', 'reward-uuid')).rejects.toThrow(
        BadRequestException,
      );
    });

    it('should throw NotFoundException for inactive reward', async () => {
      // Arrange
      jest.spyOn(prismaService.user, 'findUnique').mockResolvedValue({
        houseId: 'house-uuid',
        walletBalance: 2000,
      } as any);
      jest.spyOn(prismaService.reward, 'findUnique').mockResolvedValue({
        id: 'reward-uuid',
        houseId: 'house-uuid',
        isActive: false,
      } as any);

      // Act & Assert
      await expect(service.redeem('user-uuid', 'reward-uuid')).rejects.toThrow(
        NotFoundException,
      );
    });
  });
});
