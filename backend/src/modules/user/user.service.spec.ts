import { Test, TestingModule } from '@nestjs/testing';
import { UserService } from './user.service';
import { PrismaService } from '../../prisma/prisma.service';
import { ForbiddenException, NotFoundException } from '@nestjs/common';

describe('UserService', () => {
  let service: UserService;
  let prismaService: PrismaService;

  const mockUser = {
    id: 'user-uuid-123',
    displayName: 'Test User',
    avatarId: 1,
    email: 'test@example.com',
    walletBalance: 1000,
    houseId: 'house-uuid-123',
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UserService,
        {
          provide: PrismaService,
          useValue: {
            user: {
              update: jest.fn(),
              findUnique: jest.fn(),
            },
          },
        },
      ],
    }).compile();

    service = module.get<UserService>(UserService);
    prismaService = module.get<PrismaService>(PrismaService);
  });

  describe('updateProfile', () => {
    it('should update displayName only', async () => {
      // Arrange
      const updatedUser = { ...mockUser, displayName: 'New Name' };
      jest.spyOn(prismaService.user, 'update').mockResolvedValue(updatedUser as any);

      // Act
      const result = await service.updateProfile('user-uuid-123', {
        displayName: 'New Name',
      });

      // Assert
      expect(result.displayName).toBe('New Name');
    });

    it('should update avatarId only', async () => {
      // Arrange
      const updatedUser = { ...mockUser, avatarId: 5 };
      jest.spyOn(prismaService.user, 'update').mockResolvedValue(updatedUser as any);

      // Act
      const result = await service.updateProfile('user-uuid-123', {
        avatarId: 5,
      });

      // Assert
      expect(result.avatarId).toBe(5);
    });

    it('should update both displayName and avatarId', async () => {
      // Arrange
      const updatedUser = { ...mockUser, displayName: 'New Name', avatarId: 10 };
      jest.spyOn(prismaService.user, 'update').mockResolvedValue(updatedUser as any);

      // Act
      const result = await service.updateProfile('user-uuid-123', {
        displayName: 'New Name',
        avatarId: 10,
      });

      // Assert
      expect(result.displayName).toBe('New Name');
      expect(result.avatarId).toBe(10);
    });
  });

  describe('updateFcmToken', () => {
    it('should update FCM token and return success message', async () => {
      // Arrange
      jest.spyOn(prismaService.user, 'update').mockResolvedValue(mockUser as any);

      // Act
      const result = await service.updateFcmToken('user-uuid-123', 'new-fcm-token');

      // Assert
      expect(result.message).toBe('FCM token updated successfully');
    });
  });

  describe('getUserById', () => {
    it('should return user when in same house', async () => {
      // Arrange
      const findUniqueSpy = jest.spyOn(prismaService.user, 'findUnique');
      findUniqueSpy
        .mockResolvedValueOnce({ houseId: 'house-uuid-123' } as any)
        .mockResolvedValueOnce({
          id: 'target-uuid',
          displayName: 'Target User',
          avatarId: 5,
          walletBalance: 2000,
          houseId: 'house-uuid-123',
        } as any);

      // Act
      const result = await service.getUserById('user-uuid-123', 'target-uuid');

      // Assert
      expect(result.id).toBe('target-uuid');
      expect(result.displayName).toBe('Target User');
    });

    it('should throw ForbiddenException when current user not in house', async () => {
      // Arrange
      jest.spyOn(prismaService.user, 'findUnique').mockResolvedValueOnce({ houseId: null } as any);

      // Act & Assert
      await expect(
        service.getUserById('user-uuid-123', 'target-uuid'),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw ForbiddenException when users in different houses', async () => {
      // Arrange
      const findUniqueSpy = jest.spyOn(prismaService.user, 'findUnique');
      findUniqueSpy
        .mockResolvedValueOnce({ houseId: 'house-A' } as any)
        .mockResolvedValueOnce({ houseId: 'house-B' } as any);

      // Act & Assert
      await expect(
        service.getUserById('user-uuid-123', 'target-uuid'),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw NotFoundException when target user not found', async () => {
      // Arrange
      const findUniqueSpy = jest.spyOn(prismaService.user, 'findUnique');
      findUniqueSpy
        .mockResolvedValueOnce({ houseId: 'house-uuid-123' } as any)
        .mockResolvedValueOnce(null as any);

      // Act & Assert
      await expect(
        service.getUserById('user-uuid-123', 'target-uuid'),
      ).rejects.toThrow(NotFoundException);
    });
  });
});
