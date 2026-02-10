import { Test, TestingModule } from '@nestjs/testing';
import { LeaderboardNotificationService } from './leaderboard-notification.service';
import { PrismaService } from '../../prisma/prisma.service';
import { NotificationsService } from './notifications.service';
import { NotificationType } from '@prisma/client';

describe('LeaderboardNotificationService', () => {
  let service: LeaderboardNotificationService;
  let prismaService: PrismaService;
  let notificationsService: NotificationsService;

  const mockNotificationsService = {
    createNotification: jest.fn().mockResolvedValue({}),
  };

  const mockPrismaService = {
    house: {
      findMany: jest.fn(),
    },
    activity: {
      groupBy: jest.fn(),
    },
    user: {
      update: jest.fn().mockResolvedValue({}),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        LeaderboardNotificationService,
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

    service = module.get<LeaderboardNotificationService>(
      LeaderboardNotificationService,
    );
    prismaService = module.get<PrismaService>(PrismaService);
    notificationsService =
      module.get<NotificationsService>(NotificationsService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('checkLeaderboardChanges', () => {
    it('should send notification when rank improves', async () => {
      // Arrange
      mockPrismaService.house.findMany.mockResolvedValue([
        {
          id: 'house-1',
          name: 'Test House',
          members: [
            { id: 'user-1', displayName: 'Alice', leaderboardRank: 2 },
            { id: 'user-2', displayName: 'Bob', leaderboardRank: 1 },
          ],
        },
      ]);

      mockPrismaService.activity.groupBy.mockResolvedValue([
        { userId: 'user-1', _sum: { pointsEarned: 500 } },
        { userId: 'user-2', _sum: { pointsEarned: 300 } },
      ]);

      // Act
      await service.checkLeaderboardChanges();

      // Assert — user-1 went from rank 2 to rank 1 (improvement)
      expect(mockNotificationsService.createNotification).toHaveBeenCalledWith(
        expect.objectContaining({
          userId: 'user-1',
          type: NotificationType.LEADERBOARD_CHANGE,
          sendPush: true,
        }),
      );
    });

    it('should send notification when rank drops', async () => {
      // Arrange
      mockPrismaService.house.findMany.mockResolvedValue([
        {
          id: 'house-1',
          name: 'Test House',
          members: [
            { id: 'user-1', displayName: 'Alice', leaderboardRank: 1 },
            { id: 'user-2', displayName: 'Bob', leaderboardRank: 2 },
          ],
        },
      ]);

      mockPrismaService.activity.groupBy.mockResolvedValue([
        { userId: 'user-2', _sum: { pointsEarned: 500 } },
        { userId: 'user-1', _sum: { pointsEarned: 300 } },
      ]);

      // Act
      await service.checkLeaderboardChanges();

      // Assert — user-1 dropped from rank 1 to rank 2 (no push)
      expect(mockNotificationsService.createNotification).toHaveBeenCalledWith(
        expect.objectContaining({
          userId: 'user-1',
          type: NotificationType.LEADERBOARD_CHANGE,
          sendPush: false,
        }),
      );
    });

    it('should NOT send notification when rank unchanged', async () => {
      // Arrange
      mockPrismaService.house.findMany.mockResolvedValue([
        {
          id: 'house-1',
          name: 'Test House',
          members: [
            { id: 'user-1', displayName: 'Alice', leaderboardRank: 1 },
            { id: 'user-2', displayName: 'Bob', leaderboardRank: 2 },
          ],
        },
      ]);

      mockPrismaService.activity.groupBy.mockResolvedValue([
        { userId: 'user-1', _sum: { pointsEarned: 500 } },
        { userId: 'user-2', _sum: { pointsEarned: 300 } },
      ]);

      // Act
      await service.checkLeaderboardChanges();

      // Assert — ranks stayed the same, no notification
      expect(
        mockNotificationsService.createNotification,
      ).not.toHaveBeenCalled();
    });

    it('should skip houses with less than 2 members', async () => {
      // Arrange
      mockPrismaService.house.findMany.mockResolvedValue([
        {
          id: 'house-1',
          name: 'Solo House',
          members: [
            { id: 'user-1', displayName: 'Alice', leaderboardRank: 1 },
          ],
        },
      ]);

      // Act
      await service.checkLeaderboardChanges();

      // Assert
      expect(mockPrismaService.activity.groupBy).not.toHaveBeenCalled();
      expect(
        mockNotificationsService.createNotification,
      ).not.toHaveBeenCalled();
    });

    it('should NOT send notification for new users (null rank)', async () => {
      // Arrange
      mockPrismaService.house.findMany.mockResolvedValue([
        {
          id: 'house-1',
          name: 'Test House',
          members: [
            { id: 'user-1', displayName: 'Alice', leaderboardRank: null },
            { id: 'user-2', displayName: 'Bob', leaderboardRank: null },
          ],
        },
      ]);

      mockPrismaService.activity.groupBy.mockResolvedValue([
        { userId: 'user-1', _sum: { pointsEarned: 100 } },
      ]);

      // Act
      await service.checkLeaderboardChanges();

      // Assert — first time ranking, no notification
      expect(
        mockNotificationsService.createNotification,
      ).not.toHaveBeenCalled();

      // But rank should still be stored
      expect(mockPrismaService.user.update).toHaveBeenCalledTimes(2);
    });

    it('should update leaderboardRank for all members', async () => {
      // Arrange
      mockPrismaService.house.findMany.mockResolvedValue([
        {
          id: 'house-1',
          name: 'Test House',
          members: [
            { id: 'user-1', displayName: 'Alice', leaderboardRank: null },
            { id: 'user-2', displayName: 'Bob', leaderboardRank: null },
            { id: 'user-3', displayName: 'Charlie', leaderboardRank: null },
          ],
        },
      ]);

      mockPrismaService.activity.groupBy.mockResolvedValue([
        { userId: 'user-2', _sum: { pointsEarned: 500 } },
        { userId: 'user-1', _sum: { pointsEarned: 300 } },
      ]);

      // Act
      await service.checkLeaderboardChanges();

      // Assert — all 3 members should get their rank updated
      expect(mockPrismaService.user.update).toHaveBeenCalledWith({
        where: { id: 'user-2' },
        data: { leaderboardRank: 1 },
      });
      expect(mockPrismaService.user.update).toHaveBeenCalledWith({
        where: { id: 'user-1' },
        data: { leaderboardRank: 2 },
      });
      expect(mockPrismaService.user.update).toHaveBeenCalledWith({
        where: { id: 'user-3' },
        data: { leaderboardRank: 3 },
      });
    });
  });
});
