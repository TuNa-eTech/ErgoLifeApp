import {
  Controller,
  Get,
  Post,
  Body,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { AdminNotificationsService } from './notifications.service';

class BroadcastNotificationDto {
  title: string;
  body: string;
  type?: string;
  priority?: string;
}

@ApiTags('Admin Notifications')
@ApiBearerAuth()
@UseGuards(AuthGuard('admin-jwt'))
@Controller('admin/notifications')
export class AdminNotificationsController {
  constructor(
    private readonly notificationsService: AdminNotificationsService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'List all notifications' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'type', required: false, type: String })
  @ApiQuery({ name: 'userId', required: false, type: String })
  findAll(
    @Query('page') page = 1,
    @Query('limit') limit = 20,
    @Query('type') type?: string,
    @Query('userId') userId?: string,
  ) {
    return this.notificationsService.findAll(
      Number(page),
      Number(limit),
      type,
      userId,
    );
  }

  @Get('stats')
  @ApiOperation({ summary: 'Get notification delivery stats' })
  getStats() {
    return this.notificationsService.getStats();
  }

  @Post('broadcast')
  @ApiOperation({ summary: 'Send broadcast notification to all users' })
  broadcast(@Body() dto: BroadcastNotificationDto) {
    return this.notificationsService.broadcast(dto);
  }
}
