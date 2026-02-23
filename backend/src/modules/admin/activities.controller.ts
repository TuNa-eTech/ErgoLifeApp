import {
  Controller,
  Get,
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
import { AdminActivitiesService } from './activities.service';

@ApiTags('Admin Activities')
@ApiBearerAuth()
@UseGuards(AuthGuard('admin-jwt'))
@Controller('admin/activities')
export class AdminActivitiesController {
  constructor(
    private readonly activitiesService: AdminActivitiesService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'List all activities' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'userId', required: false, type: String })
  @ApiQuery({ name: 'houseId', required: false, type: String })
  @ApiQuery({ name: 'from', required: false, type: String })
  @ApiQuery({ name: 'to', required: false, type: String })
  findAll(
    @Query('page') page = 1,
    @Query('limit') limit = 20,
    @Query('userId') userId?: string,
    @Query('houseId') houseId?: string,
    @Query('from') from?: string,
    @Query('to') to?: string,
  ) {
    return this.activitiesService.findAll(
      Number(page),
      Number(limit),
      userId,
      houseId,
      from,
      to,
    );
  }
}
