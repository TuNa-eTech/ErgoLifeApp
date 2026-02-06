import { Test, TestingModule } from '@nestjs/testing';
import { FcmService } from './fcm.service';
import * as admin from 'firebase-admin';

// Mock firebase-admin
jest.mock('firebase-admin', () => ({
  messaging: jest.fn(),
}));

describe('FcmService', () => {
  let service: FcmService;
  let mockMessaging: jest.Mocked<admin.messaging.Messaging>;

  beforeEach(async () => {
    // Create mock messaging
    mockMessaging = {
      send: jest.fn(),
      sendEachForMulticast: jest.fn(),
      subscribeToTopic: jest.fn(),
      unsubscribeFromTopic: jest.fn(),
    } as any;

    // Mock admin.messaging() to return our mock
    (admin.messaging as jest.Mock).mockReturnValue(mockMessaging);

    const module: TestingModule = await Test.createTestingModule({
      providers: [FcmService],
    }).compile();

    service = module.get<FcmService>(FcmService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('send', () => {
    it('should send notification successfully to a single device', async () => {
      // Arrange
      const payload = {
        token: 'mock-fcm-token-123',
        notification: {
          title: 'Test Notification',
          body: 'This is a test',
        },
        data: { key: 'value' },
      };
      mockMessaging.send.mockResolvedValue('mock-message-id');

      // Act
      const result = await service.send(payload);

      // Assert
      expect(result).toBe('mock-message-id');
      expect(mockMessaging.send).toHaveBeenCalledTimes(1);
      expect(mockMessaging.send).toHaveBeenCalledWith(
        expect.objectContaining({
          token: payload.token,
          notification: expect.objectContaining({
            title: payload.notification.title,
            body: payload.notification.body,
          }),
          data: payload.data,
        }),
      );
    });

    it('should include platform-specific configs', async () => {
      // Arrange
      const payload = {
        token: 'mock-fcm-token',
        notification: {
          title: 'Test',
          body: 'Test body',
        },
        badge: 5,
      };
      mockMessaging.send.mockResolvedValue('message-id');

      // Act
      await service.send(payload);

      // Assert
      const callArgs = mockMessaging.send.mock.calls[0][0];
      expect(callArgs).toHaveProperty('android');
      expect(callArgs).toHaveProperty('apns');
      expect(callArgs.android?.priority).toBe('high');
      expect(callArgs.apns?.payload?.aps?.badge).toBe(5);
    });

    it('should throw INVALID_TOKEN error for invalid token', async () => {
      // Arrange
      const payload = {
        token: 'invalid-token',
        notification: {
          title: 'Test',
          body: 'Test',
        },
      };
      const error: any = new Error('Invalid token');
      error.code = 'messaging/invalid-registration-token';
      mockMessaging.send.mockRejectedValue(error);

      // Act & Assert
      await expect(service.send(payload)).rejects.toThrow('INVALID_TOKEN');
    });

    it('should throw INVALID_TOKEN error for unregistered token', async () => {
      // Arrange
      const payload = {
        token: 'unregistered-token',
        notification: {
          title: 'Test',
          body: 'Test',
        },
      };
      const error: any = new Error('Unregistered');
      error.code = 'messaging/registration-token-not-registered';
      mockMessaging.send.mockRejectedValue(error);

      // Act & Assert
      await expect(service.send(payload)).rejects.toThrow('INVALID_TOKEN');
    });

    it('should rethrow other errors', async () => {
      // Arrange
      const payload = {
        token: 'mock-token',
        notification: {
          title: 'Test',
          body: 'Test',
        },
      };
      const error = new Error('Network error');
      mockMessaging.send.mockRejectedValue(error);

      // Act & Assert
      await expect(service.send(payload)).rejects.toThrow('Network error');
    });
  });

  describe('sendMulticast', () => {
    it('should send notifications to multiple devices', async () => {
      // Arrange
      const payload = {
        tokens: ['token-1', 'token-2', 'token-3'],
        notification: {
          title: 'Multicast Test',
          body: 'Sent to multiple devices',
        },
        data: { type: 'multicast' },
      };
      const mockResponse = {
        successCount: 3,
        failureCount: 0,
        responses: [
          { success: true, messageId: 'msg-1' },
          { success: true, messageId: 'msg-2' },
          { success: true, messageId: 'msg-3' },
        ],
      };
      mockMessaging.sendEachForMulticast.mockResolvedValue(mockResponse as any);

      // Act
      const result = await service.sendMulticast(payload);

      // Assert
      expect(result.successCount).toBe(3);
      expect(result.failureCount).toBe(0);
      expect(mockMessaging.sendEachForMulticast).toHaveBeenCalledTimes(1);
    });

    it('should handle partial failures', async () => {
      // Arrange
      const payload = {
        tokens: ['valid-token', 'invalid-token'],
        notification: {
          title: 'Test',
          body: 'Test',
        },
      };
      const mockResponse = {
        successCount: 1,
        failureCount: 1,
        responses: [
          { success: true, messageId: 'msg-1' },
          { success: false, error: new Error('Invalid token') as any },
        ],
      };
      mockMessaging.sendEachForMulticast.mockResolvedValue(mockResponse as any);

      // Act
      const result = await service.sendMulticast(payload);

      // Assert
      expect(result.successCount).toBe(1);
      expect(result.failureCount).toBe(1);
    });
  });

  describe('sendToTopic', () => {
    it('should send notification to a topic', async () => {
      // Arrange
      const payload = {
        topic: 'house-123',
        notification: {
          title: 'House Update',
          body: 'New member joined',
        },
        data: { houseId: '123' },
      };
      mockMessaging.send.mockResolvedValue('topic-message-id');

      // Act
      const result = await service.sendToTopic(payload);

      // Assert
      expect(result).toBe('topic-message-id');
      expect(mockMessaging.send).toHaveBeenCalledWith(
        expect.objectContaining({
          topic: payload.topic,
          notification: expect.objectContaining({
            title: payload.notification.title,
            body: payload.notification.body,
          }),
        }),
      );
    });
  });

  describe('subscribeToTopic', () => {
    it('should subscribe device to topic', async () => {
      // Arrange
      const token = 'device-token';
      const topic = 'house-456';
      mockMessaging.subscribeToTopic.mockResolvedValue({} as any);

      // Act
      await service.subscribeToTopic(token, topic);

      // Assert
      expect(mockMessaging.subscribeToTopic).toHaveBeenCalledWith([token], topic);
    });

    it('should handle subscription errors', async () => {
      // Arrange
      const token = 'invalid-token';
      const topic = 'house-456';
      mockMessaging.subscribeToTopic.mockRejectedValue(new Error('Subscription failed'));

      // Act & Assert
      await expect(service.subscribeToTopic(token, topic)).rejects.toThrow(
        'Subscription failed',
      );
    });
  });

  describe('unsubscribeFromTopic', () => {
    it('should unsubscribe device from topic', async () => {
      // Arrange
      const token = 'device-token';
      const topic = 'house-456';
      mockMessaging.unsubscribeFromTopic.mockResolvedValue({} as any);

      // Act
      await service.unsubscribeFromTopic(token, topic);

      // Assert
      expect(mockMessaging.unsubscribeFromTopic).toHaveBeenCalledWith([token], topic);
    });
  });
});
