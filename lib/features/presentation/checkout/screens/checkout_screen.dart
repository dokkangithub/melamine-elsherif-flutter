import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
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
import '../controller/payment_provider.dart';
import '../widgets/geust_address_form.dart';
import '../widgets/shipping_address_section.dart';
import '../widgets/payment_method_section.dart';
import '../widgets/order_summary_section.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Address? _selectedAddress;
  bool _isProcessingPayment = false;
  
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
        backgroundColor: AppTheme.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'checkout'.tr(context),
          style: context.headlineSmall!.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: CustomImage(assetPath: AppSvgs.back),
          ),
          onTap: () => Navigator.pop(context),
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

                    // Remove Coupon Section and directly show Order Summary
                    OrderSummarySection(
                      cartSummary: cartProvider.cartSummary!,
                      cartItems: cartProvider.cartItems,
                      isUpdatingShipping:
                          paymentProvider.shippingUpdateState ==
                          LoadingState.loading,
                      shippingError: paymentProvider.errorMessage,
                      isInitialLoading: isLoading, noteController: _noteController,
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
                        isGradient: true,
                        onPressed:
                            _isProcessingPayment ? null : _processPayment,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Place Order'.tr(context),
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
