import 'dart:async';
import 'package:flutter/material.dart';
import 'interfaces/notification_service_interface.dart';
import 'notification_service.dart';
import 'notification_router.dart';
import 'models/notification_models.dart';

/// High-level notification manager that coordinates all notification functionality
/// Follows Facade pattern and Dependency Inversion Principle
class NotificationManager {
  final INotificationService _notificationService;
  final NotificationRouter _router;

  late StreamSubscription<NotificationPayload> _messageTapSubscription;

  NotificationManager({
    INotificationService? notificationService,
    required NotificationRouter router,
  }) : _notificationService = notificationService ?? NotificationService(),
        _router = router;

  /// Initialize the notification manager
  Future<void> initialize() async {
    await _notificationService.initialize();

    // Listen to message taps and handle routing
    _messageTapSubscription = _notificationService.onMessageTap.listen(
          (payload) => _router.handleNotificationAction(payload),
    );
  }

  /// Get FCM token
  Future<String?> getToken() => _notificationService.getToken();

  /// Listen to token refresh
  Stream<String> get onTokenRefresh => _notificationService.onTokenRefresh;

  /// Listen to foreground messages
  Stream<NotificationPayload> get onForegroundMessage =>
      _notificationService.onForegroundMessage;

  /// Request notification permissions
  Future<bool> requestPermissions() => _notificationService.requestPermissions();

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) =>
      _notificationService.subscribeToTopic(topic);

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) =>
      _notificationService.unsubscribeFromTopic(topic);

  /// Clear all notifications
  Future<void> clearAllNotifications() =>
      _notificationService.clearAllNotifications();

  /// Dispose resources
  void dispose() {
    _messageTapSubscription.cancel();
    _notificationService.dispose();
  }
}