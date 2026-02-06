import { Test, TestingModule } from '@nestjs/testing';
import { NotificationsService } from './notifications.service';
import { PrismaService } from '../../prisma/prisma.service';
import { FcmService } from '../../firebase/fcm.service';
import { NotFoundException, ForbiddenException } from '@nestjs/common';
import { NotificationType, NotificationPriority } from '@prisma/client';

describe('NotificationsService', () => {
  let service: NotificationsService;
  let prismaService: PrismaService;
  let fcmService: FcmService;

  const mockNotification = {
    id: 'notif-uuid-123',
    userId: 'user-uuid-123',
    type: NotificationType.STREAK_REMINDER,
    priority: NotificationPriority.MEDIUM,
    title: 'Test Notification',
    body: 'Test Body',
    imageUrl: null,
    data: { streak: '5' },
    actionUrl: 'ergolife://tasks',
    isRead: false,
    isSent: false,
    sentAt: null,
    readAt: null,
    scheduledFor: null,
    createdAt: new Date(),
  };

  const mockUser = {
    id: 'user-uuid-123',
    fcmToken: 'mock-fcm-token',
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        NotificationsService,
        {
          provide: PrismaService,
          useValue: {
            notification: {
              create: jest.fn(),
              findMany: jest.fn(),
              findUnique: jest.fn(),
              update: jest.fn(),
              updateMany: jest.fn(),
              delete: jest.fn(),
              count: jest.fn(),
            },
            user: {
              findUnique: jest.fn(),
              update: jest.fn(),
            },
          },
        },
        {
          provide: FcmService,
          useValue: {
            send: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<NotificationsService>(NotificationsService);
    prismaService = module.get<PrismaService>(PrismaService);
    fcmService = module.get<FcmService>(FcmService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('createNotification', () => {
    it('should create notification and send push', async () => {
      // Arrange
      const dto = {
        userId: 'user-uuid-123',
        type: NotificationType.STREAK_REMINDER,
        title: 'Test Notification',
        body: 'Test Body',
        sendPush: true,
      };
      jest.spyOn(prismaService.notification, 'create').mockResolvedValue(mockNotification as any);
      jest.spyOn(prismaService.user, 'findUnique').mockResolvedValue(mockUser as any);
      jest.spyOn(fcmService, 'send').mockResolvedValue('message-id');
      jest.spyOn(prismaService.notification, 'update').mockResolvedValue(mockNotification as any);

      // Act
      const result = await service.createNotification(dto);

      // Assert
      expect(result).toBeDefined();
      expect(prismaService.notification.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            userId: dto.userId,
            type: dto.type,
            title: dto.title,
            body: dto.body,
          }),
        }),
      );
      expect(fcmService.send).toHaveBeenCalled();
    });

    it('should create notification without sending push if sendPush is false', async () => {
      // Arrange
      const dto = {
        userId: 'user-uuid-123',
        type: NotificationType.WELCOME,
        title: 'Welcome',
        body: 'Welcome to app',
        sendPush: false,
      };
      jest.spyOn(prismaService.notification, 'create').mockResolvedValue(mockNotification as any);

      // Act
      await service.createNotification(dto);

      // Assert
      expect(prismaService.notification.create).toHaveBeenCalled();
      expect(fcmService.send).not.toHaveBeenCalled();
    });

    it('should not send push for scheduled notifications', async () => {
      // Arrange
      const dto = {
        userId: 'user-uuid-123',
        type: NotificationType.STREAK_REMINDER,
        title: 'Future Notification',
        body: 'This is scheduled',
        scheduledFor: new Date(Date.now() + 86400000), // Tomorrow
        sendPush: true,
      };
      jest.spyOn(prismaService.notification, 'create').mockResolvedValue(mockNotification as any);

      // Act
      await service.createNotification(dto);

      // Assert
      expect(prismaService.notification.create).toHaveBeenCalled();
      expect(fcmService.send).not.toHaveBeenCalled();
    });
  });

  describe('sendPushNotification', () => {
    it('should send push notification and mark as sent', async () => {
      // Arrange
      jest.spyOn(prismaService.user, 'findUnique').mockResolvedValue(mockUser as any);
      jest.spyOn(fcmService, 'send').mockResolvedValue('message-id');
      jest.spyOn(prismaService.notification, 'update').mockResolvedValue(mockNotification as any);

      // Act
      await service.sendPushNotification(mockNotification as any);

      // Assert
      expect(fcmService.send).toHaveBeenCalledWith(
        expect.objectContaining({
          token: mockUser.fcmToken,
          notification: expect.objectContaining({
            title: mockNotification.title,
            body: mockNotification.body,
          }),
        }),
      );
      expect(prismaService.notification.update).toHaveBeenCalledWith({
        where: { id: mockNotification.id },
        data: {
          isSent: true,
          sentAt: expect.any(Date),
        },
      });
    });

    it('should skip push if user has no FCM token', async () => {
      // Arrange
      jest.spyOn(prismaService.user, 'findUnique').mockResolvedValue({
        id: 'user-123',
        fcmToken: null,
      } as any);

      // Act
      await service.sendPushNotification(mockNotification as any);

      // Assert
      expect(fcmService.send).not.toHaveBeenCalled();
    });

    it('should clear invalid FCM token on INVALID_TOKEN error', async () => {
      // Arrange
      jest.spyOn(prismaService.user, 'findUnique').mockResolvedValue(mockUser as any);
      jest.spyOn(fcmService, 'send').mockRejectedValue(new Error('INVALID_TOKEN'));
      jest.spyOn(prismaService.user, 'update').mockResolvedValue(mockUser as any);

      // Act & Assert
      await expect(service.sendPushNotification(mockNotification as any)).rejects.toThrow(
        'INVALID_TOKEN',
      );
      expect(prismaService.user.update).toHaveBeenCalledWith({
        where: { id: mockNotification.userId },
        data: { fcmToken: null },
      });
    });
  });

  describe('getUserNotifications', () => {
    it('should return paginated notifications', async () => {
      // Arrange
      const userId = 'user-uuid-123';
      const dto = { page: 1, limit: 20, unreadOnly: false };
      const mockNotifications = [mockNotification];
      jest.spyOn(prismaService.notification, 'findMany').mockResolvedValue(mockNotifications as any);
      jest.spyOn(prismaService.notification, 'count').mockResolvedValue(1);

      // Act
      const result = await service.getUserNotifications(userId, dto);

      // Assert
      expect(result.notifications).toHaveLength(1);
      expect(result.total).toBe(1);
      expect(result.hasMore).toBe(false);
      expect(prismaService.notification.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { userId },
          orderBy: { createdAt: 'desc' },
          skip: 0,
          take: 20,
        }),
      );
    });

    it('should filter by unread only', async () => {
      // Arrange
      const userId = 'user-uuid-123';
      const dto = { page: 1, limit: 20, unreadOnly: true };
      jest.spyOn(prismaService.notification, 'findMany').mockResolvedValue([]);
      jest.spyOn(prismaService.notification, 'count').mockResolvedValue(0);

      // Act
      await service.getUserNotifications(userId, dto);

      // Assert
      expect(prismaService.notification.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            userId,
            isRead: false,
          }),
        }),
      );
    });

    it('should filter by notification type', async () => {
      // Arrange
      const userId = 'user-uuid-123';
      const dto = { page: 1, limit: 20, type: NotificationType.HOUSE_INVITE };
      jest.spyOn(prismaService.notification, 'findMany').mockResolvedValue([]);
      jest.spyOn(prismaService.notification, 'count').mockResolvedValue(0);

      // Act
      await service.getUserNotifications(userId, dto);

      // Assert
      expect(prismaService.notification.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            userId,
            type: NotificationType.HOUSE_INVITE,
          }),
        }),
      );
    });
  });

  describe('markAsRead', () => {
    it('should mark notification as read', async () => {
      // Arrange
      const notificationId = 'notif-uuid-123';
      const userId = 'user-uuid-123';
      jest
        .spyOn(prismaService.notification, 'findUnique')
        .mockResolvedValue(mockNotification as any);
      jest
        .spyOn(prismaService.notification, 'update')
        .mockResolvedValue({ ...mockNotification, isRead: true } as any);

      // Act
      const result = await service.markAsRead(notificationId, userId);

      // Assert
      expect(result.isRead).toBe(true);
      expect(prismaService.notification.update).toHaveBeenCalledWith({
        where: { id: notificationId },
        data: {
          isRead: true,
          readAt: expect.any(Date),
        },
      });
    });

    it('should throw NotFoundException if notification not found', async () => {
      // Arrange
      jest.spyOn(prismaService.notification, 'findUnique').mockResolvedValue(null);

      // Act & Assert
      await expect(service.markAsRead('non-existent', 'user-123')).rejects.toThrow(
        NotFoundException,
      );
    });

    it('should throw ForbiddenException if user is not notification owner', async () => {
      // Arrange
      jest.spyOn(prismaService.notification, 'findUnique').mockResolvedValue(mockNotification as any);

      // Act & Assert
      await expect(service.markAsRead(mockNotification.id, 'wrong-user-id')).rejects.toThrow(
        ForbiddenException,
      );
    });
  });

  describe('markAllAsRead', () => {
    it('should mark all unread notifications as read', async () => {
      // Arrange
      const userId = 'user-uuid-123';
      jest.spyOn(prismaService.notification, 'updateMany').mockResolvedValue({ count: 5 } as any);

      // Act
      const result = await service.markAllAsRead(userId);

      // Assert
      expect(result.count).toBe(5);
      expect(prismaService.notification.updateMany).toHaveBeenCalledWith({
        where: {
          userId,
          isRead: false,
        },
        data: {
          isRead: true,
          readAt: expect.any(Date),
        },
      });
    });
  });

  describe('deleteNotification', () => {
    it('should delete notification', async () => {
      // Arrange
      const notificationId = 'notif-uuid-123';
      const userId = 'user-uuid-123';
      jest
        .spyOn(prismaService.notification, 'findUnique')
        .mockResolvedValue(mockNotification as any);
      jest.spyOn(prismaService.notification, 'delete').mockResolvedValue(mockNotification as any);

      // Act
      await service.deleteNotification(notificationId, userId);

      // Assert
      expect(prismaService.notification.delete).toHaveBeenCalledWith({
        where: { id: notificationId },
      });
    });

    it('should throw NotFoundException if notification not found', async () => {
      // Arrange
      jest.spyOn(prismaService.notification, 'findUnique').mockResolvedValue(null);

      // Act & Assert
      await expect(service.deleteNotification('non-existent', 'user-123')).rejects.toThrow(
        NotFoundException,
      );
    });

    it('should throw ForbiddenException if user is not notification owner', async () => {
      // Arrange
      jest.spyOn(prismaService.notification, 'findUnique').mockResolvedValue(mockNotification as any);

      // Act & Assert
      await expect(service.deleteNotification(mockNotification.id, 'wrong-user')).rejects.toThrow(
        ForbiddenException,
      );
    });
  });

  describe('getUnreadCount', () => {
    it('should return unread notification count', async () => {
      // Arrange
      const userId = 'user-uuid-123';
      jest.spyOn(prismaService.notification, 'count').mockResolvedValue(3);

      // Act
      const result = await service.getUnreadCount(userId);

      // Assert
      expect(result).toBe(3);
      expect(prismaService.notification.count).toHaveBeenCalledWith({
        where: {
          userId,
          isRead: false,
        },
      });
    });
  });

  describe('sendBulkNotifications', () => {
    it('should create notifications for multiple users', async () => {
      // Arrange
      const userIds = ['user-1', 'user-2', 'user-3'];
      const notification = {
        type: NotificationType.NEW_REWARD,
        title: 'New Reward',
        body: 'Check it out',
      };
      jest.spyOn(service, 'createNotification').mockResolvedValue(mockNotification as any);

      // Act
      await service.sendBulkNotifications(userIds, notification);

      // Assert
      expect(service.createNotification).toHaveBeenCalledTimes(3);
    });
  });
});
