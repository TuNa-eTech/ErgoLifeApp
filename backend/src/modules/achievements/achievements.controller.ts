import {
  Controller,
  Get,
  UseGuards,
  Headers,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { AchievementsService } from './achievements.service';

interface JwtPayload {
  id: string;
  email: string;
}

@ApiTags('achievements')
@Controller('achievements')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class AchievementsController {
  constructor(
    private readonly achievementsService: AchievementsService,
  ) {}

  @Get()
  @ApiOperation({
    summary: 'Get all badges with earned/locked status',
  })
  getAllBadges(
    @CurrentUser() user: JwtPayload,
    @Headers('accept-language') locale?: string,
  ) {
    return this.achievementsService.getAllBadges(
      user.id,
      locale ?? 'vi',
    );
  }

  @Get('my')
  @ApiOperation({ summary: 'Get only earned badges' })
  getMyBadges(
    @CurrentUser() user: JwtPayload,
    @Headers('accept-language') locale?: string,
  ) {
    return this.achievementsService.getMyBadges(
      user.id,
      locale ?? 'vi',
    );
  }
}
