import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import * as admin from 'firebase-admin';

export interface FcmNotificationPayload {
  title: string;
  body: string;
  imageUrl?: string;
}

export interface FcmDataPayload {
  [key: string]: string;
}

export interface SendNotificationDto {
  token: string;
  notification: FcmNotificationPayload;
  data?: FcmDataPayload;
  badge?: number;
}

export interface SendMulticastDto {
  tokens: string[];
  notification: FcmNotificationPayload;
  data?: FcmDataPayload;
}

export interface SendToTopicDto {
  topic: string;
  notification: FcmNotificationPayload;
  data?: FcmDataPayload;
}

/**
 * Firebase Cloud Messaging Service
 * Handles sending push notifications via FCM
 */
@Injectable()
export class FcmService implements OnModuleInit {
  private readonly logger = new Logger(FcmService.name);
  private messaging: admin.messaging.Messaging;

  onModuleInit() {
    // Initialize messaging after Firebase Admin SDK is initialized by FirebaseService
    this.messaging = admin.messaging();
    this.logger.log('FCM Service initialized');
  }

  /**
   * Send notification to a single device
   */
  async send(payload: SendNotificationDto): Promise<string> {
    try {
      const message: admin.messaging.Message = {
        token: payload.token,
        notification: {
          title: payload.notification.title,
          body: payload.notification.body,
          imageUrl: payload.notification.imageUrl,
        },
        data: payload.data,
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'ergolife_notifications',
            priority: 'high',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: payload.badge,
            },
          },
        },
      };

      const response = await this.messaging.send(message);
      this.logger.log(`Successfully sent notification to token: ${payload.token.substring(0, 10)}...`);
      return response;
    } catch (error) {
      this.logger.error(`Error sending notification: ${error.message}`);
      
      // Handle invalid token
      if (
        error.code === 'messaging/invalid-registration-token' ||
        error.code === 'messaging/registration-token-not-registered'
      ) {
        this.logger.warn(`Invalid or unregistered token: ${payload.token.substring(0, 10)}...`);
        throw new Error('INVALID_TOKEN');
      }
      
      throw error;
    }
  }

  /**
   * Send notification to multiple devices
   */
  async sendMulticast(payload: SendMulticastDto): Promise<admin.messaging.BatchResponse> {
    try {
      const message: admin.messaging.MulticastMessage = {
        tokens: payload.tokens,
        notification: {
          title: payload.notification.title,
          body: payload.notification.body,
          imageUrl: payload.notification.imageUrl,
        },
        data: payload.data,
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'ergolife_notifications',
            priority: 'high',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
            },
          },
        },
      };

      const response = await this.messaging.sendEachForMulticast(message);
      this.logger.log(
        `Successfully sent ${response.successCount}/${payload.tokens.length} notifications`,
      );

      // Log failed tokens
      if (response.failureCount > 0) {
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            this.logger.warn(
              `Failed to send to token ${payload.tokens[idx].substring(0, 10)}...: ${resp.error?.message}`,
            );
          }
        });
      }

      return response;
    } catch (error) {
      this.logger.error(`Error sending multicast notification: ${error.message}`);
      throw error;
    }
  }

  /**
   * Send notification to a topic (for house-based notifications)
   */
  async sendToTopic(payload: SendToTopicDto): Promise<string> {
    try {
      const message: admin.messaging.Message = {
        topic: payload.topic,
        notification: {
          title: payload.notification.title,
          body: payload.notification.body,
          imageUrl: payload.notification.imageUrl,
        },
        data: payload.data,
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'ergolife_notifications',
            priority: 'high',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
            },
          },
        },
      };

      const response = await this.messaging.send(message);
      this.logger.log(`Successfully sent notification to topic: ${payload.topic}`);
      return response;
    } catch (error) {
      this.logger.error(`Error sending topic notification: ${error.message}`);
      throw error;
    }
  }

  /**
   * Subscribe device to a topic
   */
  async subscribeToTopic(token: string, topic: string): Promise<void> {
    try {
      await this.messaging.subscribeToTopic([token], topic);
      this.logger.log(`Subscribed token to topic: ${topic}`);
    } catch (error) {
      this.logger.error(`Error subscribing to topic: ${error.message}`);
      throw error;
    }
  }

  /**
   * Unsubscribe device from a topic
   */
  async unsubscribeFromTopic(token: string, topic: string): Promise<void> {
    try {
      await this.messaging.unsubscribeFromTopic([token], topic);
      this.logger.log(`Unsubscribed token from topic: ${topic}`);
    } catch (error) {
      this.logger.error(`Error unsubscribing from topic: ${error.message}`);
      throw error;
    }
  }
}
