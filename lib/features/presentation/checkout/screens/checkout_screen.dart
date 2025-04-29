import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_form_field.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_loading.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/routes.dart/routes.dart';
import '../../../../core/utils/constants/app_strings.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../domain/address/entities/address.dart';
import '../../address/controller/address_provider.dart';
import '../../address/screens/address_list_screen.dart';
import '../../address/screens/add_edit_address_screen.dart';
import '../../cart/controller/cart_provider.dart';
import '../../coupon/controller/coupon_provider.dart';
import '../controller/payment_provider.dart';
import '../widgets/geust_address_form.dart';
import '../widgets/shipping_address_section.dart';
import '../widgets/payment_method_section.dart';
import '../widgets/coupon_section.dart';
import '../widgets/order_summary_section.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Address? _selectedAddress;
  bool _isProcessingPayment = false;
  final _couponController = TextEditingController();
  bool _isApplyingCoupon = false;

  bool get _isGuestUser => AppStrings.token == null;

  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    final addressProvider = context.read<AddressProvider>();
    final paymentProvider = context.read<PaymentProvider>();
    final cartProvider = context.read<CartProvider>();

    if (_isGuestUser) {
      // For guest users, we only load checkout types and cart summary
      await Future.wait([
        paymentProvider.fetchPaymentTypes(),
        cartProvider.fetchCartSummary(),
      ]);
    } else {
      // For logged in users, load addresses as well
      await Future.wait([
        addressProvider.fetchAddresses(),
        paymentProvider.fetchPaymentTypes(),
        cartProvider.fetchCartSummary(),
      ]);

      if (addressProvider.addresses.isNotEmpty && mounted) {
        final defaultAddress = addressProvider.addresses.firstWhere(
          (addr) => addr.isDefault,
          orElse: () => addressProvider.addresses.first,
        );

        setState(() {
          _selectedAddress = defaultAddress;
        });

        await _updateShippingWithSelectedAddress(paymentProvider);
      }
    }
  }

  Future<void> _updateShippingWithSelectedAddress(
    PaymentProvider paymentProvider,
  ) async {
    if (_selectedAddress == null) return;

    try {
      if (_isGuestUser) {
        await context.read<PaymentProvider>().updateShippingTypeForGuest(
          stateId: _selectedAddress!.stateId,
          address: _selectedAddress!.address,
        );
      } else {
        // Only update address in cart for logged in users
        await context.read<AddressProvider>().updateAddressInCart(
          _selectedAddress!.id,
        );
      }
      await context.read<CartProvider>().fetchCartSummary();
    } catch (e) {
      debugPrint('Error updating shipping: $e');
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  void _navigateToAddressList() async {
    if (_isGuestUser) {
      _navigateToGuestAddressForm();
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddressListScreen(isSelectable: true),
      ),
    );

    if (result != null && result is Address) {
      setState(() {
        _selectedAddress = result;
      });
      await _updateShippingWithSelectedAddress(context.read<PaymentProvider>());
    }
  }

  void _navigateToGuestAddressForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                GuestAddressFormScreen(initialAddress: _selectedAddress),
      ),
    );

    if (result != null && result is Address) {
      onAddressSelected(result);
    }
  }

  void onAddressSelected(Address address) {
    setState(() {
      _selectedAddress = address;
    });
    _updateShippingWithSelectedAddress(context.read<PaymentProvider>());
  }

  void _navigateToEditAddress(int addressId) async {
    if (_isGuestUser) {
      _navigateToGuestAddressForm();
      return;
    }

    final addressProvider = context.read<AddressProvider>();
    final address = addressProvider.addresses.firstWhere(
      (addr) => addr.id == addressId,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditAddressScreen(address: address),
      ),
    );

    await addressProvider.fetchAddresses();

    if (_selectedAddress?.id == addressId && mounted) {
      final updatedAddress = addressProvider.addresses.firstWhere(
        (addr) => addr.id == addressId,
        orElse: () => _selectedAddress!,
      );

      setState(() {
        _selectedAddress = updatedAddress;
      });

      await _updateShippingWithSelectedAddress(context.read<PaymentProvider>());
    }
  }

  Future<void> _applyCoupon(CouponProvider couponProvider) async {
    final couponCode = _couponController.text.trim();
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
        _couponController.clear();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('coupon_removed_successfully'.tr(context))),
        );
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

  Future<void> _processPayment() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('select_delivery_address'.tr(context))),
      );
      return;
    }

    if (_selectedAddress!.address.isEmpty ||
        _selectedAddress!.phone.isEmpty ||
        _selectedAddress!.stateId <= 0 ||
        _selectedAddress!.cityName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('missing_address_fields'.tr(context))),
      );
      return;
    }

    final paymentProvider = context.read<PaymentProvider>();
    if (paymentProvider.selectedPaymentTypeKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('select_payment_method'.tr(context))),
      );
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final response = await paymentProvider.createOrder(
        postalCode: _selectedAddress!.postalCode,
        stateId: _selectedAddress!.stateId.toString(),
        address: _selectedAddress!.address,
        city: _selectedAddress!.cityName,
        phone: _selectedAddress!.phone,
        additionalInfo: _noteController.text ?? '',
        context: context,
      );

      if (response.result && mounted) {
        await context.read<CartProvider>().fetchCartItems();
        await context.read<CartProvider>().fetchCartCount();

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.successScreen,
          (route) => route.settings.name == AppRoutes.homeScreen,
        );
      } else if (!response.result && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message)));
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
          _isProcessingPayment = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2037),
        elevation: 0,
        title: Text(
          'checkout'.tr(context),
          style: context.headlineMedium?.copyWith(color: AppTheme.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer3<AddressProvider, PaymentProvider, CartProvider>(
        builder: (context, addressProvider, paymentProvider, cartProvider, _) {
          final bool isLoading =
              (!_isGuestUser &&
                  addressProvider.addressState == LoadingState.loading) ||
              paymentProvider.paymentTypesState == LoadingState.loading ||
              cartProvider.cartState == LoadingState.loading;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    // Shipping Address Section
                    ShippingAddressSection(
                      selectedAddress: _selectedAddress,
                      addresses: _isGuestUser ? [] : addressProvider.addresses,
                      onAddressSelected: (address) {
                        setState(() {
                          _selectedAddress = address;
                        });
                        _updateShippingWithSelectedAddress(paymentProvider);
                      },
                      onChangePressed: _navigateToAddressList,
                      onEditPressed: _navigateToEditAddress,
                      isLoading: isLoading,
                    ),

                    // Payment Method Section
                    PaymentMethodSection(
                      paymentTypes: paymentProvider.paymentTypes,
                      selectedPaymentTypeKey:
                          paymentProvider.selectedPaymentTypeKey,
                      onPaymentTypeSelected: paymentProvider.selectPaymentType,
                      isLoading: isLoading,
                    ),

                    // Coupon Section
                    Consumer<CouponProvider>(
                      builder: (context, couponProvider, _) {
                        return CouponSection(
                          couponController: _couponController,
                          isInitialLoading: isLoading,
                          hasCoupon:
                              cartProvider.cartSummary?.couponApplied == true,
                          appliedCouponCode:
                              cartProvider.cartSummary?.couponCode,
                          isLoading: _isApplyingCoupon,
                          errorMessage: couponProvider.couponError,
                          onApply: () => _applyCoupon(couponProvider),
                          onRemove: () => _removeCoupon(couponProvider),
                        );
                      },
                    ),

                    // Order Summary Section
                    OrderSummarySection(
                      cartSummary: cartProvider.cartSummary!,
                      isUpdatingShipping:
                          paymentProvider.shippingUpdateState ==
                          LoadingState.loading,
                      shippingError: paymentProvider.errorMessage,
                      isInitialLoading: isLoading,
                    ),

                    // Add note to order section
                    Container(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      child: CustomTextFormField(
                        controller: _noteController,
                        maxLines: 2,
                        hint: 'Add a note to order',
                      ),
                    ),
                  ],
                ),
              ),

              // Payment Button
              if (!isLoading)
                _isProcessingPayment
                    ? const CustomLoadingWidget()
                    : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(0, -2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: CustomButton(
                        borderRadius: 15,
                        onPressed:
                            _isProcessingPayment ? null : _processPayment,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Checkout • L.E.45.00',
                              style: context.titleLarge?.copyWith(
                                color: AppTheme.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}
