import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import {
  CreateCustomTaskDto,
  UpdateCustomTaskDto,
  CustomTaskResponseDto,
  GetCustomTasksResponseDto,
  SeedTaskDto,
  ReorderTasksDto,
  SeedResultDto,
} from './dto';

@Injectable()
export class TasksService {
  constructor(private prisma: PrismaService) {}

  /**
   * Create a custom task
   */
  async createCustomTask(
    userId: string,
    dto: CreateCustomTaskDto,
  ): Promise<CustomTaskResponseDto> {
    // Get the max sortOrder for this user
    const maxSort = await this.prisma.customTask.aggregate({
      where: { userId },
      _max: { sortOrder: true },
    });
    const nextSortOrder = (maxSort._max.sortOrder ?? -1) + 1;

    const task = await this.prisma.customTask.create({
      data: {
        userId,
        templateId: dto.templateId,
        exerciseName: dto.exerciseName,
        taskDescription: dto.taskDescription,
        durationMinutes: dto.durationMinutes,
        metsValue: dto.metsValue ?? 3.5,
        icon: dto.icon ?? 'fitness_center',
        animation: dto.animation,
        color: dto.color ?? '#FF6A00',
        sortOrder: nextSortOrder,
      },
    });

    return this.mapToResponse(task);
  }

  /**
   * Get all user tasks (visible and hidden)
   */
  async getCustomTasks(
    userId: string,
    includeHidden: boolean = false,
  ): Promise<GetCustomTasksResponseDto> {
    const where = includeHidden ? { userId } : { userId, isHidden: false };

    const tasks = await this.prisma.customTask.findMany({
      where,
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'desc' }],
    });

    return {
      tasks: tasks.map((t) => this.mapToResponse(t)),
      total: tasks.length,
    };
  }

  /**
   * Update a custom task
   */
  async updateCustomTask(
    userId: string,
    taskId: string,
    dto: UpdateCustomTaskDto,
  ): Promise<CustomTaskResponseDto> {
    const task = await this.prisma.customTask.findFirst({
      where: { id: taskId, userId },
    });

    if (!task) {
      throw new NotFoundException('Custom task not found');
    }

    const updated = await this.prisma.customTask.update({
      where: { id: taskId },
      data: {
        exerciseName: dto.exerciseName,
        taskDescription: dto.taskDescription,
        durationMinutes: dto.durationMinutes,
        metsValue: dto.metsValue,
        icon: dto.icon,
        animation: dto.animation,
        color: dto.color,
        isHidden: dto.isHidden,
        isFavorite: dto.isFavorite,
      },
    });

    return this.mapToResponse(updated);
  }

  /**
   * Delete a custom task
   */
  async deleteCustomTask(userId: string, taskId: string): Promise<void> {
    const task = await this.prisma.customTask.findFirst({
      where: { id: taskId, userId },
    });

    if (!task) {
      throw new NotFoundException('Custom task not found');
    }

    await this.prisma.customTask.delete({
      where: { id: taskId },
    });
  }

  /**
   * Toggle favorite status
   */
  async toggleFavorite(
    userId: string,
    taskId: string,
  ): Promise<CustomTaskResponseDto> {
    const task = await this.prisma.customTask.findFirst({
      where: { id: taskId, userId },
    });

    if (!task) {
      throw new NotFoundException('Custom task not found');
    }

    const updated = await this.prisma.customTask.update({
      where: { id: taskId },
      data: { isFavorite: !task.isFavorite },
    });

    return this.mapToResponse(updated);
  }

  /**
   * Toggle hidden status
   */
  async toggleHidden(
    userId: string,
    taskId: string,
  ): Promise<CustomTaskResponseDto> {
    const task = await this.prisma.customTask.findFirst({
      where: { id: taskId, userId },
    });

    if (!task) {
      throw new NotFoundException('Custom task not found');
    }

    const updated = await this.prisma.customTask.update({
      where: { id: taskId },
      data: { isHidden: !task.isHidden },
    });

    return this.mapToResponse(updated);
  }

  /**
   * Reorder tasks
   */
  async reorderTasks(
    userId: string,
    dto: ReorderTasksDto,
  ): Promise<GetCustomTasksResponseDto> {
    // Update sortOrder for each task
    await this.prisma.$transaction(
      dto.tasks.map((item) =>
        this.prisma.customTask.updateMany({
          where: { id: item.id, userId },
          data: { sortOrder: item.sortOrder },
        }),
      ),
    );

    return this.getCustomTasks(userId);
  }

  /**
   * Seed default tasks from templates (first login only)
   */
  async seedDefaultTasks(
    userId: string,
    tasks: SeedTaskDto[],
  ): Promise<SeedResultDto> {
    // Check if user already has seeded tasks
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { hasSeededTasks: true },
    });

    if (user?.hasSeededTasks) {
      return { seeded: false, tasksCreated: 0 };
    }

    // Create tasks in transaction
    await this.prisma.$transaction(async (tx) => {
      // Create all tasks
      await tx.customTask.createMany({
        data: tasks.map((task, index) => ({
          userId,
          templateId: task.templateId,
          exerciseName: task.exerciseName,
          taskDescription: task.taskDescription,
          durationMinutes: task.durationMinutes,
          metsValue: task.metsValue,
          icon: task.icon ?? 'fitness_center',
          animation: task.animation,
          color: task.color ?? '#FF6A00',
          sortOrder: index,
        })),
      });

      // Mark user as seeded
      await tx.user.update({
        where: { id: userId },
        data: { hasSeededTasks: true },
      });
    });

    return { seeded: true, tasksCreated: tasks.length };
  }

  /**
   * Check if user needs seeding
   */
  async needsSeeding(userId: string): Promise<boolean> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { hasSeededTasks: true },
    });
    return !user?.hasSeededTasks;
  }

  /**
   * Map database model to response DTO
   */
  private mapToResponse(task: {
    id: string;
    templateId: string | null;
    exerciseName: string;
    taskDescription: string | null;
    durationMinutes: number;
    metsValue: number;
    icon: string;
    animation: string | null;
    color: string;
    sortOrder: number;
    isHidden: boolean;
    isFavorite: boolean;
    createdAt: Date;
  }): CustomTaskResponseDto {
    return {
      id: task.id,
      templateId: task.templateId ?? undefined,
      exerciseName: task.exerciseName,
      taskDescription: task.taskDescription ?? undefined,
      durationMinutes: task.durationMinutes,
      metsValue: task.metsValue,
      icon: task.icon,
      animation: task.animation ?? undefined,
      color: task.color,
      sortOrder: task.sortOrder,
      isHidden: task.isHidden,
      isFavorite: task.isFavorite,
      createdAt: task.createdAt,
    };
  }
}
