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
    debugPrint("=== CREATING NOTIFICATION PAYLOAD ===");
    debugPrint("Message ID: ${message.messageId}");
    debugPrint("Title: ${message.notification?.title}");
    debugPrint("Body: ${message.notification?.body}");
    debugPrint("Raw data: ${message.data}");

    return NotificationPayload(
      title: message.notification?.title ?? message.data['title'] ?? '',
      body: message.notification?.body ?? message.data['body'] ?? '',
      data: message.data,
      imageUrl:
      message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl ??
          message.data['image_url'],
      channelId: message.notification?.android?.channelId ??
          message.data['channel_id'],
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
    debugPrint('=== NOTIFICATION ACTION PARSING ===');
    debugPrint('Raw notification data: $data');
    debugPrint('Data keys: ${data.keys.toList()}');

    // Clean and normalize the data
    final cleanData = _cleanNotificationData(data);
    debugPrint('Cleaned data: $cleanData');

    final String? actionType = cleanData['action_type'] ??
        cleanData['actionType'] ??
        cleanData['type'];
    debugPrint('Extracted action type: $actionType');

    switch (actionType?.toLowerCase()) {
      case 'open_screen':
      case 'openscreen':
      case 'screen':
        return _parseOpenScreenAction(cleanData);

      case 'open_url':
      case 'openurl':
      case 'url':
        return _parseOpenUrlAction(cleanData);

      case 'custom':
        return _parseCustomAction(cleanData);

      default:
        debugPrint('No specific action type found, defaulting to openApp');
        return const NotificationAction(type: NotificationActionType.openApp);
    }
  }

  /// Clean and normalize notification data
  static Map<String, dynamic> _cleanNotificationData(Map<String, dynamic> data) {
    final cleanData = <String, dynamic>{};

    for (final entry in data.entries) {
      var key = entry.key.toLowerCase().trim();
      var value = entry.value;

      // Handle nested JSON strings
      if (value is String) {
        try {
          // Try to parse as JSON if it looks like JSON
          if (value.trim().startsWith('{') && value.trim().endsWith('}')) {
            value = jsonDecode(value) as Map<String, dynamic>;
          }
        } catch (e) {
          // If parsing fails, keep as string
          debugPrint('Failed to parse JSON string for key $key: $e');
        }
      }

      cleanData[key] = value;
    }

    return cleanData;
  }

  static NotificationAction _parseOpenScreenAction(Map<String, dynamic> data) {
    debugPrint('=== PARSING OPEN SCREEN ACTION ===');
    debugPrint('Data for screen action: $data');

    // Extract route with multiple possible key names
    final route = data['route'] ??
        data['screen'] ??
        data['page'] ??
        data['destination'];
    debugPrint('Extracted route: $route');

    if (route == null || route.toString().isEmpty) {
      debugPrint('No valid route found, defaulting to openApp');
      return const NotificationAction(type: NotificationActionType.openApp);
    }

    // Extract arguments
    Map<String, dynamic>? arguments = _extractArguments(data);
    debugPrint('Final extracted arguments: $arguments');

    return NotificationAction(
      type: NotificationActionType.openScreen,
      route: route.toString(),
      arguments: arguments,
    );
  }

  static NotificationAction _parseOpenUrlAction(Map<String, dynamic> data) {
    debugPrint('=== PARSING OPEN URL ACTION ===');
    debugPrint('Data for URL action: $data');

    final url = data['url'] ??
        data['link'] ??
        data['web_url'] ??
        data['external_url'];
    debugPrint('Extracted URL: $url');

    if (url == null || url.toString().isEmpty) {
      debugPrint('No valid URL found, defaulting to openApp');
      return const NotificationAction(type: NotificationActionType.openApp);
    }

    return NotificationAction(
      type: NotificationActionType.openUrl,
      url: url.toString(),
    );
  }

  static NotificationAction _parseCustomAction(Map<String, dynamic> data) {
    debugPrint('=== PARSING CUSTOM ACTION ===');
    debugPrint('Data for custom action: $data');

    final customAction = data['custom_action'] ??
        data['customaction'] ??
        data['action'] ??
        data['custom'];
    debugPrint('Extracted custom action: $customAction');

    if (customAction == null || customAction.toString().isEmpty) {
      debugPrint('No valid custom action found, defaulting to openApp');
      return const NotificationAction(type: NotificationActionType.openApp);
    }

    return NotificationAction(
      type: NotificationActionType.custom,
      customAction: customAction.toString(),
    );
  }

  /// Extract arguments from notification data
  static Map<String, dynamic>? _extractArguments(Map<String, dynamic> data) {
    debugPrint('=== EXTRACTING ARGUMENTS ===');
    debugPrint('Raw data for argument extraction: $data');

    Map<String, dynamic>? arguments;

    // First, try to get arguments from specific 'arguments' field
    final argumentsField = data['arguments'] ?? data['args'] ?? data['params'];

    if (argumentsField != null) {
      debugPrint('Found arguments field: $argumentsField (${argumentsField.runtimeType})');

      if (argumentsField is String) {
        // If it's a JSON string, parse it
        try {
          arguments = jsonDecode(argumentsField) as Map<String, dynamic>;
          debugPrint('Parsed JSON arguments: $arguments');
        } catch (e) {
          debugPrint('Error parsing JSON arguments: $e');
        }
      } else if (argumentsField is Map<String, dynamic>) {
        // If it's already a Map, use it directly
        arguments = argumentsField;
        debugPrint('Direct map arguments: $arguments');
      }
    }

    // If no specific arguments field or parsing failed, extract relevant data
    if (arguments == null || arguments.isEmpty) {
      arguments = <String, dynamic>{};

      // List of keys to exclude when extracting arguments
      final excludeKeys = {
        'action_type', 'actiontype', 'type',
        'route', 'screen', 'page', 'destination',
        'url', 'link', 'web_url', 'external_url',
        'custom_action', 'customaction', 'action', 'custom',
        'arguments', 'args', 'params',
        'title', 'body', 'message',
        'channel_id', 'channelid',
        'image_url', 'imageurl', 'image'
      };

      // Extract all relevant data as arguments
      for (final entry in data.entries) {
        final key = entry.key.toLowerCase();
        if (!excludeKeys.contains(key) && entry.value != null) {
          // Use original key case for the argument
          arguments[entry.key] = entry.value;
        }
      }

      debugPrint('Extracted arguments from data: $arguments');
    }

    // Handle common argument patterns
    arguments = _normalizeCommonArguments(arguments);

    return arguments.isNotEmpty ? arguments : null;
  }

  /// Normalize common argument patterns
  static Map<String, dynamic> _normalizeCommonArguments(Map<String, dynamic> arguments) {
    debugPrint('=== NORMALIZING ARGUMENTS ===');
    debugPrint('Arguments before normalization: $arguments');

    final normalized = Map<String, dynamic>.from(arguments);

    // Normalize slug arguments (for product details)
    if (!normalized.containsKey('slug')) {
      final slug = normalized['product_slug'] ??
          normalized['productSlug'] ??
          normalized['productslug'] ??
          normalized['id'] ??
          normalized['product_id'] ??
          normalized['productId'] ??
          normalized['productid'];

      if (slug != null) {
        normalized['slug'] = slug.toString();
        debugPrint('Normalized slug: ${normalized['slug']}');
      }
    }

    // Normalize order ID arguments
    if (!normalized.containsKey('orderId')) {
      final orderId = normalized['order_id'] ??
          normalized['orderid'] ??
          normalized['orderID'] ??
          normalized['id'];

      if (orderId != null) {
        // Try to parse as integer
        final parsedOrderId = int.tryParse(orderId.toString());
        if (parsedOrderId != null) {
          normalized['orderId'] = parsedOrderId;
          debugPrint('Normalized orderId: ${normalized['orderId']}');
        }
      }
    }

    // Normalize contact info arguments
    if (!normalized.containsKey('contactInfo')) {
      final contactInfo = normalized['contact_info'] ??
          normalized['contactinfo'] ??
          normalized['email'] ??
          normalized['phone'] ??
          normalized['mobile'];

      if (contactInfo != null) {
        normalized['contactInfo'] = contactInfo.toString();
        debugPrint('Normalized contactInfo: ${normalized['contactInfo']}');
      }
    }

    // Normalize product type arguments
    if (!normalized.containsKey('productType')) {
      final productType = normalized['product_type'] ??
          normalized['producttype'] ??
          normalized['type'];

      if (productType != null) {
        normalized['productType'] = productType.toString();
        debugPrint('Normalized productType: ${normalized['productType']}');
      }
    }

    // Normalize title arguments
    if (!normalized.containsKey('title')) {
      final title = normalized['page_title'] ??
          normalized['screen_title'] ??
          normalized['name'];

      if (title != null) {
        normalized['title'] = title.toString();
        debugPrint('Normalized title: ${normalized['title']}');
      }
    }

    // Normalize deal ID arguments
    if (!normalized.containsKey('dealId')) {
      final dealId = normalized['deal_id'] ??
          normalized['dealid'] ??
          normalized['deal'];

      if (dealId != null) {
        final parsedDealId = int.tryParse(dealId.toString());
        if (parsedDealId != null) {
          normalized['dealId'] = parsedDealId;
          debugPrint('Normalized dealId: ${normalized['dealId']}');
        }
      }
    }

    debugPrint('Arguments after normalization: $normalized');
    return normalized;
  }
}