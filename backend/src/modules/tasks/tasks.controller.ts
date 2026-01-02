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
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
} from '@nestjs/swagger';
import { TasksService } from './tasks.service';
import { CreateCustomTaskDto } from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/auth.service';

@ApiTags('tasks')
@ApiBearerAuth('JWT-auth')
@Controller('tasks')
@UseGuards(JwtAuthGuard)
export class TasksController {
  constructor(private readonly tasksService: TasksService) {}

  @Post('custom')
  @ApiOperation({
    summary: 'Create custom task',
    description: 'Create a new custom task for the user',
  })
  @ApiResponse({
    status: 201,
    description: 'Custom task created successfully',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
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
  @ApiOperation({
    summary: 'Get custom tasks',
    description: 'Get all custom tasks for the current user',
  })
  @ApiResponse({
    status: 200,
    description: 'List of custom tasks',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getCustomTasks(@CurrentUser() user: JwtPayload) {
    return {
      success: true,
      data: await this.tasksService.getCustomTasks(user.sub),
    };
  }

  @Delete('custom/:id')
  @ApiOperation({
    summary: 'Delete custom task',
    description: 'Delete a custom task by ID',
  })
  @ApiParam({ name: 'id', description: 'Custom task ID' })
  @ApiResponse({
    status: 200,
    description: 'Custom task deleted successfully',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Task not found' })
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
  @ApiOperation({
    summary: 'Toggle favorite',
    description: 'Toggle favorite status of a custom task',
  })
  @ApiParam({ name: 'id', description: 'Custom task ID' })
  @ApiResponse({
    status: 200,
    description: 'Favorite status toggled',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Task not found' })
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
