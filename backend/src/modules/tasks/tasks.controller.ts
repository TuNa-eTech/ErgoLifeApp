import {
  Controller,
  Get,
  Post,
  Delete,
  Patch,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import { TasksService } from './tasks.service';
import { CreateCustomTaskDto } from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/auth.service';

@Controller('tasks')
@UseGuards(JwtAuthGuard)
export class TasksController {
  constructor(private readonly tasksService: TasksService) {}

  @Post('custom')
  async createCustomTask(
    @CurrentUser() user: JwtPayload,
    @Body() dto: CreateCustomTaskDto,
  ) {
    return {
      success: true,
      data: await this.tasksService.createCustomTask(user.sub, dto),
    };
  }

  @Get('custom')
  async getCustomTasks(@CurrentUser() user: JwtPayload) {
    return {
      success: true,
      data: await this.tasksService.getCustomTasks(user.sub),
    };
  }

  @Delete('custom/:id')
  async deleteCustomTask(
    @CurrentUser() user: JwtPayload,
    @Param('id') taskId: string,
  ) {
    await this.tasksService.deleteCustomTask(user.sub, taskId);
    return {
      success: true,
      message: 'Custom task deleted successfully',
    };
  }

  @Patch('custom/:id/favorite')
  async toggleFavorite(
    @CurrentUser() user: JwtPayload,
    @Param('id') taskId: string,
  ) {
    return {
      success: true,
      data: await this.tasksService.toggleFavorite(user.sub, taskId),
    };
  }
}
