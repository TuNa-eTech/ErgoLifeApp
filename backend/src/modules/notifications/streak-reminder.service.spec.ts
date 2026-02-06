import { Test, TestingModule } from '@nestjs/testing';
import { StreakReminderService } from './streak-reminder.service';
import { PrismaService } from '../../prisma/prisma.service';
import { NotificationsService } from './notifications.service';
import { NotificationType } from '@prisma/client';

describe('StreakReminderService', () => {
  let service: StreakReminderService;
  let prismaService: PrismaService;
  let notificationsService: NotificationsService;

  const mockPrismaService = {
    user: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
    },
  };

  const mockNotificationsService = {
    createNotification: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        StreakReminderService,
        {
          provide: PrismaService,
          useValue: mockPrismaService,
        },
        {
          provide: NotificationsService,
          useValue: mockNotificationsService,
        },
      ],
    }).compile();

    service = module.get<StreakReminderService>(StreakReminderService);
    prismaService = module.get<PrismaService>(PrismaService);
    notificationsService = module.get<NotificationsService>(NotificationsService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('sendPersonalizedStreakReminders', () => {
    it('should send reminders at personalized times', async () => {
      const usersToRemind = [
        {
          id: 'user-1',
          fcmToken: 'token-1',
          currentStreak: 5,
          longestStreak: 10,
          lastReminderSentAt: null,
          preferredReminderTime: new Date(),
          activities: [],
        },
      ];

      mockPrismaService.user.findMany.mockResolvedValue(usersToRemind);
      mockNotificationsService.createNotification.mockResolvedValue({});
      mockPrismaService.user.update.mockResolvedValue({});

      await service.sendPersonalizedStreakReminders();

      expect(mockNotificationsService.createNotification).toHaveBeenCalledWith(
        expect.objectContaining({
          userId: 'user-1',
          type: NotificationType.STREAK_REMINDER,
        }),
      );
    });

    it('should skip if user already active today', async () => {
      const usersToRemind = [
        {
          id: 'user-1',
          fcmToken: 'token-1',
          currentStreak: 5,
          longestStreak: 10,
          lastReminderSentAt: null,
          preferredReminderTime: new Date(),
          activities: [{ completedAt: new Date() }], // Already active
        },
      ];

      mockPrismaService.user.findMany.mockResolvedValue(usersToRemind);

      await service.sendPersonalizedStreakReminders();

      expect(mockNotificationsService.createNotification).not.toHaveBeenCalled();
    });

    it('should skip if reminder already sent today', async () => {
      const today = new Date();
      today.setHours(8, 0, 0, 0); // Earlier today

      const usersToRemind = [
        {
          id: 'user-1',
          fcmToken: 'token-1',
          currentStreak: 5,
          longestStreak: 10,
          lastReminderSentAt: today,
          preferredReminderTime: new Date(),
          activities: [],
        },
      ];

      mockPrismaService.user.findMany.mockResolvedValue(usersToRemind);

      await service.sendPersonalizedStreakReminders();

      expect(mockNotificationsService.createNotification).not.toHaveBeenCalled();
    });

    it('should update lastReminderSentAt after sending', async () => {
      const usersToRemind = [
        {
          id: 'user-1',
          fcmToken: 'token-1',
          currentStreak: 5,
          longestStreak: 10,
          lastReminderSentAt: null,
          preferredReminderTime: new Date(),
          activities: [],
        },
      ];

      mockPrismaService.user.findMany.mockResolvedValue(usersToRemind);
      mockNotificationsService.createNotification.mockResolvedValue({});
      mockPrismaService.user.update.mockResolvedValue({});

      await service.sendPersonalizedStreakReminders();

      expect(mockPrismaService.user.update).toHaveBeenCalledWith({
        where: { id: 'user-1' },
        data: { lastReminderSentAt: expect.any(Date) },
      });
    });

    it('should include personalized flag in notification data', async () => {
      const usersToRemind = [
        {
          id: 'user-1',
          fcmToken: 'token-1',
          currentStreak: 5,
          longestStreak: 10,
          lastReminderSentAt: null,
          preferredReminderTime: new Date(), // Has learned preference
          activities: [],
        },
      ];

      mockPrismaService.user.findMany.mockResolvedValue(usersToRemind);
      mockNotificationsService.createNotification.mockResolvedValue({});
      mockPrismaService.user.update.mockResolvedValue({});

      await service.sendPersonalizedStreakReminders();

      expect(mockNotificationsService.createNotification).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            personalized: 'true',
          }),
        }),
      );
    });
  });

  describe('triggerManualStreakReminder', () => {
    it('should send manual reminder to specific user', async () => {
      const userId = 'user-123';
      const user = {
        id: userId,
        fcmToken: 'token-123',
        currentStreak: 7,
        longestStreak: 10,
      };

      mockPrismaService.user.findUnique.mockResolvedValue(user);
      mockNotificationsService.createNotification.mockResolvedValue({});

      await service.triggerManualStreakReminder(userId);

      expect(mockNotificationsService.createNotification).toHaveBeenCalledWith(
        expect.objectContaining({
          userId,
          type: NotificationType.STREAK_REMINDER,
          priority: 'HIGH',
          data: expect.objectContaining({
            manual: 'true',
          }),
        }),
      );
    });

    it('should throw error if user not found', async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(null);

      await expect(service.triggerManualStreakReminder('non-existent')).rejects.toThrow(
        'User not found',
      );
    });

    it('should throw error if user has no FCM token', async () => {
      const user = {
        id: 'user-123',
        fcmToken: null,
        currentStreak: 5,
        longestStreak: 10,
      };

      mockPrismaService.user.findUnique.mockResolvedValue(user);

      await expect(service.triggerManualStreakReminder('user-123')).rejects.toThrow(
        'User has no FCM token',
      );
    });
  });

  describe('message variants', () => {
    it('should generate Vietnamese messages for different streak lengths', async () => {
      const streaks = [3, 7, 14, 30, 50, 100];

      for (const streak of streaks) {
        const usersToRemind = [
          {
            id: 'user-1',
            fcmToken: 'token-1',
            currentStreak: streak,
            longestStreak: streak + 5,
            lastReminderSentAt: null,
            preferredReminderTime: new Date(),
            activities: [],
          },
        ];

        mockPrismaService.user.findMany.mockResolvedValue(usersToRemind);
        mockNotificationsService.createNotification.mockResolvedValue({});
        mockPrismaService.user.update.mockResolvedValue({});

        await service.sendPersonalizedStreakReminders();

        const callArgs = (mockNotificationsService.createNotification as jest.Mock).mock.calls[0][0];
        expect(callArgs.title).toContain(String(streak));
        expect(callArgs.body).toBeTruthy();
        
        jest.clearAllMocks();
      }
    });
  });
});
