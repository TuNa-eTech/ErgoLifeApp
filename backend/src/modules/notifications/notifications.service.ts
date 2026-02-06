import { Injectable, Logger, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { FcmService } from '../../firebase/fcm.service';
import { CreateNotificationDto, GetNotificationsDto, NotificationResponseDto } from './dto/notification.dto';
import { NotificationType, NotificationPriority, Notification } from '@prisma/client';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly fcmService: FcmService,
  ) {}

  /**
   * Create and optionally send a notification
   */
  async createNotification(dto: CreateNotificationDto): Promise<Notification> {
    // Create notification in database
    const notification = await this.prisma.notification.create({
      data: {
        userId: dto.userId,
        type: dto.type,
        priority: dto.priority || NotificationPriority.MEDIUM,
        title: dto.title,
        body: dto.body,
        imageUrl: dto.imageUrl,
        data: dto.data,
        actionUrl: dto.actionUrl,
        scheduledFor: dto.scheduledFor,
        isSent: false,
      },
    });

    // Send push notification if requested and not scheduled
    if (dto.sendPush !== false && !dto.scheduledFor) {
      await this.sendPushNotification(notification);
    }

    return notification;
  }

  /**
   * Send push notification via FCM
   */
  async sendPushNotification(notification: Notification): Promise<void> {
    try {
      const user = await this.prisma.user.findUnique({
        where: { id: notification.userId },
        select: { fcmToken: true },
      });

      if (!user?.fcmToken) {
        this.logger.warn(`User ${notification.userId} has no FCM token`);
        return;
      }

      // Convert data to string format for FCM
      const fcmData: Record<string, string> = {};
      if (notification.data) {
        Object.entries(notification.data as Record<string, any>).forEach(([key, value]) => {
          fcmData[key] = typeof value === 'string' ? value : JSON.stringify(value);
        });
      }
      if (notification.actionUrl) {
        fcmData.actionUrl = notification.actionUrl;
      }
      fcmData.notificationId = notification.id;

      await this.fcmService.send({
        token: user.fcmToken,
        notification: {
          title: notification.title,
          body: notification.body,
          imageUrl: notification.imageUrl || undefined,
        },
        data: fcmData,
      });

      // Mark as sent
      await this.prisma.notification.update({
        where: { id: notification.id },
        data: {
          isSent: true,
          sentAt: new Date(),
        },
      });

      this.logger.log(`Sent notification ${notification.id} to user ${notification.userId}`);
    } catch (error) {
      this.logger.error(`Failed to send notification ${notification.id}: ${error.message}`);

      // If token is invalid, clear it from user
      if (error.message === 'INVALID_TOKEN') {
        await this.prisma.user.update({
          where: { id: notification.userId },
          data: { fcmToken: null },
        });
      }

      throw error;
    }
  }

  /**
   * Get user's notifications with pagination
   */
  async getUserNotifications(
    userId: string,
    dto: GetNotificationsDto,
  ): Promise<{ notifications: NotificationResponseDto[]; total: number; hasMore: boolean }> {
    const where: any = { userId };

    if (dto.unreadOnly) {
      where.isRead = false;
    }

    if (dto.type) {
      where.type = dto.type;
    }

    const skip = (dto.page - 1) * dto.limit;

    const [notifications, total] = await Promise.all([
      this.prisma.notification.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take: dto.limit,
      }),
      this.prisma.notification.count({ where }),
    ]);

    return {
      notifications: notifications as NotificationResponseDto[],
      total,
      hasMore: skip + notifications.length < total,
    };
  }

  /**
   * Mark notification as read
   */
  async markAsRead(notificationId: string, userId: string): Promise<Notification> {
    const notification = await this.prisma.notification.findUnique({
      where: { id: notificationId },
    });

    if (!notification) {
      throw new NotFoundException('Notification not found');
    }

    if (notification.userId !== userId) {
      throw new ForbiddenException('You can only mark your own notifications as read');
    }

    return this.prisma.notification.update({
      where: { id: notificationId },
      data: {
        isRead: true,
        readAt: new Date(),
      },
    });
  }

  /**
   * Mark all notifications as read for a user
   */
  async markAllAsRead(userId: string): Promise<{ count: number }> {
    const result = await this.prisma.notification.updateMany({
      where: {
        userId,
        isRead: false,
      },
      data: {
        isRead: true,
        readAt: new Date(),
      },
    });

    return { count: result.count };
  }

  /**
   * Delete a notification
   */
  async deleteNotification(notificationId: string, userId: string): Promise<void> {
    const notification = await this.prisma.notification.findUnique({
      where: { id: notificationId },
    });

    if (!notification) {
      throw new NotFoundException('Notification not found');
    }

    if (notification.userId !== userId) {
      throw new ForbiddenException('You can only delete your own notifications');
    }

    await this.prisma.notification.delete({
      where: { id: notificationId },
    });
  }

  /**
   * Get unread count for a user
   */
  async getUnreadCount(userId: string): Promise<number> {
    return this.prisma.notification.count({
      where: {
        userId,
        isRead: false,
      },
    });
  }

  /**
   * Send notification to multiple users
   */
  async sendBulkNotifications(
    userIds: string[],
    notification: Omit<CreateNotificationDto, 'userId'>,
  ): Promise<void> {
    const notifications = await Promise.all(
      userIds.map((userId) =>
        this.createNotification({
          ...notification,
          userId,
        }),
      ),
    );

    this.logger.log(`Created ${notifications.length} bulk notifications`);
  }
}
