import {
  Controller,
  Get,
  Post,
  Body,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { ActivitiesService } from './activities.service';
import {
  CreateActivityDto,
  CreateActivityResponseDto,
  GetActivitiesQueryDto,
  GetActivitiesResponseDto,
  GetLeaderboardQueryDto,
  LeaderboardResponseDto,
  GetStatsQueryDto,
  StatsResponseDto,
} from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/auth.service';

@ApiTags('activities')
@Controller('activities')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class ActivitiesController {
  constructor(private readonly activitiesService: ActivitiesService) {}

  @Post()
  @ApiOperation({
    summary: 'Log new activity',
    description: 'Log a completed chore activity after Magic Wipe',
  })
  @ApiResponse({
    status: 201,
    description: 'Activity logged successfully',
    type: CreateActivityResponseDto,
  })
  @ApiResponse({ status: 403, description: 'Not in a house' })
  async create(
    @CurrentUser() user: JwtPayload,
    @Body() createActivityDto: CreateActivityDto,
  ): Promise<CreateActivityResponseDto> {
    return this.activitiesService.create(user.sub, createActivityDto);
  }

  @Get()
  @ApiOperation({
    summary: 'Get activity history',
    description: 'Get paginated activity history for current user',
  })
  @ApiResponse({
    status: 200,
    description: 'Activity history',
    type: GetActivitiesResponseDto,
  })
  async findAll(
    @CurrentUser() user: JwtPayload,
    @Query() query: GetActivitiesQueryDto,
  ): Promise<GetActivitiesResponseDto> {
    return this.activitiesService.findAll(user.sub, query);
  }

  @Get('leaderboard')
  @ApiOperation({
    summary: 'Get weekly leaderboard',
    description: 'Get weekly leaderboard for current house',
  })
  @ApiResponse({
    status: 200,
    description: 'Weekly leaderboard',
    type: LeaderboardResponseDto,
  })
  @ApiResponse({ status: 403, description: 'Not in a house' })
  async getLeaderboard(
    @CurrentUser() user: JwtPayload,
    @Query() query: GetLeaderboardQueryDto,
  ): Promise<LeaderboardResponseDto> {
    return this.activitiesService.getLeaderboard(user.sub, query);
  }

  @Get('stats')
  @ApiOperation({
    summary: 'Get activity statistics',
    description: 'Get personal activity statistics for a period',
  })
  @ApiResponse({
    status: 200,
    description: 'Activity statistics',
    type: StatsResponseDto,
  })
  async getStats(
    @CurrentUser() user: JwtPayload,
    @Query() query: GetStatsQueryDto,
  ): Promise<StatsResponseDto> {
    return this.activitiesService.getStats(user.sub, query);
  }
}
