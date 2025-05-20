import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../widgets/empty_wishlist_widget.dart';
import '../widgets/wishlist_widget.dart';
import '../widgets/shimmer/wishlist_screen_shimmer.dart';
import '../controller/wishlist_provider.dart';

class WishlistScreen extends StatefulWidget {
  final bool isActive;
  
  const WishlistScreen({super.key, this.isActive = false});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final GlobalKey _animationKey = GlobalKey();
  bool _shouldAnimate = false;
  
  @override
  void initState() {
    super.initState();
    _shouldAnimate = widget.isActive;
    
    // Load wishlist data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<WishlistProvider>(context, listen: false);
      provider.fetchWishlist();
    });
  }

  @override
  void didUpdateWidget(WishlistScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reset animation state when screen becomes inactive
    if (!widget.isActive && oldWidget.isActive) {
      setState(() {
        _shouldAnimate = false;
      });
    }
    
    // Trigger animation when screen becomes active
    if (widget.isActive && !oldWidget.isActive) {
      setState(() {
        _shouldAnimate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WishlistProvider>(
        builder: (context, provider, child) {
          if (provider.wishlistState == LoadingState.error) {
            return const SizedBox.shrink();
          } else {
            // Using a key to force rebuild when animation state changes
            return WishlistWidget(
              key: _shouldAnimate ? ValueKey('animated-${DateTime.now().millisecondsSinceEpoch}') : _animationKey,
              provider: provider,
              triggerAnimation: _shouldAnimate,
            );
          }
        },
      ),
    );
  }
}
