import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/enums/products_type.dart';
import 'package:melamine_elsherif/features/presentation/category/screens/category_screen.dart';
import 'package:melamine_elsherif/features/presentation/profile/screens/edit_profile_screen.dart';
import 'package:melamine_elsherif/features/presentation/profile/screens/profile_screen.dart';
import 'package:melamine_elsherif/features/presentation/wishlist/screens/wishlist_screen.dart';
import '../../../core/services/notification/models/notification_models.dart';
import '../../../features/domain/category/entities/category.dart';
import '../../../features/presentation/address/screens/address_list_screen.dart';
import '../../../features/presentation/all products/screens/all_category_products.dart';
import '../../../features/presentation/all products/screens/all_products_by_type_screen.dart';
import '../../../features/presentation/auth/screens/forgot_password_screen.dart';
import '../../../features/presentation/auth/screens/login_screen.dart';
import '../../../features/presentation/auth/screens/reset_password_screen.dart';
import '../../../features/presentation/auth/screens/signup_screen.dart';
import '../../../features/presentation/auth/screens/verification_screen.dart';
import '../../../features/presentation/cart/screens/cart_screen.dart';
import '../../../features/presentation/home/screens/home.dart';
import '../../../features/presentation/main layout/screens/main_layout_screen.dart';
import '../../../features/presentation/onboarding/screens/onboarding_screen.dart';
import '../../../features/presentation/order/screens/order_screen.dart';
import '../../../features/presentation/order/screens/orders_list_screen.dart';
import '../../../features/presentation/checkout/screens/checkout_screen.dart';
import '../../../features/presentation/product details/screens/product_screen.dart';
import '../../../features/presentation/set products/screens/set_product_details_screen.dart';
import '../../../features/presentation/set products/screens/set_products_screen.dart';
import '../../../features/presentation/splash/splash_screen.dart';
import '../../../features/presentation/search/screens/search_screen.dart';
import '../../../features/presentation/wallet/screens/wallet_screen.dart';
import 'package:page_transition/page_transition.dart';

class AppRoutes {

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String forgetPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String verificationScreen = '/verification';
  static const String homeScreen = '/home';
  static const String categoryScreen = '/category';
  static const String wishListScreen = '/wishList';
  static const String profileScreen = '/profile';
  static const String editProfileScreen = '/editProfileScreen';
  static const String mainLayoutScreen = '/mainLayout';
  static const String cartScreen = '/cart';
  static const String productDetailScreen = '/product-details';
  static const String allCategoryProductsScreen = '/all-category-product';
  static const String allProductsByTypeScreen = '/allProductsByType';
  static const String setProductsScreen = '/setProductsScreen';
  static const String addressListScreen = '/addressListScreen';
  static const String checkoutScreen = '/checkout';
  static const String newCheckoutScreen = '/new-checkout';
  static const String successScreen = '/success';
  static const String allOrdersListScreen = '/all-orders-list';
  static const String orderDetailsScreen = '/order-details';
  static const String searchScreen = '/search-screen';
  static const String walletScreen = '/wallet-screen';
  static const String setProductDetailsScreen = '/set-product-details';


  static const PageTransitionType defaultTransition = PageTransitionType.sharedAxisHorizontal;

  static Route<dynamic> generateRoute(
      RouteSettings settings, {
        PageTransitionType? transitionType,
        NotificationAction? pendingNotificationAction,
      }) {
    Widget page;

    final transition = transitionType ?? defaultTransition;

    // Check if we have a pending notification action for this route
    Map<String, dynamic>? routeArguments = settings.arguments as Map<String, dynamic>?;

    if (pendingNotificationAction != null &&
        pendingNotificationAction.type == NotificationActionType.openScreen &&
        pendingNotificationAction.route == settings.name) {
      debugPrint('=== USING NOTIFICATION ARGUMENTS ===');
      debugPrint('Route: ${settings.name}');
      debugPrint('Notification arguments: ${pendingNotificationAction.arguments}');

      // Use notification arguments instead of route arguments
      routeArguments = pendingNotificationAction.arguments;
    }

    switch (settings.name) {
      case splash:
        page = const SplashScreen();
        break;
      case onboarding:
        page = const OnboardingScreen();
        break;
      case login:
        page = const LoginScreen();
        break;
      case signUp:
        page = const SignUpScreen();
        break;
      case forgetPassword:
        page = const ForgotPasswordScreen();
        break;
      case resetPassword:
        page = const ResetPasswordScreen();
        break;
      case verificationScreen:
        page = VerificationScreen(
          contactInfo: routeArguments?['contactInfo'] as String? ?? '',
        );
        break;
      case homeScreen:
        page = const HomeScreen();
        break;
      case categoryScreen:
        page = const CategoryScreen();
        break;
      case wishListScreen:
        page = const WishlistScreen();
        break;
      case profileScreen:
        page = const ProfileScreen();
        break;
      case editProfileScreen:
        page = const EditProfileScreen();
        break;
      case mainLayoutScreen:
        page = const MainLayoutScreen();
        break;
      case cartScreen:
        page = const CartScreen();
        break;
      case productDetailScreen:
      // Debug: Print what we're receiving
        debugPrint('=== PRODUCT DETAIL ROUTE DEBUG ===');
        debugPrint('Arguments received: $routeArguments');
        debugPrint('Arguments type: ${routeArguments.runtimeType}');

        if (routeArguments != null) {
          debugPrint('Available keys: ${routeArguments.keys.toList()}');
          debugPrint('slug value: ${routeArguments['slug']}');
          debugPrint('product_slug value: ${routeArguments['product_slug']}');
        }

        final slug = routeArguments?['slug'] as String?;

        debugPrint('Final slug value: $slug');
        debugPrint('From notification: ${pendingNotificationAction != null}');
        debugPrint('================================');

        if (slug == null || slug.isEmpty) {
          debugPrint('⚠️ Invalid product slug, redirecting to main layout');
          // Instead of showing error screen, redirect to main layout
          page = const MainLayoutScreen();
        } else {
          debugPrint('✅ Valid slug found, creating ProductDetailScreen');
          page = ProductDetailScreen(slug: slug);
        }
        break;
      case setProductDetailsScreen:
        final setSlug = routeArguments?['slug'] as String?;

        debugPrint('=== SET PRODUCT DETAIL ROUTE DEBUG ===');
        debugPrint('Slug: $setSlug');
        debugPrint('From notification: ${pendingNotificationAction != null}');

        if (setSlug == null || setSlug.isEmpty) {
          debugPrint('⚠️ Invalid set product slug, redirecting to main layout');
          page = const MainLayoutScreen();
        } else {
          debugPrint('✅ Valid set slug found, creating SetProductDetailsScreen');
          page = SetProductDetailsScreen(slug: setSlug);
        }
        break;
      case allCategoryProductsScreen:
        page = AllCategoryProductsScreen(
          category: routeArguments?['category'] as Category,
        );
        break;
      case AppRoutes.allProductsByTypeScreen:
        if (routeArguments == null ||
            routeArguments['productType'] == null ||
            routeArguments['title'] == null) {
          debugPrint('⚠️ Invalid product type arguments, redirecting to main layout');
          page = const MainLayoutScreen();
        } else {
          page = AllProductsByTypeScreen(
            productType: routeArguments['productType'] as ProductType,
            title: routeArguments['title'] as String,
            dealId: routeArguments['dealId'] as int?,
          );
        }
        break;
      case addressListScreen:
        page = const AddressListScreen();
        break;
      case newCheckoutScreen:
        page = const CheckoutScreen();
        break;
      case setProductsScreen:
        page = const SetProductsScreen();
        break;
      case allOrdersListScreen:
        page = const OrdersListScreen();
        break;
      case AppRoutes.orderDetailsScreen:
        final orderId = routeArguments?['orderId'];

        debugPrint('=== ORDER DETAILS ROUTE DEBUG ===');
        debugPrint('OrderId: $orderId');
        debugPrint('From notification: ${pendingNotificationAction != null}');

        if (orderId == null) {
          debugPrint('⚠️ Invalid order ID, redirecting to main layout');
          page = const MainLayoutScreen();
        } else {
          // Handle both int and string order IDs
          int? parsedOrderId;
          if (orderId is int) {
            parsedOrderId = orderId;
          } else if (orderId is String) {
            parsedOrderId = int.tryParse(orderId);
          }

          if (parsedOrderId == null) {
            debugPrint('⚠️ Could not parse order ID, redirecting to main layout');
            page = const MainLayoutScreen();
          } else {
            debugPrint('✅ Valid order ID found, creating OrderDetailsScreen');
            page = OrderDetailsScreen(orderId: parsedOrderId);
          }
        }
        break;
      case searchScreen:
        page = const SearchScreen();
        break;
      case walletScreen:
        page = const WalletScreen();
        break;
      default:
        debugPrint('⚠️ Unknown route: ${settings.name}, redirecting to main layout');
        page = const MainLayoutScreen();
    }

    return PageTransition(
      child: page,
      type: transition,
      settings: settings,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 300),
    );
  }

  static void navigateTo(
      BuildContext context,
      String route, {
        Object? arguments,
        PageTransitionType? transitionType,
      }) {
    Navigator.push(
      context,
      generateRoute(RouteSettings(name: route, arguments: arguments),
          transitionType: transitionType),
    );
  }

  static void navigateToAndReplace(
      BuildContext context,
      String route, {
        Object? arguments,
        PageTransitionType? transitionType,
      }) {
    Navigator.pushReplacement(
      context,
      generateRoute(RouteSettings(name: route, arguments: arguments),
          transitionType: transitionType),
    );
  }

  static void navigateToAndRemoveUntil(
      BuildContext context,
      String route, {
        PageTransitionType? transitionType,
      }) {
    Navigator.pushAndRemoveUntil(
      context,
      generateRoute(RouteSettings(name: route), transitionType: transitionType),
          (route) => false,
    );
  }
}