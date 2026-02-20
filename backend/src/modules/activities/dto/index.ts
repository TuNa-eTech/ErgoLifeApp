import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsInt,
  IsNumber,
  Min,
  Max,
  MinLength,
  MaxLength,
  IsOptional,
  IsDateString,
} from 'class-validator';
import { Type } from 'class-transformer';

// ============= Request DTOs =============

export class CreateActivityDto {
  @ApiProperty({
    example: 'Hút bụi',
    description: 'Task name (1-50 characters)',
    minLength: 1,
    maxLength: 50,
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(1)
  @MaxLength(50)
  taskName: string;

  @ApiProperty({
    example: 1200,
    description: 'Duration in seconds (1-7200)',
    minimum: 1,
    maximum: 7200,
  })
  @IsInt()
  @Min(1, { message: 'Duration must be at least 1 second' })
  @Max(7200, { message: 'Duration must be at most 7200 seconds (2 hours)' })
  durationSeconds: number;

  @ApiProperty({
    example: 3.5,
    description: 'METs value (1.0-10.0)',
    minimum: 1.0,
    maximum: 10.0,
  })
  @IsNumber()
  @Min(1.0, { message: 'METs value must be at least 1.0' })
  @Max(10.0, { message: 'METs value must be at most 10.0' })
  metsValue: number;

  @ApiProperty({
    example: 95,
    description: 'Magic Wipe percentage (70-100)',
    minimum: 70,
    maximum: 100,
  })
  @IsInt()
  @Min(70, { message: 'Magic Wipe percentage must be at least 70' })
  @Max(100)
  magicWipePercentage: number;
}

export class GetActivitiesQueryDto {
  @ApiPropertyOptional({ example: 1, default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ example: 20, default: 20, maximum: 50 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(50)
  limit?: number = 20;

  @ApiPropertyOptional({
    example: '2025-12-01',
    description: 'Filter from date (ISO8601)',
  })
  @IsOptional()
  @IsDateString()
  startDate?: string;

  @ApiPropertyOptional({
    example: '2025-12-31',
    description: 'Filter to date (ISO8601)',
  })
  @IsOptional()
  @IsDateString()
  endDate?: string;
}

export class GetLeaderboardQueryDto {
  @ApiPropertyOptional({
    example: 'house',
    enum: ['house', 'global'],
    default: 'house',
    description: 'Leaderboard scope: house (members) or global (all users)',
  })
  @IsOptional()
  @IsString()
  scope?: 'house' | 'global' = 'house';

  @ApiPropertyOptional({
    example: 10,
    default: 10,
    maximum: 50,
    description: 'Max number of users to return',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(50)
  limit?: number = 10;

  @ApiPropertyOptional({
    example: 2026,
    description: 'Year for monthly leaderboard (default: current year)',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  year?: number;

  @ApiPropertyOptional({
    example: 2,
    description: 'Month 1-12 for monthly leaderboard (default: current month)',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(12)
  month?: number;
}

export class GetStatsQueryDto {
  @ApiPropertyOptional({
    example: 'week',
    enum: ['week', 'month', 'all'],
    default: 'week',
  })
  @IsOptional()
  @IsString()
  period?: 'week' | 'month' | 'all' = 'week';

  @ApiPropertyOptional({
    example: 'Hút bụi',
    description: 'Filter by specific task name',
  })
  @IsOptional()
  @IsString()
  taskName?: string;

  @ApiPropertyOptional({
    example: 2025,
    description: 'Filter by year',
  })
  @IsOptional()
  @IsInt()
  @Type(() => Number)
  year?: number;

  @ApiPropertyOptional({
    example: 12,
    description: 'Filter by month (1-12)',
  })
  @IsOptional()
  @IsInt()
  @Type(() => Number)
  @Min(1)
  @Max(12)
  month?: number;
}

// ============= Response DTOs =============

export class ActivityDto {
  @ApiProperty({ example: '770e8400-e29b-41d4-a716-446655442222' })
  id: string;

  @ApiProperty({ example: 'Hút bụi' })
  taskName: string;

  @ApiProperty({ example: 1200 })
  durationSeconds: number;

  @ApiProperty({ example: 3.5 })
  metsValue: number;

  @ApiProperty({ example: 770 })
  pointsEarned: number;

  @ApiProperty({ example: 1.1 })
  bonusMultiplier: number;

  @ApiProperty({ example: '2025-12-20T10:30:00.000Z' })
  completedAt: Date;
}

export class WalletUpdateDto {
  @ApiProperty({ example: 2500 })
  previousBalance: number;

  @ApiProperty({ example: 770 })
  pointsEarned: number;

  @ApiProperty({ example: 3270 })
  newBalance: number;
}

export class StreakUpdateDto {
  @ApiProperty({ example: 14 })
  previousStreak: number;

  @ApiProperty({ example: 15 })
  currentStreak: number;

  @ApiProperty({ example: 28 })
  longestStreak: number;

  @ApiProperty({ example: 1 })
  streakFreezeCount: number;

  @ApiProperty({
    example: 'STREAK_INCREASED',
    enum: [
      'STREAK_INCREASED',
      'STREAK_STARTED',
      'STREAK_MAINTAINED',
      'STREAK_FREEZE_USED',
      'STREAK_FREEZE_BONUS',
      'STREAK_RESET',
    ],
  })
  message:
    | 'STREAK_INCREASED'
    | 'STREAK_STARTED'
    | 'STREAK_MAINTAINED'
    | 'STREAK_FREEZE_USED'
    | 'STREAK_FREEZE_BONUS'
    | 'STREAK_RESET';

  @ApiPropertyOptional({
    example:
      'You missed yesterday, but your Streak Freeze kept your streak safe! 🛡️',
  })
  info?: string;
}

export class CreateActivityResponseDto {
  @ApiProperty({ type: ActivityDto })
  activity: ActivityDto;

  @ApiProperty({ type: WalletUpdateDto })
  wallet: WalletUpdateDto;

  @ApiProperty({ type: StreakUpdateDto })
  streak: StreakUpdateDto;
}

export class PaginationDto {
  @ApiProperty({ example: 1 })
  page: number;

  @ApiProperty({ example: 20 })
  limit: number;

  @ApiProperty({ example: 150 })
  total: number;

  @ApiProperty({ example: 8 })
  totalPages: number;
}

export class ActivitySummaryDto {
  @ApiProperty({ example: 1145 })
  totalPoints: number;

  @ApiProperty({ example: 2100 })
  totalDuration: number;

  @ApiProperty({ example: 2 })
  activityCount: number;
}

export class GetActivitiesResponseDto {
  @ApiProperty({ type: [ActivityDto] })
  items: ActivityDto[];

  @ApiProperty({ type: PaginationDto })
  pagination: PaginationDto;

  @ApiProperty({ type: ActivitySummaryDto })
  summary: ActivitySummaryDto;
}

export class LeaderboardUserDto {
  @ApiProperty({ example: '550e8400-e29b-41d4-a716-446655440000' })
  id: string;

  @ApiPropertyOptional({ example: 'Minh Nguyễn' })
  displayName: string | null;

  @ApiPropertyOptional({ example: 3 })
  avatarId: number | null;
}

export class LeaderboardEntryDto {
  @ApiProperty({ example: 1 })
  rank: number;

  @ApiProperty({ type: LeaderboardUserDto })
  user: LeaderboardUserDto;

  @ApiProperty({ example: 5200 })
  weeklyPoints: number;

  @ApiProperty({ example: 12 })
  activityCount: number;
}

export class LeaderboardResponseDto {
  @ApiProperty({ example: 'house', enum: ['house', 'global'] })
  scope: 'house' | 'global';

  @ApiProperty({ example: '2026-02' })
  month: string;

  @ApiProperty({ example: '2026-02-01T00:00:00.000Z' })
  monthStart: string;

  @ApiProperty({ example: '2026-02-28T23:59:59.999Z' })
  monthEnd: string;

  @ApiProperty({ type: [LeaderboardEntryDto] })
  rankings: LeaderboardEntryDto[];
}

export class TopTaskDto {
  @ApiProperty({ example: 'Hút bụi' })
  taskName: string;

  @ApiProperty({ example: 4 })
  count: number;

  @ApiProperty({ example: 2800 })
  totalPoints: number;

  @ApiProperty({ example: 3600 })
  totalDuration: number;
}

export class StreakDto {
  @ApiProperty({ example: 5 })
  current: number;

  @ApiProperty({ example: 12 })
  longest: number;
}

export class StatsResponseDto {
  @ApiProperty({ example: 'week' })
  period: string;

  @ApiProperty({ example: 5200 })
  totalPoints: number;

  @ApiProperty({ example: 12 })
  totalActivities: number;

  @ApiProperty({ example: 28800 })
  totalDuration: number;

  @ApiProperty({ example: 850 })
  estimatedCalories: number;

  @ApiProperty({ type: [TopTaskDto] })
  topTasks: TopTaskDto[];

  @ApiProperty({ type: StreakDto })
  streak: StreakDto;
}

// ============= Chart DTOs =============

export class GetDailyBreakdownQueryDto {
  @ApiPropertyOptional({
    example: 7,
    default: 7,
    minimum: 1,
    maximum: 90,
    description: 'Number of days to include (1-90)',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(90)
  days?: number = 7;
}

export class GetHeatmapQueryDto {
  @ApiPropertyOptional({
    example: 2026,
    description: 'Year for heatmap (default: current)',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  year?: number;
}

export class DailyBreakdownItemDto {
  @ApiProperty({ example: '2026-02-20' })
  date: string;

  @ApiProperty({ example: 850 })
  points: number;

  @ApiProperty({ example: 3600 })
  duration: number;

  @ApiProperty({ example: 3 })
  count: number;
}

export class DailyBreakdownResponseDto {
  @ApiProperty({ type: [DailyBreakdownItemDto] })
  data: DailyBreakdownItemDto[];

  @ApiProperty({ example: '2026-02-14' })
  startDate: string;

  @ApiProperty({ example: '2026-02-20' })
  endDate: string;
}

export class HeatmapItemDto {
  @ApiProperty({ example: '2026-02-20' })
  date: string;

  @ApiProperty({
    example: 3,
    description: 'Intensity level 0-4',
  })
  intensity: number;

  @ApiProperty({ example: 3 })
  count: number;

  @ApiProperty({ example: 850 })
  points: number;
}

export class HeatmapResponseDto {
  @ApiProperty({ example: 2026 })
  year: number;

  @ApiProperty({ type: [HeatmapItemDto] })
  data: HeatmapItemDto[];
}
