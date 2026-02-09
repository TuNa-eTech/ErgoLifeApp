import { IsEnum, IsString, IsOptional, IsBoolean, IsObject, IsNumber, Min, Max } from 'class-validator';
import { Type, Transform } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { NotificationType, NotificationPriority } from '@prisma/client';

export class CreateNotificationDto {
  @ApiProperty({ description: 'User ID to send notification to' })
  @IsString()
  userId: string;

  @ApiProperty({ enum: NotificationType, description: 'Type of notification' })
  @IsEnum(NotificationType)
  type: NotificationType;

  @ApiPropertyOptional({ enum: NotificationPriority, default: NotificationPriority.MEDIUM })
  @IsEnum(NotificationPriority)
  @IsOptional()
  priority?: NotificationPriority;

  @ApiProperty({ description: 'Notification title' })
  @IsString()
  title: string;

  @ApiProperty({ description: 'Notification body' })
  @IsString()
  body: string;

  @ApiPropertyOptional({ description: 'Image URL for rich notifications' })
  @IsString()
  @IsOptional()
  imageUrl?: string;

  @ApiPropertyOptional({ description: 'Additional data as JSON object' })
  @IsObject()
  @IsOptional()
  data?: Record<string, any>;

  @ApiPropertyOptional({ description: 'Deep link URL (e.g., ergolife://house/123)' })
  @IsString()
  @IsOptional()
  actionUrl?: string;

  @ApiPropertyOptional({ description: 'Schedule notification for future (ISO 8601)' })
  @IsOptional()
  scheduledFor?: Date;

  @ApiPropertyOptional({ description: 'Send push notification immediately', default: true })
  @IsBoolean()
  @IsOptional()
  sendPush?: boolean;
}

export class GetNotificationsDto {
  @ApiPropertyOptional({ description: 'Page number', default: 1 })
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @IsOptional()
  page?: number = 1;

  @ApiPropertyOptional({ description: 'Items per page', default: 20 })
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(100)
  @IsOptional()
  limit?: number = 20;

  @ApiPropertyOptional({ description: 'Filter unread only', default: false })
  @Transform(({ value }) => value === 'true' || value === true)
  @IsBoolean()
  @IsOptional()
  unreadOnly?: boolean = false;

  @ApiPropertyOptional({ enum: NotificationType, description: 'Filter by notification type' })
  @IsEnum(NotificationType)
  @IsOptional()
  type?: NotificationType;
}

export class MarkAsReadDto {
  @ApiProperty({ description: 'Notification ID to mark as read' })
  @IsString()
  notificationId: string;
}

export class NotificationResponseDto {
  id: string;
  userId: string;
  type: NotificationType;
  priority: NotificationPriority;
  title: string;
  body: string;
  imageUrl?: string;
  data?: Record<string, any>;
  actionUrl?: string;
  isRead: boolean;
  isSent: boolean;
  sentAt?: Date;
  readAt?: Date;
  scheduledFor?: Date;
  createdAt: Date;
}
