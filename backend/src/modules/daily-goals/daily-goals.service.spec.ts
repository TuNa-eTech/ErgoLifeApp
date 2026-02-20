import { Test, TestingModule } from '@nestjs/testing';
import { DailyGoalsService } from './daily-goals.service';
import { PrismaService } from '../../prisma/prisma.service';

describe('DailyGoalsService', () => {
  let service: DailyGoalsService;
  let prismaService: PrismaService;

  const mockDate = new Date(
    Date.UTC(2026, 1, 20), // 2026-02-20
  );

  const mockGoal = {
    id: 'goal-uuid',
    userId: 'user-uuid',
    date: mockDate,
    targetEp: 500,
    targetDuration: 30,
    targetActivities: 2,
    currentEp: 0,
    currentDuration: 0,
    currentActivities: 0,
    isPerfectDay: false,
    completedAt: null,
    createdAt: mockDate,
    updatedAt: mockDate,
  };

  const mockSettings = {
    id: 'settings-uuid',
    userId: 'user-uuid',
    targetEp: 500,
    targetDuration: 30,
    targetActivities: 2,
    createdAt: mockDate,
    updatedAt: mockDate,
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        DailyGoalsService,
        {
          provide: PrismaService,
          useValue: {
            dailyGoal: {
              findUnique: jest.fn(),
              create: jest.fn(),
              update: jest.fn(),
              findMany: jest.fn(),
            },
            userGoalSettings: {
              findUnique: jest.fn(),
              create: jest.fn(),
              upsert: jest.fn(),
            },
          },
        },
      ],
    }).compile();

    service = module.get<DailyGoalsService>(DailyGoalsService);
    prismaService = module.get<PrismaService>(PrismaService);
  });

  describe('getTodayGoal', () => {
    it('should return existing goal if found', async () => {
      jest
        .spyOn(prismaService.dailyGoal, 'findUnique')
        .mockResolvedValue(mockGoal as any);

      const result = await service.getTodayGoal('user-uuid');

      expect(result.id).toBe('goal-uuid');
      expect(result.targetEp).toBe(500);
      expect(result.epProgress).toBe(0);
      expect(result.durationProgress).toBe(0);
      expect(result.activitiesProgress).toBe(0);
      expect(result.isPerfectDay).toBe(false);
    });

    it('should create new goal if not found', async () => {
      jest
        .spyOn(prismaService.dailyGoal, 'findUnique')
        .mockResolvedValue(null);
      jest
        .spyOn(prismaService.userGoalSettings, 'findUnique')
        .mockResolvedValue(mockSettings as any);
      jest
        .spyOn(prismaService.dailyGoal, 'create')
        .mockResolvedValue(mockGoal as any);

      const result = await service.getTodayGoal('user-uuid');

      expect(result.id).toBe('goal-uuid');
      expect(prismaService.dailyGoal.create).toHaveBeenCalled();
    });
  });

  describe('updateProgress', () => {
    it('should increment progress and detect non-perfect day', async () => {
      jest
        .spyOn(prismaService.dailyGoal, 'findUnique')
        .mockResolvedValue(mockGoal as any);
      jest
        .spyOn(prismaService.dailyGoal, 'update')
        .mockResolvedValue({} as any);

      await service.updateProgress('user-uuid', 200, 15);

      expect(prismaService.dailyGoal.update).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            currentEp: 200,
            currentDuration: 15,
            currentActivities: 1,
            isPerfectDay: false,
          }),
        }),
      );
    });

    it('should detect perfect day when all rings are closed', async () => {
      const almostDoneGoal = {
        ...mockGoal,
        currentEp: 400,
        currentDuration: 20,
        currentActivities: 1,
      };

      jest
        .spyOn(prismaService.dailyGoal, 'findUnique')
        .mockResolvedValue(almostDoneGoal as any);
      jest
        .spyOn(prismaService.dailyGoal, 'update')
        .mockResolvedValue({} as any);

      await service.updateProgress('user-uuid', 300, 15);

      expect(prismaService.dailyGoal.update).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            currentEp: 700,
            currentDuration: 35,
            currentActivities: 2,
            isPerfectDay: true,
          }),
        }),
      );
    });

    it('should create goal if not exists before updating', async () => {
      jest
        .spyOn(prismaService.dailyGoal, 'findUnique')
        .mockResolvedValue(null);
      jest
        .spyOn(prismaService.userGoalSettings, 'findUnique')
        .mockResolvedValue(mockSettings as any);
      jest
        .spyOn(prismaService.dailyGoal, 'create')
        .mockResolvedValue(mockGoal as any);
      jest
        .spyOn(prismaService.dailyGoal, 'update')
        .mockResolvedValue({} as any);

      await service.updateProgress('user-uuid', 100, 10);

      expect(prismaService.dailyGoal.create).toHaveBeenCalled();
      expect(prismaService.dailyGoal.update).toHaveBeenCalled();
    });
  });

  describe('updateGoalSettings', () => {
    it('should upsert goal settings', async () => {
      const newSettings = {
        ...mockSettings,
        targetEp: 1000,
        targetDuration: 60,
      };

      jest
        .spyOn(prismaService.userGoalSettings, 'upsert')
        .mockResolvedValue(newSettings as any);

      const result = await service.updateGoalSettings('user-uuid', {
        targetEp: 1000,
        targetDuration: 60,
      });

      expect(result.targetEp).toBe(1000);
      expect(result.targetDuration).toBe(60);
      expect(result.targetActivities).toBe(2);
    });
  });

  describe('getHistory', () => {
    it('should return goals for date range', async () => {
      const goals = [mockGoal, { ...mockGoal, id: 'goal-2' }];
      jest
        .spyOn(prismaService.dailyGoal, 'findMany')
        .mockResolvedValue(goals as any);

      const result = await service.getHistory(
        'user-uuid',
        '2026-01-01',
        '2026-02-28',
      );

      expect(result).toHaveLength(2);
      expect(prismaService.dailyGoal.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            userId: 'user-uuid',
          }),
        }),
      );
    });
  });
});
