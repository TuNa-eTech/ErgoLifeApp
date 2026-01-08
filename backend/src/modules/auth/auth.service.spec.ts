import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { PrismaService } from '../../prisma/prisma.service';
import { FirebaseService } from '../../firebase';
import { JwtService } from '@nestjs/jwt';
import { UnauthorizedException } from '@nestjs/common';
import { AuthProvider } from '@prisma/client';

describe('AuthService', () => {
  let service: AuthService;
  let prismaService: PrismaService;
  let firebaseService: FirebaseService;
  let jwtService: JwtService;

  const mockUser = {
    id: 'user-uuid-123',
    firebaseUid: 'firebase-uid-123',
    provider: AuthProvider.GOOGLE,
    email: 'test@example.com',
    displayName: 'Test User',
    avatarId: 1,
    houseId: null,
    walletBalance: 0,
    fcmToken: null,
    createdAt: new Date(),
    updatedAt: new Date(),
    house: null,
  };

  const mockFirebaseUserInfo = {
    uid: 'firebase-uid-123',
    email: 'test@example.com',
    name: 'Test User',
    picture: 'https://example.com/avatar.jpg',
    provider: 'google.com' as const,
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: PrismaService,
          useValue: {
            user: {
              findUnique: jest.fn(),
              upsert: jest.fn(),
              update: jest.fn(),
            },
          },
        },
        {
          provide: FirebaseService,
          useValue: {
            verifyIdToken: jest.fn(),
            extractUserInfo: jest.fn(),
          },
        },
        {
          provide: JwtService,
          useValue: {
            sign: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    prismaService = module.get<PrismaService>(PrismaService);
    firebaseService = module.get<FirebaseService>(FirebaseService);
    jwtService = module.get<JwtService>(JwtService);
  });

  describe('socialLogin', () => {
    it('should create new user and return JWT with isNewUser=true', async () => {
      // Arrange
      jest.spyOn(firebaseService, 'verifyIdToken').mockResolvedValue({} as any);
      jest
        .spyOn(firebaseService, 'extractUserInfo')
        .mockReturnValue(mockFirebaseUserInfo);
      jest
        .spyOn(prismaService.user, 'findUnique')
        .mockResolvedValue(null as any);
      jest.spyOn(prismaService.user, 'upsert').mockResolvedValue({
        ...mockUser,
        house: null,
      } as any);
      jest.spyOn(jwtService, 'sign').mockReturnValue('mock-jwt-token');

      // Act
      const result = await service.socialLogin('valid-id-token');

      // Assert
      expect(result.isNewUser).toBe(true);
      expect(result.accessToken).toBe('mock-jwt-token');
      expect(result.user.firebaseUid).toBe('firebase-uid-123');
    });

    it('should return isNewUser=false for existing user', async () => {
      // Arrange
      jest.spyOn(firebaseService, 'verifyIdToken').mockResolvedValue({} as any);
      jest
        .spyOn(firebaseService, 'extractUserInfo')
        .mockReturnValue(mockFirebaseUserInfo);
      jest
        .spyOn(prismaService.user, 'findUnique')
        .mockResolvedValue(mockUser as any);
      jest.spyOn(prismaService.user, 'upsert').mockResolvedValue({
        ...mockUser,
        house: null,
      } as any);
      jest.spyOn(jwtService, 'sign').mockReturnValue('mock-jwt-token');

      // Act
      const result = await service.socialLogin('valid-id-token');

      // Assert
      expect(result.isNewUser).toBe(false);
    });

    it('should throw UnauthorizedException for invalid Firebase token', async () => {
      // Arrange
      jest
        .spyOn(firebaseService, 'verifyIdToken')
        .mockRejectedValue(new Error('Invalid token'));

      // Act & Assert
      await expect(service.socialLogin('invalid-token')).rejects.toThrow(
        UnauthorizedException,
      );
    });
  });

  describe('getMe', () => {
    it('should return user with house info', async () => {
      // Arrange
      const userWithHouse = {
        ...mockUser,
        houseId: 'house-uuid-123',
        house: {
          id: 'house-uuid-123',
          name: 'Test House',
          members: [{ id: 'user-uuid-123' }, { id: 'user-uuid-456' }],
        },
      };
      jest
        .spyOn(prismaService.user, 'findUnique')
        .mockResolvedValue(userWithHouse as any);

      // Act
      const result = await service.getMe('user-uuid-123');

      // Assert
      expect(result.houseId).toBe('house-uuid-123');
      expect(result.house).toBeDefined();
      expect(result.house?.memberCount).toBe(2);
    });

    it('should throw UnauthorizedException if user not found', async () => {
      // Arrange
      jest
        .spyOn(prismaService.user, 'findUnique')
        .mockResolvedValue(null as any);

      // Act & Assert
      await expect(service.getMe('non-existent-id')).rejects.toThrow(
        UnauthorizedException,
      );
    });
  });

  describe('logout', () => {
    it('should clear FCM token and return success message', async () => {
      // Arrange
      jest
        .spyOn(prismaService.user, 'update')
        .mockResolvedValue(mockUser as any);

      // Act
      const result = await service.logout('user-uuid-123');

      // Assert
      expect(result.message).toBe('Logged out successfully');
      expect(prismaService.user.update).toHaveBeenCalledWith({
        where: { id: 'user-uuid-123' },
        data: { fcmToken: null },
      });
    });
  });
});
