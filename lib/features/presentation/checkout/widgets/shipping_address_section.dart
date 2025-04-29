import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import '../../../../core/utils/constants/app_strings.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../domain/address/entities/address.dart';
import 'geust_address_form.dart';

class ShippingAddressSection extends StatelessWidget {
  final Address? selectedAddress;
  final List<Address> addresses;
  final Function(Address) onAddressSelected;
  final VoidCallback onChangePressed;
  final Function(int) onEditPressed;
  final bool isLoading; // Add a loading state

  const ShippingAddressSection({
    super.key,
    required this.selectedAddress,
    required this.addresses,
    required this.onAddressSelected,
    required this.onChangePressed,
    required this.onEditPressed,
    this.isLoading = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    // Check if user is guest
    final isGuest = AppStrings.token == null;

    // Find the default address
    final defaultAddress = addresses.where((address) => address.isDefault).firstOrNull;

    // If there's a default address and selectedAddress is not the default, select it
    if (defaultAddress != null && selectedAddress?.id != defaultAddress.id && !isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onAddressSelected(defaultAddress);
      });
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
              Text(
                'shipping_to'.tr(context),
                style: context.headlineSmall?.copyWith(color: AppTheme.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (isLoading)
            _buildShimmerEffect(context)
          else if (isGuest && selectedAddress == null)
            _buildGuestAddressPrompt(context)
          else if (addresses.isEmpty && !isGuest)
              _buildNoAddressWidget(context)
            else if (isGuest && selectedAddress != null)
                _buildGuestAddressItem(context, selectedAddress!)
              else
                Column(
                  children: [
                    if (defaultAddress != null)
                      _buildAddressItem(
                        context,
                        defaultAddress,
                        selectedAddress?.id == defaultAddress.id,
                        isGuest,
                      ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 30,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestAddressPrompt(BuildContext context) {
    return Center(
      child: Card(
        elevation: 2,
        shadowColor: AppTheme.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'enter_shipping_address'.tr(context),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _navigateToGuestAddressForm(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('add_address'.tr(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestAddressItem(BuildContext context, Address address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shadowColor: AppTheme.primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              address.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              address.phone,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            Text(
              address.address,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            Text(
              '${address.cityName}, ${address.stateName}, ${address.postalCode}',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _navigateToGuestAddressForm(context),
                icon: const Icon(Icons.edit, size: 16),
                label: Text('edit'.tr(context)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToGuestAddressForm(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuestAddressFormScreen(
          initialAddress: selectedAddress,
        ),
      ),
    );

    if (result != null && result is Address) {
      onAddressSelected(result);
    }
  }

  Widget _buildNoAddressWidget(BuildContext context) {
    return Center(
      child: Card(
        elevation: 2,
        shadowColor: AppTheme.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'no_addresses'.tr(context),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onChangePressed,
                child: Text('add_new_address'.tr(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressItem(
      BuildContext context,
      Address address,
      bool isSelected,
      bool isGuest,
      ) {
    return Card(
      elevation: 2,
      shadowColor: AppTheme.primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<int>(
              value: address.id,
              groupValue: selectedAddress?.id,
              onChanged: (value) => onAddressSelected(address),
              activeColor: AppTheme.primaryColor,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'default_address'.tr(context),
                    style: context.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.phone,
                    style: context.titleSmall,
                  ),
                  Text(
                    address.address,
                    style: context.titleSmall,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                if (isGuest) {
                  _navigateToGuestAddressForm(context);
                } else {
                  onChangePressed();
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: Text(
                isGuest && selectedAddress == null
                    ? 'add_address'.tr(context)
                    : 'change'.tr(context),
                style: context.titleMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}