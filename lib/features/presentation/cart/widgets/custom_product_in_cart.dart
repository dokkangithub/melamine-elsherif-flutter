import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import '../../../../../core/config/routes.dart/routes.dart';
import '../../../../core/utils/widgets/custom_cached_image.dart';
import '../../../domain/cart/entities/cart.dart';

class ProductItemInCart extends StatelessWidget {
  final CartItem item;
  final int index;
  final Function(int) onDelete;
  final bool isFavorite;
  final Function(int)? onQuantityChanged;

  const ProductItemInCart({
    super.key,
    required this.item,
    required this.index,
    required this.onDelete,
    this.isFavorite = false,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        height: 100,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            children: [
              // Product Image
              Expanded(
                  flex: 1,
                  child: _productImage()),
              SizedBox(width: 8),
              // Product Details
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      item.productName,
                      style: context.titleSmall.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.variant.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('${item.variant}',
                          style: context.bodySmall.copyWith(color: Colors.grey[600]),
                        ),
                      ),
                    Spacer(),
                    // Quantity Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
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
                            child: Text('${item.quantity}',
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

                  ],
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    //delete item
                    InkWell(
                      onTap: (){
                        onDelete(item.id);
                      },
                      child: CustomImage(assetPath: AppSvgs.delete_icon),
                    ),
                    Spacer(),
                    Text('${item.currencySymbol}${item.discountedPrice}',
                      style: context.titleSmall.copyWith(
                        color: AppTheme.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
    return CustomButton(
      onPressed: enabled ? onPressed : null,
      padding: EdgeInsets.all(6),
      borderRadius: 8,
      isOutlined: true,
      child: Icon(
        icon,
        size: 16,
        color: AppTheme.primaryColor,
      ),
    );
  }

}