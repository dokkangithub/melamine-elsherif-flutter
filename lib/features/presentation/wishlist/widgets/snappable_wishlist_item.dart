import 'package:flutter/material.dart';
import 'package:thanos_snap_effect/thanos_snap_effect.dart';
import 'package:melamine_elsherif/features/domain/wishlist/entities/wishlist_details.dart';
import 'package:provider/provider.dart';
import '../controller/wishlist_provider.dart';

class SnappableWishlistItem extends StatefulWidget {
  final Widget child;
  final String slug;

  const SnappableWishlistItem({
    Key? key,
    required this.child,
    required this.slug,
  }) : super(key: key);

  @override
  State<SnappableWishlistItem> createState() => SnappableWishlistItemState();
}

class SnappableWishlistItemState extends State<SnappableWishlistItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isDeleting = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isDeleting && !_isCompleted) {
        _isCompleted = true;
        final provider = context.read<WishlistProvider>();
        // Remove from wishlist immediately after animation completes for smooth UX
        provider.removeFromWishlist(widget.slug);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void startSnap() {
    if (!_isDeleting) {
      setState(() {
        _isDeleting = true;
      });
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Snappable(
      animation: _animationController,
      style: const SnappableStyle(
        particleLifetime: 0.8,
        fadeOutDuration: 0.4,
        particleSpeed: 1.0,
        particleSize: SnappableParticleSize.squareFromRelativeWidth(0.01),
      ),
      child: widget.child,
    );
  }
} 