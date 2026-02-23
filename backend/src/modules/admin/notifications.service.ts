import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import {
  NotificationType,
  NotificationPriority,
} from '@prisma/client';

@Injectable()
export class AdminNotificationsService {
  private readonly logger = new Logger(AdminNotificationsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly notificationsService: NotificationsService,
  ) {}

  async findAll(
    page: number,
    limit: number,
    type?: string,
    userId?: string,
  ) {
    const where: any = {};
    if (type) where.type = type;
    if (userId) where.userId = userId;

    const [data, total] = await Promise.all([
      this.prisma.notification.findMany({
        where,
        include: {
          user: {
            select: {
              id: true,
              displayName: true,
              email: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.notification.count({ where }),
    ]);

    return {
      data,
      meta: {
        total,
        page,
        limit,
        pages: Math.ceil(total / limit),
      },
    };
  }

  async getStats() {
    const [total, sent, read, byType] = await Promise.all([
      this.prisma.notification.count(),
      this.prisma.notification.count({ where: { isSent: true } }),
      this.prisma.notification.count({ where: { isRead: true } }),
      this.prisma.notification.groupBy({
        by: ['type'],
        _count: { id: true },
      }),
    ]);

    return {
      total,
      sent,
      read,
      unread: total - read,
      byType: byType.map((item) => ({
        type: item.type,
        count: item._count.id,
      })),
    };
  }

  async broadcast(dto: {
    title: string;
    body: string;
    type?: string;
    priority?: string;
  }) {
    const users = await this.prisma.user.findMany({
      select: { id: true },
    });

    const userIds = users.map((u) => u.id);

    await this.notificationsService.sendBulkNotifications(userIds, {
      type: (dto.type as NotificationType) || 'APP_UPDATE',
      title: dto.title,
      body: dto.body,
      priority:
        (dto.priority as NotificationPriority) || 'MEDIUM',
      sendPush: true,
    });

    return {
      message: `Broadcast sent to ${userIds.length} users`,
      count: userIds.length,
    };
  }
}
