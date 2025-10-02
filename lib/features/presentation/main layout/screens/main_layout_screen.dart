import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controller/layout_provider.dart';
import '../widgets/bottom_nav_bar_widget.dart';
import '../widgets/drawer_widget.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => MainLayoutScreenState();
}

class MainLayoutScreenState extends State<MainLayoutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late PageController _pageController;
  final double _maxSlideAmount = 0.8;
  bool _isNavigating = false; // Flag to prevent conflicts during navigation

  // Configuration options for swipe behavior
  static const bool _enableSwipe = true;
  static const Duration _pageAnimationDuration = Duration(milliseconds: 300);
  static const Curve _pageAnimationCurve = Curves.easeInOut;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    // Initialize PageController with the current index
    final provider = Provider.of<LayoutProvider>(context, listen: false);
    _pageController = PageController(initialPage: provider.currentIndex);

    // Set up callback for external navigation
    provider.setOnIndexChangedCallback(_handleExternalNavigation);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void toggleDrawer() {
    if (_animationController.isDismissed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  // Handle navigation triggered externally (bottom nav, drawer, etc.)
  void _handleExternalNavigation() {
    if (_isNavigating) return; // Prevent recursive calls

    final provider = Provider.of<LayoutProvider>(context, listen: false);
    final targetIndex = provider.currentIndex;

    // No wishlist tab anymore; no auth guard needed here

    if (_pageController.hasClients &&
        _pageController.page?.round() != targetIndex) {
      _navigateToPage(targetIndex);
    }
  }

  void _onPageChanged(int index) {
    if (_isNavigating) return; // Prevent conflicts during navigation

    final provider = Provider.of<LayoutProvider>(context, listen: false);

    // No wishlist tab anymore; straight navigation

    // Add haptic feedback on page change
    HapticFeedback.lightImpact();

    // Update provider state
    _isNavigating = true;
    provider.setCurrentIndex(index);
    _isNavigating = false;
  }

  void _navigateToPage(int index) {
    if (!_pageController.hasClients || _isNavigating) return;

    // No wishlist tab anymore; no auth guard needed here

    _isNavigating = true;
    _pageController
        .animateToPage(
          index,
          duration: _pageAnimationDuration,
          curve: _pageAnimationCurve,
        )
        .then((_) {
          _isNavigating = false;
        });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<LayoutProvider>(
      builder: (context, provider, child) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final slideAmount =
                screenWidth * _maxSlideAmount * _animationController.value;
            final contentScale = 1.0 - (0.2 * _animationController.value);
            final cornerRadius = 24.0 * _animationController.value;

            return Stack(
              children: [
                // Drawer
                DrawerWidget(animationController: _animationController),

                // Main content with animation
                Transform(
                  transform: Matrix4.identity()
                    ..translate(slideAmount)
                    ..scale(contentScale),
                  alignment: Alignment.centerLeft,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(cornerRadius),
                    child: GestureDetector(
                      onTap: _animationController.isCompleted
                          ? () => toggleDrawer()
                          : null,
                      child: _buildMainContent(context, provider),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context, LayoutProvider provider) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.dark,
        ),
        child: _enableSwipe
            ? PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const ClampingScrollPhysics(),
                children: provider.mainScreens,
              )
            : IndexedStack(
                index: provider.currentIndex,
                children: provider.mainScreens,
              ),
      ),
      bottomNavigationBar: const BottomNavBarWidget(),
    );
  }
}
