import {
  Controller,
  Get,
  Post,
  Delete,
  Patch,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
  ApiQuery,
} from '@nestjs/swagger';
import { TasksService } from './tasks.service';
import {
  CreateCustomTaskDto,
  UpdateCustomTaskDto,
  SeedTasksDto,
  ReorderTasksDto,
} from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/auth.service';

@ApiTags('tasks')
@ApiBearerAuth('JWT-auth')
@Controller('tasks')
@UseGuards(JwtAuthGuard)
export class TasksController {
  constructor(private readonly tasksService: TasksService) {}

  // ===========================================
  // CRUD ENDPOINTS
  // ===========================================

  @Post()
  @ApiOperation({
    summary: 'Create task',
    description: 'Create a new custom task',
  })
  @ApiResponse({ status: 201, description: 'Task created successfully' })
  async createTask(
    @CurrentUser() user: JwtPayload,
    @Body() dto: CreateCustomTaskDto,
  ) {
    return this.tasksService.createCustomTask(user.sub, dto);
  }

  @Get()
  @ApiOperation({
    summary: 'Get all tasks',
    description: 'Get all tasks for the current user',
  })
  @ApiQuery({
    name: 'includeHidden',
    required: false,
    type: Boolean,
    description: 'Include hidden tasks',
  })
  @ApiResponse({ status: 200, description: 'List of tasks' })
  async getTasks(
    @CurrentUser() user: JwtPayload,
    @Query('includeHidden') includeHidden?: string,
  ) {
    const includeHiddenBool = includeHidden === 'true';
    return this.tasksService.getCustomTasks(user.sub, includeHiddenBool);
  }

  @Patch(':id')
  @ApiOperation({
    summary: 'Update task',
    description: 'Update an existing task',
  })
  @ApiParam({ name: 'id', description: 'Task ID' })
  @ApiResponse({ status: 200, description: 'Task updated successfully' })
  async updateTask(
    @CurrentUser() user: JwtPayload,
    @Param('id') taskId: string,
    @Body() dto: UpdateCustomTaskDto,
  ) {
    return this.tasksService.updateCustomTask(user.sub, taskId, dto);
  }

  @Delete(':id')
  @ApiOperation({
    summary: 'Delete task',
    description: 'Delete a task by ID',
  })
  @ApiParam({ name: 'id', description: 'Task ID' })
  @ApiResponse({ status: 200, description: 'Task deleted successfully' })
  async deleteTask(
    @CurrentUser() user: JwtPayload,
    @Param('id') taskId: string,
  ) {
    await this.tasksService.deleteCustomTask(user.sub, taskId);
    return { message: 'Task deleted successfully' };
  }

  // ===========================================
  // TOGGLE ENDPOINTS
  // ===========================================

  @Patch(':id/favorite')
  @ApiOperation({
    summary: 'Toggle favorite',
    description: 'Toggle favorite status of a task',
  })
  @ApiParam({ name: 'id', description: 'Task ID' })
  @ApiResponse({ status: 200, description: 'Favorite status toggled' })
  async toggleFavorite(
    @CurrentUser() user: JwtPayload,
    @Param('id') taskId: string,
  ) {
    return this.tasksService.toggleFavorite(user.sub, taskId);
  }

  @Patch(':id/visibility')
  @ApiOperation({
    summary: 'Toggle visibility',
    description: 'Toggle hidden/visible status of a task',
  })
  @ApiParam({ name: 'id', description: 'Task ID' })
  @ApiResponse({ status: 200, description: 'Visibility toggled' })
  async toggleHidden(
    @CurrentUser() user: JwtPayload,
    @Param('id') taskId: string,
  ) {
    return this.tasksService.toggleHidden(user.sub, taskId);
  }

  // ===========================================
  // REORDER ENDPOINT
  // ===========================================

  @Post('reorder')
  @ApiOperation({
    summary: 'Reorder tasks',
    description: 'Update sort order of tasks',
  })
  @ApiResponse({ status: 200, description: 'Tasks reordered successfully' })
  async reorderTasks(
    @CurrentUser() user: JwtPayload,
    @Body() dto: ReorderTasksDto,
  ) {
    return this.tasksService.reorderTasks(user.sub, dto);
  }

  // ===========================================
  // SEEDING ENDPOINTS
  // ===========================================

  @Get('needs-seeding')
  @ApiOperation({
    summary: 'Check if user needs seeding',
    description: 'Check if user needs default tasks to be seeded',
  })
  @ApiResponse({ status: 200, description: 'Seeding status' })
  async needsSeeding(@CurrentUser() user: JwtPayload) {
    return {
      needsSeeding: await this.tasksService.needsSeeding(user.sub),
    };
  }

  @Post('seed')
  @ApiOperation({
    summary: 'Seed default tasks',
    description: 'Create default tasks from templates (first login only)',
  })
  @ApiResponse({ status: 201, description: 'Tasks seeded successfully' })
  async seedTasks(
    @CurrentUser() user: JwtPayload,
    @Body() dto: SeedTasksDto,
  ) {
    return this.tasksService.seedDefaultTasks(user.sub, dto.tasks);
  }

  // ===========================================
  // LEGACY ENDPOINTS (for backward compatibility)
  // ===========================================

  @Post('custom')
  @ApiOperation({
    summary: '[Deprecated] Create custom task',
    description: 'Use POST /tasks instead',
    deprecated: true,
  })
  async createCustomTaskLegacy(
    @CurrentUser() user: JwtPayload,
    @Body() dto: CreateCustomTaskDto,
  ) {
    return this.createTask(user, dto);
  }

  @Get('custom')
  @ApiOperation({
    summary: '[Deprecated] Get custom tasks',
    description: 'Use GET /tasks instead',
    deprecated: true,
  })
  async getCustomTasksLegacy(@CurrentUser() user: JwtPayload) {
    return this.getTasks(user);
  }

  @Delete('custom/:id')
  @ApiOperation({
    summary: '[Deprecated] Delete custom task',
    description: 'Use DELETE /tasks/:id instead',
    deprecated: true,
  })
  async deleteCustomTaskLegacy(
    @CurrentUser() user: JwtPayload,
    @Param('id') taskId: string,
  ) {
    return this.deleteTask(user, taskId);
  }

  @Patch('custom/:id/favorite')
  @ApiOperation({
    summary: '[Deprecated] Toggle favorite',
    description: 'Use PATCH /tasks/:id/favorite instead',
    deprecated: true,
  })
  async toggleFavoriteLegacy(
    @CurrentUser() user: JwtPayload,
    @Param('id') taskId: string,
  ) {
    return this.toggleFavorite(user, taskId);
  }
}
