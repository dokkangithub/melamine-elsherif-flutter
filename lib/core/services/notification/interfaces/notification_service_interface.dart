import 'dart:async';
import '../models/notification_models.dart';

/// Abstract interface for notification service following Interface Segregation Principle
abstract class INotificationService {
  /// Initialize the notification service
  Future<void> initialize();

  /// Get FCM token
  Future<String?> getToken();

  /// Listen to token refresh
  Stream<String> get onTokenRefresh;

  /// Listen to foreground messages
  Stream<NotificationPayload> get onForegroundMessage;

  /// Listen to message taps (when app is opened from notification)
  Stream<NotificationPayload> get onMessageTap;

  /// Request notification permissions
  Future<bool> requestPermissions();

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic);

  /// Show local notification
  Future<void> showLocalNotification(NotificationPayload payload);

  /// Clear all notifications
  Future<void> clearAllNotifications();

  /// Dispose resources
  void dispose();
}