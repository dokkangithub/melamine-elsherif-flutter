import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:melamine_elsherif/features/domain/product/entities/product.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';

class FeaturedProductCard extends StatefulWidget {
  final Product product;
  final double width;
  final ScrollController scrollController;
  final int index;

  const FeaturedProductCard({
    super.key,
    required this.product,
    required this.scrollController,
    required this.index,
    this.width = 250,
  });

  @override
  State<FeaturedProductCard> createState() => _FeaturedProductCardState();
}

class _FeaturedProductCardState extends State<FeaturedProductCard> {
  bool _isPressed = false;

  double _calculateScale() {
    if (!widget.scrollController.hasClients) return 0.9;

    final scrollOffset = widget.scrollController.offset;
    final cardPosition = (widget.width + 16) * widget.index;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardCenter = cardPosition + (widget.width / 2);
    final screenCenter = scrollOffset + (screenWidth / 2);

    // Calculate distance from screen center
    final distance = (cardCenter - screenCenter).abs();
    final maxDistance = screenWidth * 0.8;

    // Scale from 0.85 to 1.0 based on distance from center
    final normalizedDistance = (distance / maxDistance).clamp(0.0, 1.0);
    return 1.0 - (normalizedDistance * 0.15);
  }

  double _calculateOpacity() {
    if (!widget.scrollController.hasClients) return 0.7;

    final scrollOffset = widget.scrollController.offset;
    final cardPosition = (widget.width + 16) * widget.index;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardCenter = cardPosition + (widget.width / 2);
    final screenCenter = scrollOffset + (screenWidth / 2);

    // Calculate distance from screen center
    final distance = (cardCenter - screenCenter).abs();
    final maxDistance = screenWidth * 0.8;

    // Opacity from 0.6 to 1.0 based on distance from center
    final normalizedDistance = (distance / maxDistance).clamp(0.0, 1.0);
    return 1.0 - (normalizedDistance * 0.4);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.scrollController,
      builder: (context, child) {
        final scale = _calculateScale();
        final opacity = _calculateOpacity();

        return Transform.scale(
          scale: scale * (_isPressed ? 0.96 : 1.0),
          child: Opacity(
            opacity: opacity,
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: () {
                AppRoutes.navigateTo(
                  context,
                  AppRoutes.productDetailScreen,
                  arguments: {'slug': widget.product.slug},
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                width: widget.width,
                margin: const EdgeInsets.only(right: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: AspectRatio(
                        aspectRatio: 0.95,
                        child: CustomImage(
                          imageUrl: widget.product.thumbnailImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Product Name
                    Text(
                      widget.product.name,
                      maxLines: 2,
                      style: context.titleLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // Price
                    Text(
                      widget.product.discountedPrice,
                      style: context.titleLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}