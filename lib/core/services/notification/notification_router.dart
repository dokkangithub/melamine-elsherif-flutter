import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/notification_models.dart';
import '../../../features/domain/category/entities/category.dart';
import '../../utils/enums/products_type.dart';

class NotificationRouter {
  final GlobalKey<NavigatorState> navigatorKey;

  NotificationRouter({required this.navigatorKey});

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
      // Navigate to home if needed
        await _navigateToScreen('/mainLayout', null);
        break;
    }
  }

  Future<void> _navigateToScreen(String route, Map<String, dynamic>? arguments) async {
    // Wait for navigation to be ready
    await Future.delayed(const Duration(milliseconds: 100));

    final context = navigatorKey.currentContext;
    if (context != null) {
      // Handle special routes that need specific argument structure
      final processedArguments = _processArguments(route, arguments);

      Navigator.of(context).pushNamed(route, arguments: processedArguments);
    } else {
      // If context is not ready, retry after a delay
      await Future.delayed(const Duration(milliseconds: 500));
      final retryContext = navigatorKey.currentContext;
      if (retryContext != null) {
        final processedArguments = _processArguments(route, arguments);
        Navigator.of(retryContext).pushNamed(route, arguments: processedArguments);
      }
    }
  }

  Map<String, dynamic>? _processArguments(String route, Map<String, dynamic>? arguments) {
    if (arguments == null) return null;

    // Process arguments based on route requirements
    switch (route) {
      case '/product-details':
        return {'slug': arguments['slug'] ?? arguments['product_slug'] ?? ''};
      case '/order-details':
        return {'orderId': int.tryParse(arguments['orderId']?.toString() ?? '') ?? 0};
      case '/all-category-product':
      // You might need to fetch the category object based on ID
        return arguments;
      case '/verification':
        return {'contactInfo': arguments['contactInfo'] ?? ''};
      default:
        return arguments;
    }
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch URL: $url");
    }
  }

  Future<void> _handleCustomAction(String customAction, Map<String, dynamic> data) async {
    debugPrint("Handling custom action: $customAction with data: $data");

    // Implement custom actions based on your needs
    switch (customAction) {
      case 'open_order':
        final orderId = data['order_id'];
        if (orderId != null) {
          await _navigateToScreen('/order-details', {'orderId': orderId});
        }
        break;
      case 'open_product':
        final productSlug = data['product_slug'];
        if (productSlug != null) {
          await _navigateToScreen('/product-details', {'slug': productSlug});
        }
        break;
    // Add more custom actions as needed
    }
  }
}