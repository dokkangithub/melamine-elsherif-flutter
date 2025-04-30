import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_form_field.dart';
import 'package:melamine_elsherif/features/domain/cart/entities/cart.dart';
import 'package:melamine_elsherif/features/presentation/cart/widgets/custom_product_in_cart.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
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

          return Column(
            children: [
              // Cart items in an expandable list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  separatorBuilder:
                      (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Divider(color: Colors.grey[300]),
                      ),
                  itemCount: cartProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    final CartItem item = cartProvider.cartItems[index];
                    return ProductItemInCart(
                      item: item,
                      index: index,
                      onQuantityChanged: (int quntity) {
                        _updateQuantity(cartProvider, item.id, quntity);
                      },
                    );
                  },
                ),
              ),

              // Bottom sections container with a scrollable area if needed
              Column(
                children: [
                  // Order Summary
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15),
                        Text(
                          'Order summary',
                          style: context.titleMedium!.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildSummaryRow(
                          'Subtotal',
                          '${((cartProvider.cartSummary?.subtotal ?? 0.0) - (cartProvider.cartSummary?.discount ?? 0.0)).toStringAsFixed(2)}'
                              ' ${cartProvider.cartSummary?.currencySymbol ?? ''}',
                        ),

                        _buildSummaryRow(
                          'Shipping Fee',
                          '${cartProvider.cartSummary?.shippingCost.toStringAsFixed(2) ?? '0.00'} ${cartProvider.cartSummary?.currencySymbol ?? ''}',
                        ),
                        if (cartProvider.cartSummary?.couponApplied == true)
                          _buildSummaryRow(
                            'Discount',
                            '- ${cartProvider.cartSummary?.discount.toStringAsFixed(2) ?? '0.00'} ${cartProvider.cartSummary?.currencySymbol ?? ''}',
                            textColor: AppTheme.errorColor,
                          ),
                        _buildSummaryRow(
                          'Total',
                          '${cartProvider.cartSummary?.total.toStringAsFixed(2) ?? '0.00'} ${cartProvider.cartSummary?.currencySymbol ?? ''}',
                          isBold: true,
                        ),
                      ],
                    ),
                  ),

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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasCoupon && couponCode != null)
                              // Applied coupon UI
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            couponCode,
                                            style: context.titleMedium,
                                          ),
                                          Text(
                                            'Coupon applied successfully',
                                            style: context.titleSmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed:
                                          _isApplyingCoupon
                                              ? null
                                              : () =>
                                                  _removeCoupon(couponProvider),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        foregroundColor: Colors.black87,
                                      ),
                                      child: Text(
                                        'Remove',
                                        style: context.titleSmall!.copyWith(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.w800,
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
                                  SizedBox(width: 10),
                                  TextButton(
                                    onPressed:
                                        _isApplyingCoupon
                                            ? null
                                            : () =>
                                                _applyCoupon(couponProvider),
                                    child:
                                        _isApplyingCoupon
                                            ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                            : Text(
                                              'Apply',
                                              style: context.titleMedium!
                                                  .copyWith(
                                                    color:
                                                        AppTheme.primaryColor,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                            ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Checkout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    child: CustomButton(
                      text: 'Proceed to Checkout',
                      isGradient: true,
                      fullWidth: true,
                      borderRadius: 10,
                      padding: EdgeInsets.all(2),
                      onPressed: () {
                        AppRoutes.navigateTo(
                          context,
                          AppRoutes.newCheckoutScreen,
                        );
                      },
                    ),
                  ),

                  // Secure Checkout Text
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 6),
                        Text('Secure Checkout', style: context.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
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

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.titleSmall),
          Text(
            value,
            style: context.titleSmall!.copyWith(
              color: textColor ?? AppTheme.black,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
