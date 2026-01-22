
import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { AdminStatsService } from './stats.service';

@ApiTags('Admin Stats')
@ApiBearerAuth()
@UseGuards(AuthGuard('admin-jwt'))
@Controller('admin/stats')
export class AdminStatsController {
  constructor(private readonly statsService: AdminStatsService) {}

  @Get('dashboard')
  @ApiOperation({ summary: 'Get dashboard overview statistics' })
  getDashboardStats() {
    return this.statsService.getDashboardStats();
  }

  @Get('growth')
  @ApiOperation({ summary: 'Get user growth statistics' })
  getGrowthStats() {
    return this.statsService.getGrowthStats();
  }
}
