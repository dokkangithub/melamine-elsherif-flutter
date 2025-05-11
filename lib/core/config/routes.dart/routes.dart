import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/enums/products_type.dart';
import 'package:melamine_elsherif/features/presentation/category/screens/category_screen.dart';
import 'package:melamine_elsherif/features/presentation/profile/screens/edit_profile_screen.dart';
import 'package:melamine_elsherif/features/presentation/profile/screens/profile_screen.dart';
import 'package:melamine_elsherif/features/presentation/wishlist/screens/wishlist_screen.dart';
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
import '../../../features/presentation/splash/splash_screen.dart';
import '../../../features/presentation/search/screens/search_screen.dart';


// Define transition types for different animations outside the class
enum PageTransitionType {
  slide, // Slide from right
  fade, // Fade in
  scale, // Scale up
  slideUp, // Slide from bottom
  rotation, // Rotate in
  size, // Grow from center
}

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
  static const String addressListScreen = '/addressListScreen';
  static const String checkoutScreen = '/checkout';
  static const String newCheckoutScreen = '/new-checkout';
  static const String successScreen = '/success';
  static const String allOrdersListScreen = '/all-orders-list';
  static const String orderDetailsScreen = '/order-details';
  static const String searchScreen = '/search-screen';


  static const PageTransitionType defaultTransition = PageTransitionType.fade;

  static Route<dynamic> generateRoute(RouteSettings settings, {PageTransitionType? transitionType}) {
    Widget page;

    // Use provided transition type or default
    final transition = transitionType ?? defaultTransition;

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
        final args = settings.arguments as Map<String, dynamic>?;
        page = VerificationScreen(
          contactInfo: args?['contactInfo'] as String? ?? '',
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
        final args = settings.arguments as Map<String, dynamic>?;
        page = ProductDetailScreen(slug: args?['slug'] as String);
        break;
      case allCategoryProductsScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        page = AllCategoryProductsScreen(
          category: args?['category'] as Category,
        );
        break;
      case AppRoutes.allProductsByTypeScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null ||
            args['productType'] == null ||
            args['title'] == null) {
          page = const Scaffold(
            body: Center(child: Text('Invalid product details type')),
          );
        } else {
          page = AllProductsByTypeScreen(
            productType: args['productType'] as ProductType,
            title: args['title'] as String,
          );
        }
        break;
      case addressListScreen:
        page = const AddressListScreen();
        break;
      case newCheckoutScreen:
        page = const CheckoutScreen();
        break;
      case allOrdersListScreen:
        page = const OrdersListScreen();
        break;
      case AppRoutes.orderDetailsScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || args['orderId'] == null) {
          page = const Scaffold(body: Center(child: Text('Invalid order id')));
        } else {
          page = OrderDetailsScreen(orderId: args['orderId'] as int);
        }
        break;
      case searchScreen:
        page = const SearchScreen();
        break;
      default:
        page = Scaffold(
          body: Center(child: Text('Route ${settings.name} not found')),
        );
    }

    // Apply appropriate transition animation
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const duration = Duration(milliseconds: 300);
        const curve = Curves.easeInOut;

        switch (transition) {
          case PageTransitionType.fade:
            return FadeTransition(
              opacity: animation,
              child: child,
            );

          case PageTransitionType.scale:
            return ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1.0)
                  .animate(CurvedAnimation(parent: animation, curve: curve)),
              child: child,
            );

          case PageTransitionType.rotation:
            return RotationTransition(
              turns: Tween<double>(begin: 0.5, end: 1.0)
                  .animate(CurvedAnimation(parent: animation, curve: curve)),
              child: child,
            );

          case PageTransitionType.slideUp:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: curve)),
              child: child,
            );

          case PageTransitionType.size:
            return SizeTransition(
              sizeFactor: animation,
              child: child,
            );

          case PageTransitionType.slide:
          default:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: curve)),
              child: child,
            );
        }
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Updated navigation methods to accept transition type
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