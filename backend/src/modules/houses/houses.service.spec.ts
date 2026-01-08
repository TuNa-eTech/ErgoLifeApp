import { Test, TestingModule } from '@nestjs/testing';
import { HousesService } from './houses.service';
import { PrismaService } from '../../prisma/prisma.service';
import { ConflictException, NotFoundException } from '@nestjs/common';

describe('HousesService', () => {
  let service: HousesService;
  let prismaService: PrismaService;

  const mockHouse = {
    id: 'house-uuid-123',
    name: 'Test House',
    inviteCode: 'abc123',
    createdById: 'user-uuid-123',
    createdAt: new Date(),
    updatedAt: new Date(),
    members: [
      {
        id: 'user-uuid-123',
        displayName: 'User 1',
        avatarId: 1,
        walletBalance: 100,
      },
    ],
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        HousesService,
        {
          provide: PrismaService,
          useValue: {
            user: {
              findUnique: jest.fn(),
              update: jest.fn(),
            },
            house: {
              create: jest.fn(),
              findUnique: jest.fn(),
              delete: jest.fn(),
            },
            reward: { deleteMany: jest.fn() },
            activity: { deleteMany: jest.fn() },
            redemption: { deleteMany: jest.fn() },
            $transaction: jest.fn((fn) =>
              fn({
                user: { update: jest.fn().mockResolvedValue({}) },
                house: {
                  create: jest.fn().mockResolvedValue(mockHouse),
                  findUnique: jest.fn().mockResolvedValue(mockHouse),
                  delete: jest.fn(),
                },
                reward: { deleteMany: jest.fn() },
                activity: { deleteMany: jest.fn() },
                redemption: { deleteMany: jest.fn() },
              }),
            ),
          },
        },
      ],
    }).compile();

    service = module.get<HousesService>(HousesService);
    prismaService = module.get<PrismaService>(PrismaService);
  });

  describe('create', () => {
    it('should create house when user has no house', async () => {
      // Arrange
      jest
        .spyOn(prismaService.user, 'findUnique')
        .mockResolvedValue({ houseId: null } as any);

      // Act
      const result = await service.create('user-uuid-123', {
        name: 'Test House',
      });

      // Assert
      expect(result.name).toBe('Test House');
      expect(result.memberCount).toBe(1);
    });

    it('should throw ConflictException when user already in house', async () => {
      // Arrange
      jest.spyOn(prismaService.user, 'findUnique').mockResolvedValue({
        houseId: 'existing-house',
      } as any);

      // Act & Assert
      await expect(
        service.create('user-uuid-123', { name: 'New House' }),
      ).rejects.toThrow(ConflictException);
    });
  });

  describe('join', () => {
    it('should throw NotFoundException with invalid invite code', async () => {
      // Arrange
      jest
        .spyOn(prismaService.user, 'findUnique')
        .mockResolvedValue({ houseId: null } as any);
      jest
        .spyOn(prismaService.house, 'findUnique')
        .mockResolvedValue(null as any);

      // Act & Assert
      await expect(service.join('user-uuid-456', 'invalid')).rejects.toThrow(
        NotFoundException,
      );
    });

    it('should throw ConflictException when house is full', async () => {
      // Arrange
      jest
        .spyOn(prismaService.user, 'findUnique')
        .mockResolvedValue({ houseId: null } as any);
      jest.spyOn(prismaService.house, 'findUnique').mockResolvedValue({
        ...mockHouse,
        members: [{ id: '1' }, { id: '2' }, { id: '3' }, { id: '4' }],
      } as any);

      // Act & Assert
      await expect(service.join('user-uuid-456', 'abc123')).rejects.toThrow(
        ConflictException,
      );
    });

    it('should throw ConflictException when user already in another house', async () => {
      // Arrange
      jest.spyOn(prismaService.user, 'findUnique').mockResolvedValue({
        houseId: 'other-house',
      } as any);

      // Act & Assert
      await expect(service.join('user-uuid-456', 'abc123')).rejects.toThrow(
        ConflictException,
      );
    });
  });

  describe('leave', () => {
    it('should throw NotFoundException when user not in house', async () => {
      // Arrange
      jest
        .spyOn(prismaService.user, 'findUnique')
        .mockResolvedValue({ house: null } as any);

      // Act & Assert
      await expect(service.leave('user-uuid-123')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('preview', () => {
    it('should return house preview for valid invite code', async () => {
      // Arrange
      jest.spyOn(prismaService.house, 'findUnique').mockResolvedValue({
        name: 'Test House',
        members: [{ avatarId: 1 }, { avatarId: 2 }],
      } as any);

      // Act
      const result = await service.preview('abc123');

      // Assert
      expect(result.name).toBe('Test House');
      expect(result.memberCount).toBe(2);
      expect(result.isFull).toBe(false);
      expect(result.memberAvatars).toEqual([1, 2]);
    });

    it('should throw NotFoundException for invalid invite code', async () => {
      // Arrange
      jest
        .spyOn(prismaService.house, 'findUnique')
        .mockResolvedValue(null as any);

      // Act & Assert
      await expect(service.preview('invalid')).rejects.toThrow(
        NotFoundException,
      );
    });
  });
});
