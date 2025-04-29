import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import '../../../../../core/config/routes.dart/routes.dart';
import '../../../../core/utils/widgets/custom_cached_image.dart';
import '../../../domain/cart/entities/cart.dart';

class ProductItemInCart extends StatelessWidget {
  final CartItem item;
  final int index;
  final Function? onDelete;
  final bool isFavorite;
  final Function(int)? onQuantityChanged;

  const ProductItemInCart({
    super.key,
    required this.item,
    required this.index,
    this.onDelete,
    this.isFavorite = false,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Stack(
            children: [
              Row(
                children: [
                  // Product Image
                  _productImage(),
                  const SizedBox(width: 16),

                  // Product Details
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: context.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.variant.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              '${item.variant}',
                              style: context.bodySmall.copyWith(color: Colors.grey[600]),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Spacer(),
                        Text(
                          '${item.currencySymbol}${item.discountedPrice}',
                          style: context.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFAD6800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 15)
                ],
              ),
              // Quantity Controls
              Positioned(
                bottom: 4,
                right: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildQuantityButton(
                      icon: Icons.remove,
                      onPressed: () {
                        if (item.quantity > item.lowerLimit && onQuantityChanged != null) {
                          onQuantityChanged!(item.quantity - 1);
                        }
                      },
                      enabled: item.quantity > item.lowerLimit,
                      context: context,
                    ),
                    SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          '${item.quantity}',
                          style: context.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    _buildQuantityButton(
                      icon: Icons.add,
                      onPressed: () {
                        if (item.quantity < item.upperLimit && onQuantityChanged != null) {
                          onQuantityChanged!(item.quantity + 1);
                        }
                      },
                      enabled: item.quantity < item.upperLimit,
                      context: context,
                    ),
                  ],
                ),
              ),
              //delete item
              Positioned(
                top: 0,
                right: 0,
                child: InkWell(
                  onTap: (){
                    onDelete!();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 1,color: AppTheme.primaryColor)
                    ),
                    child: Icon(
                      Icons.close,
                      color: AppTheme.primaryColor,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productImage() {
    return CustomImage(
      imageUrl: item.thumbnailImage,
     borderRadius: BorderRadius.circular(15),
      fit: BoxFit.cover,
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
    required BuildContext context,
    bool enabled = true,
  }) {
    return InkWell(
      onTap: enabled ? onPressed : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? Colors.white : Colors.grey[500],
        ),
      ),
    );
  }

}