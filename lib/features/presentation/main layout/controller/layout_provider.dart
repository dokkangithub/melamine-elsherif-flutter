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
  late final List<Widget> _mainScreens;

  // Initialize screens once
  LayoutProvider() {
    _mainScreens = [
      const HomeScreen(),
      const CategoryScreen(),
      const WishlistScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];
  }

  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get isDrawerOpen => _isDrawerOpen;
  List<Widget> get mainScreens => _mainScreens;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
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