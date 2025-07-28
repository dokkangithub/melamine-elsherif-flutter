import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class NotificationPayload {
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String? imageUrl;
  final String? channelId;

  const NotificationPayload({
    required this.title,
    required this.body,
    required this.data,
    this.imageUrl,
    this.channelId,
  });

  factory NotificationPayload.fromRemoteMessage(RemoteMessage message) {
    return NotificationPayload(
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      data: message.data,
      imageUrl:
          message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl,
      channelId: message.notification?.android?.channelId,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'data': data,
    'imageUrl': imageUrl,
    'channelId': channelId,
  };

  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    return NotificationPayload(
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      imageUrl: json['imageUrl'],
      channelId: json['channelId'],
    );
  }
}

/// Enum for notification action types
enum NotificationActionType { openApp, openScreen, openUrl, custom }

/// Data model for notification action
class NotificationAction {
  final NotificationActionType type;
  final String? route;
  final Map<String, dynamic>? arguments;
  final String? url;
  final String? customAction;

  const NotificationAction({
    required this.type,
    this.route,
    this.arguments,
    this.url,
    this.customAction,
  });

  factory NotificationAction.fromData(Map<String, dynamic> data) {
    debugPrint('=== NOTIFICATION ACTION DEBUG ===');
    debugPrint('Raw notification data: $data');

    final String? actionType = data['action_type'];
    debugPrint('Action type: $actionType');

    switch (actionType) {
      case 'open_screen':
        final route = data['route'];
        debugPrint('Route: $route');

        Map<String, dynamic>? arguments;

        // Handle arguments field - it might be a JSON string or a Map
        final argumentsField = data['arguments'];
        debugPrint('Arguments field type: ${argumentsField.runtimeType}');
        debugPrint('Arguments field value: $argumentsField');

        if (argumentsField != null) {
          if (argumentsField is String) {
            // If it's a JSON string, parse it
            try {
              arguments = jsonDecode(argumentsField) as Map<String, dynamic>;
              debugPrint('Parsed JSON arguments: $arguments');
            } catch (e) {
              debugPrint('Error parsing JSON arguments: $e');
              arguments = null;
            }
          } else if (argumentsField is Map<String, dynamic>) {
            // If it's already a Map, use it directly
            arguments = argumentsField;
            debugPrint('Direct map arguments: $arguments');
          }
        }

        // If no 'arguments' key or parsing failed, extract all data except action_type and route
        if (arguments == null || arguments.isEmpty) {
          arguments = Map<String, dynamic>.from(data);
          arguments.remove('action_type');
          arguments.remove('route');
          arguments.remove('arguments'); // Remove the arguments field itself
          debugPrint('Fallback extracted arguments: $arguments');
        }

        return NotificationAction(
          type: NotificationActionType.openScreen,
          route: route,
          arguments: arguments.isNotEmpty ? arguments : null,
        );

      case 'open_url':
        final url = data['url'];
        debugPrint('URL: $url');
        return NotificationAction(
          type: NotificationActionType.openUrl,
          url: url,
        );

      case 'custom':
        final customAction = data['custom_action'];
        debugPrint('Custom action: $customAction');
        return NotificationAction(
          type: NotificationActionType.custom,
          customAction: customAction,
        );

      default:
        debugPrint('Default action - open app');
        return const NotificationAction(type: NotificationActionType.openApp);
    }
  }

}

