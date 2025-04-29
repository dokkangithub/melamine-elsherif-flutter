import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../controller/address_provider.dart';
import '../widgets/address_list_widget.dart';
import '../widgets/shimmer/address_list_shimmer.dart';
import '../widgets/empty_address_widget.dart';
import 'add_edit_address_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('my_addresses'.tr(context)), elevation: 0),
      body: Consumer<AddressProvider>(
        builder: (context, addressProvider, child) {
          // Show shimmer while loading
          if (addressProvider.addressState == LoadingState.loading) {
            return const AddressListShimmer();
          }
          // Show error state
          else if (addressProvider.addressState == LoadingState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${addressProvider.addressError}',
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
            );
          }
          // Show empty state
          else if (addressProvider.addresses.isEmpty) {
            return EmptyAddressWidget(
              onAddAddress: () => _navigateToAddAddress(context),
            );
          }

          // Show address list
          return Stack(
            children: [
              AddressListWidget(
                addresses: addressProvider.addresses,
                isSelectable: widget.isSelectable,
                onEdit:
                    (addressId) => _navigateToEditAddress(context, addressId),
                onDelete:
                    (addressId) => _showDeleteConfirmation(context, addressId),
                onSetDefault:
                    (addressId) =>
                        addressProvider.makeAddressDefault(addressId),
                onSelect:
                    widget.isSelectable
                        ? (address) => Navigator.pop(context, address)
                        : null,
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  onPressed: () => _navigateToAddAddress(context),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          );
        },
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
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('delete_address'.tr(context)),
            content: Text('delete_address_confirmation'.tr(context)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('cancel'.tr(context)),
              ),
              TextButton(
                onPressed: () {
                  context.read<AddressProvider>().deleteAddress(addressId);
                  Navigator.pop(context);
                },
                child: Text(
                  'delete'.tr(context),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
