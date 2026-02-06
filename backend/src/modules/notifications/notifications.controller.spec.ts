import { Test, TestingModule } from '@nestjs/testing';
import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';
import { NotificationType } from '@prisma/client';

describe('NotificationsController', () => {
  let controller: NotificationsController;
  let service: NotificationsService;

  const mockUser = {
    id: 'user-uuid-123',
    firebaseUid: 'firebase-uid',
    email: 'test@example.com',
  };

  const mockNotification = {
    id: 'notif-uuid-123',
    userId: 'user-uuid-123',
    type: NotificationType.STREAK_REMINDER,
    priority: 'MEDIUM',
    title: 'Test Notification',
    body: 'Test Body',
    isRead: false,
    isSent: true,
    createdAt: new Date(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [NotificationsController],
      providers: [
        {
          provide: NotificationsService,
          useValue: {
            getUserNotifications: jest.fn(),
            getUnreadCount: jest.fn(),
            markAsRead: jest.fn(),
            markAllAsRead: jest.fn(),
            deleteNotification: jest.fn(),
            createNotification: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<NotificationsController>(NotificationsController);
    service = module.get<NotificationsService>(NotificationsService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('getNotifications', () => {
    it('should return paginated notifications', async () => {
      // Arrange
      const dto = { page: 1, limit: 20, unreadOnly: false };
      const mockResult = {
        notifications: [mockNotification],
        total: 1,
        hasMore: false,
      };
      jest.spyOn(service, 'getUserNotifications').mockResolvedValue(mockResult as any);

      // Act
      const result = await controller.getNotifications(mockUser as any, dto);

      // Assert
      expect(result).toEqual(mockResult);
      expect(service.getUserNotifications).toHaveBeenCalledWith(mockUser.id, dto);
    });

    it('should handle unread only filter', async () => {
      // Arrange
      const dto = { page: 1, limit: 20, unreadOnly: true };
      jest.spyOn(service, 'getUserNotifications').mockResolvedValue({
        notifications: [],
        total: 0,
        hasMore: false,
      } as any);

      // Act
      await controller.getNotifications(mockUser as any, dto);

      // Assert
      expect(service.getUserNotifications).toHaveBeenCalledWith(
        mockUser.id,
        expect.objectContaining({ unreadOnly: true }),
      );
    });

    it('should handle type filter', async () => {
      // Arrange
      const dto = { page: 1, limit: 20, type: NotificationType.HOUSE_INVITE };
      jest.spyOn(service, 'getUserNotifications').mockResolvedValue({
        notifications: [],
        total: 0,
        hasMore: false,
      } as any);

      // Act
      await controller.getNotifications(mockUser as any, dto);

      // Assert
      expect(service.getUserNotifications).toHaveBeenCalledWith(
        mockUser.id,
        expect.objectContaining({ type: NotificationType.HOUSE_INVITE }),
      );
    });
  });

  describe('getUnreadCount', () => {
    it('should return unread count', async () => {
      // Arrange
      jest.spyOn(service, 'getUnreadCount').mockResolvedValue(5);

      // Act
      const result = await controller.getUnreadCount(mockUser as any);

      // Assert
      expect(result).toEqual({ count: 5 });
      expect(service.getUnreadCount).toHaveBeenCalledWith(mockUser.id);
    });

    it('should return 0 if no unread notifications', async () => {
      // Arrange
      jest.spyOn(service, 'getUnreadCount').mockResolvedValue(0);

      // Act
      const result = await controller.getUnreadCount(mockUser as any);

      // Assert
      expect(result).toEqual({ count: 0 });
    });
  });

  describe('markAsRead', () => {
    it('should mark notification as read', async () => {
      // Arrange
      const notificationId = 'notif-uuid-123';
      const updatedNotif = { ...mockNotification, isRead: true };
      jest.spyOn(service, 'markAsRead').mockResolvedValue(updatedNotif as any);

      // Act
      const result = await controller.markAsRead(mockUser as any, notificationId);

      // Assert
      expect(result.isRead).toBe(true);
      expect(service.markAsRead).toHaveBeenCalledWith(notificationId, mockUser.id);
    });
  });

  describe('markAllAsRead', () => {
    it('should mark all notifications as read', async () => {
      // Arrange
      jest.spyOn(service, 'markAllAsRead').mockResolvedValue({ count: 3 });

      // Act
      const result = await controller.markAllAsRead(mockUser as any);

      // Assert
      expect(result).toEqual({ count: 3 });
      expect(service.markAllAsRead).toHaveBeenCalledWith(mockUser.id);
    });

    it('should return count 0 if no notifications to mark', async () => {
      // Arrange
      jest.spyOn(service, 'markAllAsRead').mockResolvedValue({ count: 0 });

      // Act
      const result = await controller.markAllAsRead(mockUser as any);

      // Assert
      expect(result.count).toBe(0);
    });
  });

  describe('deleteNotification', () => {
    it('should delete notification', async () => {
      // Arrange
      const notificationId = 'notif-uuid-123';
      jest.spyOn(service, 'deleteNotification').mockResolvedValue(undefined);

      // Act
      await controller.deleteNotification(mockUser as any, notificationId);

      // Assert
      expect(service.deleteNotification).toHaveBeenCalledWith(notificationId, mockUser.id);
    });
  });

  describe('createTestNotification', () => {
    it('should create test notification', async () => {
      // Arrange
      const testNotif = {
        ...mockNotification,
        type: NotificationType.WELCOME,
        title: '🎉 Welcome to ErgoLife!',
      };
      jest.spyOn(service, 'createNotification').mockResolvedValue(testNotif as any);

      // Act
      const result = await controller.createTestNotification(mockUser as any);

      // Assert
      expect(result.type).toBe(NotificationType.WELCOME);
      expect(service.createNotification).toHaveBeenCalledWith(
        expect.objectContaining({
          userId: mockUser.id,
          type: 'WELCOME',
          sendPush: true,
        }),
      );
    });

    it('should set correct welcome message', async () => {
      // Arrange
      jest.spyOn(service, 'createNotification').mockResolvedValue(mockNotification as any);

      // Act
      await controller.createTestNotification(mockUser as any);

      // Assert
      expect(service.createNotification).toHaveBeenCalledWith(
        expect.objectContaining({
          title: '🎉 Welcome to ErgoLife!',
          body: 'Start your health journey today and build healthy habits.',
        }),
      );
    });
  });
});
