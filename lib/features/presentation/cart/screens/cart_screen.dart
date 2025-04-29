import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_form_field.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/routes.dart/routes.dart';
import '../../../../core/config/themes.dart/theme.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../coupon/controller/coupon_provider.dart';
import '../controller/cart_provider.dart';
import '../widgets/empty_cart_widget.dart';
import '../widgets/shimmer/cart_screen_shimmer.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promoCodeController = TextEditingController();
  bool _isApplyingCoupon = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final cartProvider = context.read<CartProvider>();
      cartProvider.fetchCartItems();
      cartProvider.fetchCartCount();
      cartProvider.fetchCartSummary();
    });
  }

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon(CouponProvider couponProvider) async {
    final couponCode = _promoCodeController.text.trim();
    if (couponCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('please_enter_coupon_code'.tr(context))),
      );
      return;
    }

    setState(() {
      _isApplyingCoupon = true;
    });

    try {
      await couponProvider.applyCoupon(couponCode);
      await context.read<CartProvider>().fetchCartSummary();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(couponProvider.appliedCoupon?.message ?? '')),
        );
      }

      if (couponProvider.appliedCoupon?.success == true) {
        _promoCodeController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isApplyingCoupon = false;
        });
      }
    }
  }

  Future<void> _removeCoupon(CouponProvider couponProvider) async {
    setState(() {
      _isApplyingCoupon = true;
    });

    try {
      await couponProvider.removeCoupon();
      await context.read<CartProvider>().fetchCartSummary();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Coupon removed successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isApplyingCoupon = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Consumer<CartProvider>(
          builder: (context, cartProvider, _) {
            final itemCount = cartProvider.cartItems.length;
            return Text(
              'Shopping Cart (${itemCount} items)',
              style: context.titleMedium,
            );
          },
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          if (cartProvider.cartState == LoadingState.loading) {
            return const CartScreenShimmer();
          }

          if (cartProvider.cartItems.isEmpty) {
            return const EmptyCartWidget();
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // Cart items
              ...cartProvider.cartItems
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: CustomImage(
                                  imageUrl: item.thumbnailImage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Product details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Product name and model
                                          Expanded(
                                            child: Text(
                                              item.productName,
                                              style: context.titleMedium,
                                            ),
                                          ),

                                          // Delete button
                                          InkWell(
                                            onTap: () {
                                              cartProvider.deleteCartItem(
                                                item.id,
                                              );
                                            },
                                            child: Icon(
                                              Icons.delete_outline,
                                              color: Colors.red[400],
                                              size: 22,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 12),

                                    // Quantity selector and price
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Quantity controls
                                        Row(
                                          children: [
                                            // Minus button
                                            InkWell(
                                              onTap:
                                                  item.quantity >
                                                          item.lowerLimit
                                                      ? () {
                                                        _updateQuantity(
                                                          cartProvider,
                                                          item.id,
                                                          item.quantity - 1,
                                                        );
                                                      }
                                                      : null,
                                              child: Container(
                                                width: 28,
                                                height: 28,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    width: 1,
                                                    color:
                                                        AppTheme.primaryColor,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Icon(
                                                  Icons.remove,
                                                  color: AppTheme.accentColor,
                                                  size: 16,
                                                ),
                                              ),
                                            ),

                                            // Quantity value
                                            Container(
                                              width: 32,
                                              height: 28,
                                              alignment: Alignment.center,
                                              child: Text(
                                                '${item.quantity}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            // Plus button
                                            InkWell(
                                              onTap:
                                                  item.quantity <
                                                          item.upperLimit
                                                      ? () {
                                                        _updateQuantity(
                                                          cartProvider,
                                                          item.id,
                                                          item.quantity + 1,
                                                        );
                                                      }
                                                      : null,
                                              child: Container(
                                                width: 28,
                                                height: 28,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    width: 1,
                                                    color:
                                                        AppTheme.primaryColor,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Icon(
                                                  Icons.add,
                                                  color: AppTheme.accentColor,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Price
                                        Text(
                                          '\$${item.discountedPrice}',
                                          style: context.titleMedium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),

              SizedBox(height: 16),

              // Order Summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order summary', style: context.titleMedium),
                      SizedBox(height: 12),
                      _buildSummaryRow(
                        'Subtotal',
                        '${cartProvider.cartSummary?.currencySymbol ?? ''}'
                            '${((cartProvider.cartSummary?.subtotal ?? 0.0) - (cartProvider.cartSummary?.discount ?? 0.0)).toStringAsFixed(2)}',
                      ),

                      _buildSummaryRow(
                        'Shipping Fee',
                        '${cartProvider.cartSummary?.currencySymbol ?? ''}${cartProvider.cartSummary?.shippingCost.toStringAsFixed(2) ?? '0.00'}',
                      ),
                      if (cartProvider.cartSummary?.couponApplied == true)
                        _buildSummaryRow(
                          'Discount',
                          '- ${cartProvider.cartSummary?.currencySymbol ?? ''}${cartProvider.cartSummary?.discount.toStringAsFixed(2) ?? '0.00'}',
                          isBold: true,
                        ),
                      _buildSummaryRow(
                        'Total',
                        '${cartProvider.cartSummary?.currencySymbol ?? ''}${cartProvider.cartSummary?.total.toStringAsFixed(2) ?? '0.00'}',
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Discount Coupon Section
              Consumer<CouponProvider>(
                builder: (context, couponProvider, _) {
                  final bool hasCoupon =
                      couponProvider.appliedCoupon?.success == true ||
                      cartProvider.cartSummary?.couponApplied == true;
                  final String? couponCode =
                      couponProvider.appliedCoupon?.couponCode ??
                      cartProvider.cartSummary?.couponCode;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discount Coupon',
                          style: context.titleMedium?.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        SizedBox(height: 12),

                        if (hasCoupon && couponCode != null)
                          // Applied coupon UI
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        couponCode,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'Coupon applied successfully',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed:
                                      _isApplyingCoupon
                                          ? null
                                          : () => _removeCoupon(couponProvider),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    foregroundColor: Colors.black87,
                                  ),
                                  child: Text(
                                    'Remove',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          // Coupon input
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextFormField(
                                  controller: _promoCodeController,
                                  hint: 'Enter promo code',
                                ),
                              ),
                              SizedBox(width: 8),
                              CustomButton(
                                onPressed:
                                    _isApplyingCoupon
                                        ? null
                                        : () => _applyCoupon(couponProvider),
                                isOutlined: true,
                                child:
                                    _isApplyingCoupon
                                        ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                        : Text(
                                          'Apply',
                                          style: context.titleSmall,
                                        ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),

              SizedBox(height: 24),

              // Checkout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.newCheckoutScreen);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Proceed to Checkout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Secure Checkout Text
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 14, color: Colors.grey[600]),
                    SizedBox(width: 6),
                    Text(
                      'Secure Checkout',
                      style: context.bodyMedium,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  void _updateQuantity(CartProvider cartProvider, int itemId, int newQuantity) {
    // Create a list of all cart IDs
    final cartIds = cartProvider.cartItems
        .map((i) => i.id.toString())
        .join(',');

    // Create updated quantities list
    final quantities =
        cartProvider.cartItems
            .map((i) => i.id == itemId ? newQuantity : i.quantity)
            .toList();

    final quantitiesStr = quantities.join(',');

    // Update cart quantities
    cartProvider.updateCartQuantities(cartIds, quantitiesStr);
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
