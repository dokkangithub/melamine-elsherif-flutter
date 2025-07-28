import 'package:flutter/material.dart';
import 'models/notification_models.dart';

/// Router service for handling notification navigation
/// Follows Single Responsibility Principle
class NotificationRouter {
  final GlobalKey<NavigatorState> navigatorKey;

  NotificationRouter({required this.navigatorKey});

  /// Handle notification action based on payload
  Future<void> handleNotificationAction(NotificationPayload payload) async {
    final action = NotificationAction.fromData(payload.data);

    switch (action.type) {
      case NotificationActionType.openScreen:
        await _navigateToScreen(action.route!, action.arguments);
        break;
      case NotificationActionType.openUrl:
        await _openUrl(action.url!);
        break;
      case NotificationActionType.custom:
        await _handleCustomAction(action.customAction!, payload.data);
        break;
      case NotificationActionType.openApp:
      // App is already opened, do nothing or navigate to home
        break;
    }
  }

  /// Navigate to specific screen
  Future<void> _navigateToScreen(String route, Map<String, dynamic>? arguments) async {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushNamed(route, arguments: arguments);
    }
  }

  /// Open URL (implement based on your URL handling strategy)
  Future<void> _openUrl(String url) async {
    // Implement URL opening logic here
    // You might want to use url_launcher package
    debugPrint("Opening URL: $url");
  }

  /// Handle custom actions
  Future<void> _handleCustomAction(String customAction, Map<String, dynamic> data) async {
    // Implement custom action handling based on your app's needs
    debugPrint("Handling custom action: $customAction with data: $data");
  }
}