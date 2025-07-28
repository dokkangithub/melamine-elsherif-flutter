import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/themes.dart/theme.dart';
import '../controller/layout_provider.dart';
import '../../home/widgets/app_bar_widget.dart';
import '../widgets/bottom_nav_bar_widget.dart';
import '../widgets/drawer_widget.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => MainLayoutScreenState();
}

class MainLayoutScreenState extends State<MainLayoutScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late PageController _pageController;
  final double _maxSlideAmount = 0.8;

  // Configuration options for swipe behavior
  static const bool _enableSwipe = true; // Set to false to disable swipe
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

  void _onPageChanged(int index) {
    final provider = Provider.of<LayoutProvider>(context, listen: false);

    // Add haptic feedback on page change
    HapticFeedback.lightImpact();

    provider.setCurrentIndex(index);
  }

  void _navigateToPage(int index) {
    if (!_pageController.hasClients) return;

    _pageController.animateToPage(
      index,
      duration: _pageAnimationDuration,
      curve: _pageAnimationCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<LayoutProvider>(
      builder: (context, provider, child) {
        // Update page controller when index changes from external sources
        // (like bottom nav bar tap or programmatic navigation)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients &&
              _pageController.page?.round() != provider.currentIndex) {
            _navigateToPage(provider.currentIndex);
          }
        });

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final slideAmount = screenWidth * _maxSlideAmount * _animationController.value;
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
                      onTap: _animationController.isCompleted ? () => toggleDrawer() : null,
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

  // Build the main content with PageView for swipe navigation
  Widget _buildMainContent(BuildContext context, LayoutProvider provider) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: AppTheme.white,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.dark,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: _enableSwipe
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
      bottomNavigationBar: const BottomNavBarWidget(),
    );
  }
}