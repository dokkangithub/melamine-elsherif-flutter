import 'package:firebase_messaging/firebase_messaging.dart';

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
      imageUrl: message.notification?.android?.imageUrl ??
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
enum NotificationActionType {
  openApp,
  openScreen,
  openUrl,
  custom,
}

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
    final String? actionType = data['action_type'];

    switch (actionType) {
      case 'open_screen':
        return NotificationAction(
          type: NotificationActionType.openScreen,
          route: data['route'],
          arguments: data['arguments'],
        );
      case 'open_url':
        return NotificationAction(
          type: NotificationActionType.openUrl,
          url: data['url'],
        );
      case 'custom':
        return NotificationAction(
          type: NotificationActionType.custom,
          customAction: data['custom_action'],
        );
      default:
        return const NotificationAction(type: NotificationActionType.openApp);
    }
  }
}