import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { AdminStatsService } from './stats.service';

@ApiTags('Admin Stats')
@ApiBearerAuth()
@UseGuards(AuthGuard('admin-jwt'))
@Controller('admin/stats')
export class AdminStatsController {
  constructor(private readonly statsService: AdminStatsService) {}

  @Get('dashboard')
  @ApiOperation({ summary: 'Get dashboard overview statistics with trends' })
  getDashboardStats() {
    return this.statsService.getDashboardStats();
  }

  @Get('growth')
  @ApiOperation({ summary: 'Get user growth statistics (last 30 days)' })
  getGrowthStats() {
    return this.statsService.getGrowthStats();
  }

  @Get('activities')
  @ApiOperation({ summary: 'Get activity completion stats by day' })
  @ApiQuery({ name: 'days', required: false, type: Number })
  getActivityStats(@Query('days') days?: string) {
    return this.statsService.getActivityStats(
      days ? parseInt(days, 10) : 7,
    );
  }

  @Get('houses')
  @ApiOperation({ summary: 'Get house distribution stats' })
  getHouseDistribution() {
    return this.statsService.getHouseDistribution();
  }

  @Get('recent-events')
  @ApiOperation({ summary: 'Get recent system events' })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  getRecentEvents(@Query('limit') limit?: string) {
    return this.statsService.getRecentEvents(
      limit ? parseInt(limit, 10) : 10,
    );
  }

  @Get('streaks')
  @ApiOperation({ summary: 'Get streak distribution stats' })
  getStreakStats() {
    return this.statsService.getStreakStats();
  }

  @Get('leaderboard')
  @ApiOperation({ summary: 'Get top users leaderboard preview' })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  getLeaderboardPreview(@Query('limit') limit?: string) {
    return this.statsService.getLeaderboardPreview(
      limit ? parseInt(limit, 10) : 5,
    );
  }
}
