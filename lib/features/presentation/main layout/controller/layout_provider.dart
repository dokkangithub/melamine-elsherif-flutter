import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/features/presentation/cart/screens/cart_screen.dart';
import 'package:melamine_elsherif/features/presentation/category/screens/category_screen.dart';
import 'package:melamine_elsherif/features/presentation/home/screens/home.dart';
import 'package:melamine_elsherif/features/presentation/profile/screens/profile_screen.dart';
import 'package:melamine_elsherif/features/presentation/wishlist/screens/wishlist_screen.dart';

class LayoutProvider extends ChangeNotifier {
  int _currentIndex = 0;
  bool _isLoading = false;
  final bool _isDrawerOpen = false;
  late List<Widget> _mainScreens;

  // Track if we're coming from a "Buy Now" action to optimize cart loading
  bool _skipCartDataReload = false;

  // Callback to notify external components (like PageController) about index changes
  VoidCallback? _onIndexChanged;

  // Initialize screens once
  LayoutProvider() {
    _updateMainScreens();
  }

  // Update screens based on current index
  void _updateMainScreens() {
    _mainScreens = [
      const HomeScreen(),
      CategoryScreen(isActive: _currentIndex == 1),
      WishlistScreen(isActive: _currentIndex == 2),
      CartScreen(isActive: _currentIndex == 3),
      ProfileScreen(isActive: _currentIndex == 4),
    ];
  }

  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get isDrawerOpen => _isDrawerOpen;
  List<Widget> get mainScreens => _mainScreens;
  bool get skipCartDataReload => _skipCartDataReload;

  // Set callback for external components to listen to index changes
  void setOnIndexChangedCallback(VoidCallback callback) {
    _onIndexChanged = callback;
  }

  void setCurrentIndex(int index) {
    if (_currentIndex == index) return; // Prevent unnecessary updates

    final oldIndex = _currentIndex;
    _currentIndex = index;

    // Reset the flag when changing to any tab other than cart
    if (index != 3) {
      _skipCartDataReload = false;
    }

    // Update screens with new active state
    _updateMainScreens();

    // Notify listeners first
    notifyListeners();

    // Then notify external listeners (like PageController) after a brief delay
    // This prevents conflicts between state updates and navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onIndexChanged?.call();
    });
  }

  set currentIndex(int index) {
    setCurrentIndex(index);
  }

  /// Navigate to cart tab after adding product via Buy Now
  /// This will skip unnecessary data reloading
  void navigateToCartFromBuyNow() {
    _skipCartDataReload = true;
    _currentIndex = 3; // Cart tab index
    _updateMainScreens(); // Update screens with new active state

    // Notify listeners first
    notifyListeners();

    // Then notify external listeners (like PageController)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onIndexChanged?.call();
    });
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  List<String> screenTitles = [
    'explore',
    'category',
    'wishlist',
    'cart',
    'profile',
  ];
}