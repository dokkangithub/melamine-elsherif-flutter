import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/notification_models.dart';
import '../../../features/domain/category/entities/category.dart';
import '../../utils/enums/products_type.dart';

class NotificationRouter {
  final GlobalKey<NavigatorState> navigatorKey;

  NotificationRouter({required this.navigatorKey});

  Future<void> handleNotificationAction(NotificationPayload payload) async {
    debugPrint('=== NOTIFICATION ROUTER HANDLING ===');
    debugPrint('Payload data: ${payload.data}');

    final action = NotificationAction.fromData(payload.data);
    debugPrint('Action type: ${action.type}');
    debugPrint('Action route: ${action.route}');
    debugPrint('Action arguments: ${action.arguments}');

    switch (action.type) {
      case NotificationActionType.openScreen:
        if (action.route != null) {
          await _navigateToScreen(action.route!, action.arguments);
        } else {
          debugPrint('Route is null, opening main app');
          await _navigateToScreen('/mainLayout', null);
        }
        break;
      case NotificationActionType.openUrl:
        if (action.url != null) {
          await _openUrl(action.url!);
        } else {
          debugPrint('URL is null, opening main app');
          await _navigateToScreen('/mainLayout', null);
        }
        break;
      case NotificationActionType.custom:
        if (action.customAction != null) {
          await _handleCustomAction(action.customAction!, payload.data);
        } else {
          debugPrint('Custom action is null, opening main app');
          await _navigateToScreen('/mainLayout', null);
        }
        break;
      case NotificationActionType.openApp:
        await _navigateToScreen('/mainLayout', null);
        break;
    }
  }

  Future<void> _navigateToScreen(String route, Map<String, dynamic>? arguments) async {
    debugPrint('=== NAVIGATING TO SCREEN ===');
    debugPrint('Route: $route');
    debugPrint('Arguments: $arguments');

    // Wait for navigation to be ready
    await Future.delayed(const Duration(milliseconds: 100));

    final context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint('Context is null, retrying...');
      // If context is not ready, retry after a delay
      await Future.delayed(const Duration(milliseconds: 500));
      final retryContext = navigatorKey.currentContext;
      if (retryContext == null) {
        debugPrint('Context still null after retry, aborting navigation');
        return;
      }
    }

    final finalContext = navigatorKey.currentContext!;

    // Process arguments and validate them
    final processedArguments = _processArguments(route, arguments);

    // Validate the route and arguments before navigation
    if (_validateRouteAndArguments(route, processedArguments)) {
      try {
        debugPrint('Navigating to: $route with arguments: $processedArguments');
        Navigator.of(finalContext).pushNamed(route, arguments: processedArguments);
      } catch (e) {
        debugPrint('Error navigating to $route: $e');
        // Fallback to main layout
        Navigator.of(finalContext).pushNamed('/mainLayout');
      }
    } else {
      debugPrint('Route validation failed, opening main app');
      Navigator.of(finalContext).pushNamed('/mainLayout');
    }
  }

  bool _validateRouteAndArguments(String route, Map<String, dynamic>? arguments) {
    debugPrint('=== VALIDATING ROUTE AND ARGUMENTS ===');
    debugPrint('Route: $route');
    debugPrint('Arguments: $arguments');

    switch (route) {
      case '/product-details':
      case '/set-product-details':
        final slug = arguments?['slug'];
        final isValid = slug != null && slug.toString().isNotEmpty;
        debugPrint('Slug validation: $isValid (slug: $slug)');
        return isValid;

      case '/order-details':
        final orderId = arguments?['orderId'];
        final isValid = orderId != null && (orderId is int || int.tryParse(orderId.toString()) != null);
        debugPrint('OrderId validation: $isValid (orderId: $orderId)');
        return isValid;

      case '/all-category-product':
        final category = arguments?['category'];
        final isValid = category != null;
        debugPrint('Category validation: $isValid');
        return isValid;

      case '/verification':
        final contactInfo = arguments?['contactInfo'];
        final isValid = contactInfo != null && contactInfo.toString().isNotEmpty;
        debugPrint('ContactInfo validation: $isValid');
        return isValid;

      case '/allProductsByType':
        final productType = arguments?['productType'];
        final title = arguments?['title'];
        final isValid = productType != null && title != null;
        debugPrint('ProductsByType validation: $isValid');
        return isValid;

    // Routes that don't require arguments
      case '/mainLayout':
      case '/home':
      case '/category':
      case '/wishList':
      case '/profile':
      case '/cart':
      case '/search-screen':
      case '/wallet-screen':
      case '/setProductsScreen':
      case '/addressListScreen':
      case '/checkout':
      case '/all-orders-list':
        debugPrint('Route requires no arguments, validation passed');
        return true;

      default:
        debugPrint('Unknown route, validation failed');
        return false;
    }
  }

  Map<String, dynamic>? _processArguments(String route, Map<String, dynamic>? arguments) {
    debugPrint('=== PROCESSING ARGUMENTS ===');
    debugPrint('Route: $route');
    debugPrint('Raw arguments: $arguments');

    if (arguments == null || arguments.isEmpty) {
      debugPrint('Arguments are null or empty');
      return null;
    }

    debugPrint('Available argument keys: ${arguments.keys.toList()}');

    // Process arguments based on route requirements
    switch (route) {
      case '/product-details':
      case '/set-product-details':
      // Handle multiple possible slug key names
        final slug = arguments['slug'] ??
            arguments['product_slug'] ??
            arguments['productSlug'] ??
            arguments['id'] ??
            arguments['product_id'];

        debugPrint('Extracted slug: $slug');

        if (slug == null || slug.toString().isEmpty) {
          debugPrint('No valid slug found in arguments');
          return null;
        }

        final processedArgs = {'slug': slug.toString()};
        debugPrint('Processed arguments: $processedArgs');
        return processedArgs;

      case '/order-details':
      // Handle multiple possible order ID key names
        final orderId = arguments['orderId'] ??
            arguments['order_id'] ??
            arguments['orderID'] ??
            arguments['id'];

        debugPrint('Raw orderId: $orderId');

        if (orderId == null) {
          debugPrint('No order ID found in arguments');
          return null;
        }

        // Try to parse as integer
        final parsedOrderId = int.tryParse(orderId.toString());
        if (parsedOrderId == null) {
          debugPrint('Could not parse orderId as integer: $orderId');
          return null;
        }

        debugPrint('Parsed orderId: $parsedOrderId');
        return {'orderId': parsedOrderId};

      case '/all-category-product':
      // For category products, we need a Category object
      // This is complex as it requires creating a Category entity
      // For now, return arguments as-is and let the validation handle it
        debugPrint('Category product arguments: $arguments');
        return arguments;

      case '/verification':
        final contactInfo = arguments['contactInfo'] ??
            arguments['contact_info'] ??
            arguments['email'] ??
            arguments['phone'];

        debugPrint('Extracted contactInfo: $contactInfo');

        if (contactInfo == null || contactInfo.toString().isEmpty) {
          debugPrint('No contact info found in arguments');
          return null;
        }

        return {'contactInfo': contactInfo.toString()};

      case '/allProductsByType':
        final productTypeStr = arguments['productType'] ?? arguments['product_type'];
        final title = arguments['title'];
        final dealId = arguments['dealId'] ?? arguments['deal_id'];

        debugPrint('ProductType string: $productTypeStr');
        debugPrint('Title: $title');
        debugPrint('DealId: $dealId');

        if (productTypeStr == null || title == null) {
          debugPrint('Missing required arguments for allProductsByType');
          return null;
        }

        // Convert string to ProductType enum (you'll need to implement this conversion)
        // For now, return the arguments as-is
        return {
          'productType': productTypeStr,
          'title': title.toString(),
          'dealId': dealId != null ? int.tryParse(dealId.toString()) : null,
        };

      default:
        debugPrint('Using default arguments processing');
        return arguments;
    }
  }

  Future<void> _openUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Could not launch URL: $url");
        // Fallback to main app
        await _navigateToScreen('/mainLayout', null);
      }
    } catch (e) {
      debugPrint("Error opening URL $url: $e");
      await _navigateToScreen('/mainLayout', null);
    }
  }

  Future<void> _handleCustomAction(String customAction, Map<String, dynamic> data) async {
    debugPrint("=== HANDLING CUSTOM ACTION ===");
    debugPrint("Custom action: $customAction");
    debugPrint("Data: $data");

    try {
      // Implement custom actions based on your needs
      switch (customAction) {
        case 'open_order':
          final orderId = data['order_id'] ?? data['orderId'];
          if (orderId != null) {
            await _navigateToScreen('/order-details', {'orderId': orderId});
          } else {
            debugPrint('No order ID found for open_order action');
            await _navigateToScreen('/mainLayout', null);
          }
          break;

        case 'open_product':
          final productSlug = data['product_slug'] ?? data['slug'] ?? data['productSlug'];
          if (productSlug != null) {
            await _navigateToScreen('/product-details', {'slug': productSlug});
          } else {
            debugPrint('No product slug found for open_product action');
            await _navigateToScreen('/mainLayout', null);
          }
          break;

        case 'open_set_product':
          final setProductSlug = data['product_slug'] ?? data['slug'] ?? data['setProductSlug'];
          if (setProductSlug != null) {
            await _navigateToScreen('/set-product-details', {'slug': setProductSlug});
          } else {
            debugPrint('No set product slug found for open_set_product action');
            await _navigateToScreen('/mainLayout', null);
          }
          break;

        case 'open_category':
        // This would need a Category object, for now just open categories screen
          await _navigateToScreen('/category', null);
          break;

        case 'open_orders':
          await _navigateToScreen('/all-orders-list', null);
          break;

        case 'open_cart':
          await _navigateToScreen('/cart', null);
          break;

        case 'open_wishlist':
          await _navigateToScreen('/wishList', null);
          break;

        case 'open_profile':
          await _navigateToScreen('/profile', null);
          break;

        case 'open_wallet':
          await _navigateToScreen('/wallet-screen', null);
          break;

        case 'open_search':
          await _navigateToScreen('/search-screen', null);
          break;

        default:
          debugPrint('Unknown custom action: $customAction');
          await _navigateToScreen('/mainLayout', null);
          break;
      }
    } catch (e) {
      debugPrint('Error handling custom action $customAction: $e');
      await _navigateToScreen('/mainLayout', null);
    }
  }
}