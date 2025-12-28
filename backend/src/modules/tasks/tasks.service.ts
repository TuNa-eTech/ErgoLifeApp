import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import {
  CreateCustomTaskDto,
  CustomTaskResponseDto,
  GetCustomTasksResponseDto,
} from './dto';

@Injectable()
export class TasksService {
  constructor(private prisma: PrismaService) {}

  async createCustomTask(
    userId: string,
    dto: CreateCustomTaskDto,
  ): Promise<CustomTaskResponseDto> {
    const task = await this.prisma.customTask.create({
      data: {
        userId,
        exerciseName: dto.exerciseName,
        taskDescription: dto.taskDescription,
        durationMinutes: dto.durationMinutes,
        metsValue: dto.metsValue ?? 3.5,
        icon: dto.icon ?? 'fitness_center',
      },
    });

    return this.mapToResponse(task);
  }

  async getCustomTasks(userId: string): Promise<GetCustomTasksResponseDto> {
    const tasks = await this.prisma.customTask.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });

    return {
      tasks: tasks.map((t) => this.mapToResponse(t)),
      total: tasks.length,
    };
  }

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

  private mapToResponse(task: {
    id: string;
    exerciseName: string;
    taskDescription: string | null;
    durationMinutes: number;
    metsValue: number;
    icon: string;
    isFavorite: boolean;
    createdAt: Date;
  }): CustomTaskResponseDto {
    return {
      id: task.id,
      exerciseName: task.exerciseName,
      taskDescription: task.taskDescription,
      durationMinutes: task.durationMinutes,
      metsValue: task.metsValue,
      icon: task.icon,
      isFavorite: task.isFavorite,
      createdAt: task.createdAt,
    };
  }
}
