import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_back_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/themes.dart/theme.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../../core/widgets/custom_confirmation_dialog.dart';
import '../controller/address_provider.dart';
import '../widgets/address_item.dart';
import '../widgets/shimmer/address_list_shimmer.dart';
import '../widgets/empty_address_widget.dart';
import 'add_edit_address_screen.dart';
import '../../cart/controller/cart_provider.dart';

class AddressListScreen extends StatefulWidget {
  final bool isSelectable;

  const AddressListScreen({super.key, this.isSelectable = false});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().fetchAddresses();
    });
  }

  // Handle setting an address as default and update shipping
  Future<void> _handleSetDefault(int addressId) async {
    final addressProvider = context.read<AddressProvider>();
    
    try {
      // First make the address default
      await addressProvider.makeAddressDefault(addressId);
      
      // Then update address in cart and shipping
      await addressProvider.updateAddressInCart(
        addressId,
        context: context,
      );
      
      // Update cart summary to reflect shipping changes
      await context.read<CartProvider>().fetchCartSummary();
      
      // Show a confirmation message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('address_set_as_default'.tr(context)),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error message if something went wrong
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_setting_default_address'.tr(context)),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        leading: const CustomBackButton(),
        backgroundColor: AppTheme.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: FadeIn(
          duration: const Duration(milliseconds: 400),
          child: Text(
            'my_addresses'.tr(context), 
            style: context.displaySmall.copyWith(
              fontFamily: GoogleFonts.playfairDisplay().fontFamily,
              fontWeight: FontWeight.w600,
            )
          ),
        ),
      ),
      body: Consumer<AddressProvider>(
        builder: (context, addressProvider, child) {
          // Show shimmer while loading
          if (addressProvider.addressState == LoadingState.loading) {
            return const AddressListShimmer();
          }
          // Show error state
          else if (addressProvider.addressState == LoadingState.error) {
            return Center(
              child: FadeIn(
                duration: const Duration(milliseconds: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${addressProvider.addressError}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        addressProvider.fetchAddresses();
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text('try_again'.tr(context)),
                    ),
                  ],
                ),
              ),
            );
          }
          // Show empty state
          else if (addressProvider.addresses.isEmpty) {
            return FadeIn(
              duration: const Duration(milliseconds: 500),
              child: EmptyAddressWidget(
                onAddAddress: () => _navigateToAddAddress(context),
              ),
            );
          }

          // Show address list
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: addressProvider.addresses.length,
                  itemBuilder: (context, index) {
                    final address = addressProvider.addresses[index];
                    return AddressItem(
                      address: address,
                      isDefault: address.isDefault,
                      onEdit: () => _navigateToEditAddress(context, address.id),
                      onDelete: () => _showDeleteConfirmation(context, address.id),
                      onSetDefault: () => _handleSetDefault(address.id),
                      onSelect: widget.isSelectable 
                        ? () => Navigator.pop(context, address)
                        : null,
                    );
                  },
                ),
              ),
              _buildAddNewAddressButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddNewAddressButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () => _navigateToAddAddress(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFB0A88E),
            borderRadius: BorderRadius.circular(0),
          ),
          child: Center(
            child: Text(
              'add_new_address'.tr(context),
              style: context.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFamily: GoogleFonts.playfairDisplay().fontFamily,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAddAddress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditAddressScreen()),
    ).then((_) {
      // Refresh the address list when returning from add screen
      context.read<AddressProvider>().fetchAddresses();
    });
  }

  void _navigateToEditAddress(BuildContext context, int addressId) {
    final addressProvider = context.read<AddressProvider>();
    final address = addressProvider.addresses.firstWhere(
      (addr) => addr.id == addressId,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditAddressScreen(address: address),
      ),
    ).then((_) {
      // Refresh the address list when returning from edit screen
      addressProvider.fetchAddresses();
    });
  }

  void _showDeleteConfirmation(BuildContext context, int addressId) {
    showCustomConfirmationDialog(
      context: context,
      title: 'delete_address'.tr(context),
      message: 'delete_address_confirmation'.tr(context),
      confirmText: 'delete'.tr(context),
      cancelText: 'cancel'.tr(context),
      confirmButtonColor: AppTheme.errorColor,
      icon: Icons.delete_outline,
      onConfirm: () {
        context.read<AddressProvider>().deleteAddress(addressId);
      },
    );
  }
}
