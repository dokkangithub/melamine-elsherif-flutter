import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import '../../../../core/utils/constants/app_strings.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../domain/address/entities/address.dart';
import '../../address/widgets/address_card.dart';
import 'geust_address_form.dart';

class ShippingAddressSection extends StatefulWidget {
  final Address? selectedAddress;
  final List<Address> addresses;
  final Function(Address) onAddressSelected;
  final VoidCallback onChangePressed;
  final Function(int) onEditPressed;
  final bool isLoading;

  const ShippingAddressSection({
    super.key,
    required this.selectedAddress,
    required this.addresses,
    required this.onAddressSelected,
    required this.onChangePressed,
    required this.onEditPressed,
    this.isLoading = false,
  });

  @override
  State<ShippingAddressSection> createState() => _ShippingAddressSectionState();
}

class _ShippingAddressSectionState extends State<ShippingAddressSection> {
  bool _initialSelectionDone = false;

  @override
  void didUpdateWidget(ShippingAddressSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If addresses loaded for the first time, select default
    if (oldWidget.addresses.isEmpty && 
        widget.addresses.isNotEmpty && 
        !_initialSelectionDone && 
        widget.selectedAddress == null) {
      _selectDefaultAddress();
    }
  }

  void _selectDefaultAddress() {
    final defaultAddress = widget.addresses
        .where((address) => address.isDefault)
        .firstOrNull;

    if (defaultAddress != null && 
        widget.selectedAddress?.id != defaultAddress.id &&
        !widget.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAddressSelected(defaultAddress);
        _initialSelectionDone = true;
      });
    } else if (widget.addresses.isNotEmpty && 
              widget.selectedAddress == null && 
              !widget.isLoading) {
      // If no default address, select the first one
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAddressSelected(widget.addresses.first);
        _initialSelectionDone = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = AppStrings.token == null;
    
    // Only auto-select default address on first load, not after user selection
    if (!_initialSelectionDone && widget.addresses.isNotEmpty && widget.selectedAddress == null) {
      _selectDefaultAddress();
    }

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Saved Addresses'.tr(context),
                style: context.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!widget.isLoading && (widget.addresses.isNotEmpty || widget.selectedAddress != null))
                TextButton(
                  onPressed: widget.onChangePressed,
                  child: Text(
                    isGuest ? 'Edit' : 'Change',
                    style: context.titleSmall!.copyWith(color: AppTheme.primaryColor,fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
          if (widget.isLoading)
            _buildShimmerEffect(context)
          else if ((isGuest && widget.selectedAddress == null) || 
                   (widget.addresses.isEmpty && !isGuest))
            _buildAddAddressPrompt(context, isGuest)
          else
            _buildAddressCards(context, isGuest),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect(BuildContext context) {
    return SizedBox(
      height: 130,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 2,
          itemBuilder: (context, index) => Container(
            width: 220,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddAddressPrompt(BuildContext context, bool isGuest) {
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'enter_shipping_address'.tr(context),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          CustomButton(
            onPressed: widget.onChangePressed,
            text: 'add_address'.tr(context),
            isGradient: true,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCards(BuildContext context, bool isGuest) {
    final displayAddresses = isGuest 
        ? (widget.selectedAddress != null ? [widget.selectedAddress!] : []) 
        : widget.addresses;
    
    if (displayAddresses.isEmpty) {
      return _buildAddAddressPrompt(context, isGuest);
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayAddresses.length,
        itemBuilder: (context, index) {
          final address = displayAddresses[index];
          final isSelected = widget.selectedAddress?.id == address.id;
          
          return AddressCard(
            address: address,
            isSelected: isSelected,
            userName: AppStrings.userName ?? 'John Doe',
            onTap: () {
              // When user manually selects an address, mark initial selection as done
              _initialSelectionDone = true;
              widget.onAddressSelected(address);
            },
            onEdit: () => isGuest 
                ? widget.onChangePressed() 
                : widget.onEditPressed(address.id),
          );
        },
      ),
    );
  }
}
