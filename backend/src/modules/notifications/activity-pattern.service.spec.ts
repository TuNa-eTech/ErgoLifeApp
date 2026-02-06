import { Test, TestingModule } from '@nestjs/testing';
import { ActivityPatternService } from './activity-pattern.service';
import { PrismaService } from '../../prisma/prisma.service';

describe('ActivityPatternService', () => {
  let service: ActivityPatternService;
  let prismaService: PrismaService;

  const mockPrismaService = {
    user: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ActivityPatternService,
        {
          provide: PrismaService,
          useValue: mockPrismaService,
        },
      ],
    }).compile();

    service = module.get<ActivityPatternService>(ActivityPatternService);
    prismaService = module.get<PrismaService>(PrismaService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('calculateActivityPattern', () => {
    it('should calculate hourly distribution correctly', () => {
      const baseDate = new Date('2026-02-01');
      const activities = [
        { completedAt: new Date(baseDate.setHours(8, 0, 0, 0)) },
        { completedAt: new Date(new Date('2026-02-02').setHours(8, 15, 0, 0)) },
        { completedAt: new Date(new Date('2026-02-03').setHours(8, 30, 0, 0)) },
        { completedAt: new Date(new Date('2026-02-04').setHours(18, 0, 0, 0)) },
        { completedAt: new Date(new Date('2026-02-05').setHours(8, 0, 0, 0)) },
      ];

      const pattern = service.calculateActivityPattern(activities);

      expect(pattern.hourly_distribution[8]).toBe(4);
      expect(pattern.hourly_distribution[18]).toBe(1);
      expect(pattern.most_active_hour).toBe(8);
      expect(pattern.last_updated).toBeInstanceOf(Date);
    });

    it('should find most active hour correctly', () => {
      const activities = [
        { completedAt: new Date(new Date('2026-02-01').setHours(7, 0, 0, 0)) },
        { completedAt: new Date(new Date('2026-02-02').setHours(18, 0, 0, 0)) },
        { completedAt: new Date(new Date('2026-02-03').setHours(18, 15, 0, 0)) },
        { completedAt: new Date(new Date('2026-02-04').setHours(18, 30, 0, 0)) },
      ];

      const pattern = service.calculateActivityPattern(activities);

      expect(pattern.most_active_hour).toBe(18);
      expect(pattern.hourly_distribution[18]).toBe(3);
    });

    it('should handle empty activities array', () => {
      const pattern = service.calculateActivityPattern([]);

      expect(pattern.hourly_distribution).toEqual({});
      expect(pattern.most_active_hour).toBe(20); // Default
    });

    it('should find typical start hour', () => {
      const activities = [
        { completedAt: new Date(new Date('2026-02-01').setHours(7, 0, 0, 0)) },
        { completedAt: new Date(new Date('2026-02-02').setHours(7, 15, 0, 0)) },
        { completedAt: new Date(new Date('2026-02-03').setHours(8, 0, 0, 0)) },
        { completedAt: new Date(new Date('2026-02-04').setHours(19, 0, 0, 0)) },
      ];

      const pattern = service.calculateActivityPattern(activities);

      expect(pattern.typical_start_hour).toBe(7);
    });
  });

  describe('calculateOptimalReminderTime', () => {
    it('should return 1 hour before peak activity', () => {
      const pattern = {
        hourly_distribution: { 18: 10 },
        most_active_hour: 18,
        typical_start_hour: 7,
        last_updated: new Date(),
      };

      const reminderTime = service.calculateOptimalReminderTime(pattern);

      expect(reminderTime.getHours()).toBe(17); // 18 - 1
    });

    it('should clamp to minimum 7am', () => {
      const pattern = {
        hourly_distribution: { 6: 10 },
        most_active_hour: 6,
        typical_start_hour: 6,
        last_updated: new Date(),
      };

      const reminderTime = service.calculateOptimalReminderTime(pattern);

      expect(reminderTime.getHours()).toBeGreaterThanOrEqual(7);
    });

    it('should clamp to maximum 21:00', () => {
      const pattern = {
        hourly_distribution: { 23: 10 },
        most_active_hour: 23,
        typical_start_hour: 20,
        last_updated: new Date(),
      };

      const reminderTime = service.calculateOptimalReminderTime(pattern);

      expect(reminderTime.getHours()).toBeLessThanOrEqual(21);
    });

    it('should handle default pattern', () => {
      const pattern = {
        hourly_distribution: {},
        most_active_hour: 20,
        typical_start_hour: 7,
        last_updated: new Date(),
      };

      const reminderTime = service.calculateOptimalReminderTime(pattern);

      expect(reminderTime.getHours()).toBe(19); // 20 - 1
    });
  });

  describe('analyzeUserPattern', () => {
    it('should skip users with insufficient activities', async () => {
      mockPrismaService.user.findUnique.mockResolvedValue({
        id: 'user-1',
        activities: [
          { completedAt: new Date() },
          { completedAt: new Date() },
        ], // Only 2 activities
      });

      const result = await service.analyzeUserPattern('user-1');

      expect(result).toBeNull();
      expect(mockPrismaService.user.update).not.toHaveBeenCalled();
    });

    it('should analyze and update user pattern successfully', async () => {
      const mockActivities = [
        { completedAt: new Date(new Date('2026-02-01').setHours(8, 0, 0, 0)) },
        { completedAt: new Date(new Date('2026-02-02').setHours(8, 0, 0, 0)) },
        { completedAt: new Date(new Date('2026-02-03').setHours(8, 0, 0, 0)) },
        { completedAt: new Date(new Date('2026-02-04').setHours(18, 0, 0, 0)) },
      ];

      mockPrismaService.user.findUnique.mockResolvedValue({
        id: 'user-1',
        activities: mockActivities,
      });

      mockPrismaService.user.update.mockResolvedValue({});

      const result = await service.analyzeUserPattern('user-1');

      expect(result).toBeDefined();
      expect(result?.most_active_hour).toBe(8);
      expect(mockPrismaService.user.update).toHaveBeenCalledWith({
        where: { id: 'user-1' },
        data: expect.objectContaining({
          activityTimePattern: expect.any(Object),
          preferredReminderTime: expect.any(Date),
        }),
      });
    });

    it('should return null for null user', async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(null);

      const result = await service.analyzeUserPattern('nonexistent-user');

      expect(result).toBeNull();
    });
  });

  describe('analyzeUserActivityPatterns (Cron Job)', () => {
    it('should process all active users', async () => {
      const mockUsers = [
        {
          id: 'user-1',
          activities: [
            { completedAt: new Date() },
            { completedAt: new Date() },
            { completedAt: new Date() },
          ],
        },
        {
          id: 'user-2',
          activities: [
            { completedAt: new Date() },
            { completedAt: new Date() },
            { completedAt: new Date() },
            { completedAt: new Date() },
          ],
        },
      ];

      mockPrismaService.user.findMany.mockResolvedValue(mockUsers);
      mockPrismaService.user.update.mockResolvedValue({});

      await service.analyzeUserActivityPatterns();

      expect(mockPrismaService.user.update).toHaveBeenCalledTimes(2);
    });

    it('should skip users with less than 3 activities', async () => {
      const mockUsers = [
        {
          id: 'user-1',
          activities: [
            { completedAt: new Date() },
            { completedAt: new Date() },
          ], // Only 2
        },
        {
          id: 'user-2',
          activities: [
            { completedAt: new Date() },
            { completedAt: new Date() },
            { completedAt: new Date() },
          ], // 3 - OK
        },
      ];

      mockPrismaService.user.findMany.mockResolvedValue(mockUsers);
      mockPrismaService.user.update.mockResolvedValue({});

      await service.analyzeUserActivityPatterns();

      // Only user-2 should be updated
      expect(mockPrismaService.user.update).toHaveBeenCalledTimes(1);
      expect(mockPrismaService.user.update).toHaveBeenCalledWith({
        where: { id: 'user-2' },
        data: expect.any(Object),
      });
    });

    it('should handle errors gracefully', async () => {
      mockPrismaService.user.findMany.mockRejectedValue(new Error('DB Error'));

      await expect(service.analyzeUserActivityPatterns()).resolves.not.toThrow();
    });
  });

  describe('getUserPreferredTime', () => {
    it('should return user preferred time', async () => {
      const preferredTime = new Date('2026-02-05T17:00:00Z');
      mockPrismaService.user.findUnique.mockResolvedValue({
        preferredReminderTime: preferredTime,
      });

      const result = await service.getUserPreferredTime('user-1');

      expect(result).toEqual(preferredTime);
    });

    it('should return null if user has no preference', async () => {
      mockPrismaService.user.findUnique.mockResolvedValue({
        preferredReminderTime: null,
      });

      const result = await service.getUserPreferredTime('user-1');

      expect(result).toBeNull();
    });

    it('should return null if user not found', async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(null);

      const result = await service.getUserPreferredTime('nonexistent');

      expect(result).toBeNull();
    });
  });
});
