import {
  Controller,
  Get,
  Put,
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
import { DailyGoalsService } from './daily-goals.service';
import {
  UpdateGoalSettingsDto,
  DailyGoalResponseDto,
  GoalSettingsResponseDto,
  GetGoalHistoryDto,
} from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/auth.service';

@ApiTags('daily-goals')
@Controller('daily-goals')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class DailyGoalsController {
  constructor(private readonly dailyGoalsService: DailyGoalsService) {}

  @Get('today')
  @ApiOperation({
    summary: "Get today's daily goal",
    description:
      "Get or create today's daily goal progress with ring fill ratios",
  })
  @ApiResponse({
    status: 200,
    description: "Today's daily goal",
    type: DailyGoalResponseDto,
  })
  async getTodayGoal(
    @CurrentUser() user: JwtPayload,
  ): Promise<DailyGoalResponseDto> {
    return this.dailyGoalsService.getTodayGoal(user.sub);
  }

  @Get('settings')
  @ApiOperation({
    summary: 'Get goal settings',
    description: "Get user's default daily goal targets",
  })
  @ApiResponse({
    status: 200,
    description: 'Goal settings',
    type: GoalSettingsResponseDto,
  })
  async getGoalSettings(
    @CurrentUser() user: JwtPayload,
  ): Promise<GoalSettingsResponseDto> {
    return this.dailyGoalsService.getGoalSettings(user.sub);
  }

  @Put('settings')
  @ApiOperation({
    summary: 'Update goal settings',
    description: 'Update default daily goal targets (EP, duration, activities)',
  })
  @ApiResponse({
    status: 200,
    description: 'Updated goal settings',
    type: GoalSettingsResponseDto,
  })
  async updateGoalSettings(
    @CurrentUser() user: JwtPayload,
    @Body() dto: UpdateGoalSettingsDto,
  ): Promise<GoalSettingsResponseDto> {
    return this.dailyGoalsService.updateGoalSettings(user.sub, dto);
  }

  @Get('history')
  @ApiOperation({
    summary: 'Get goal history',
    description: 'Get daily goal history for a date range (default: last 30d)',
  })
  @ApiResponse({
    status: 200,
    description: 'Daily goal history',
    type: [DailyGoalResponseDto],
  })
  async getHistory(
    @CurrentUser() user: JwtPayload,
    @Query() query: GetGoalHistoryDto,
  ): Promise<DailyGoalResponseDto[]> {
    return this.dailyGoalsService.getHistory(user.sub, query.from, query.to);
  }
}
