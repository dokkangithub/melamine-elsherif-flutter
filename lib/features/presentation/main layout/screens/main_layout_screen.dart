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
  final double _maxSlideAmount = 0.8;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleDrawer() {
    if (_animationController.isDismissed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final provider = Provider.of<LayoutProvider>(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final slideAmount = screenWidth * _maxSlideAmount * _animationController.value;
        final contentScale = 1.0 - (0.2 * _animationController.value);
        final cornerRadius = 24.0 * _animationController.value;

        return Stack(
          children: [
            // Drawer
             DrawerWidget(animationController: _animationController,),

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
  }

  // Build the main content
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
      body: IndexedStack(
        index: provider.currentIndex,
        children: provider.mainScreens,
      ),
      bottomNavigationBar: const BottomNavBarWidget(),
    );
  }
}