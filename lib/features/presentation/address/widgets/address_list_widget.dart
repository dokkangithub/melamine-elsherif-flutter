import 'package:flutter/material.dart';
import '../../../domain/address/entities/address.dart';
import 'address_item_widget.dart';

class AddressListWidget extends StatelessWidget {
  final List<Address> addresses;
  final bool isSelectable;
  final Function(int) onEdit;
  final Function(int) onDelete;
  final Function(int) onSetDefault;
  final Function(Address)? onSelect;

  const AddressListWidget({
    super.key,
    required this.addresses,
    this.isSelectable = false,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: addresses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final address = addresses[index];
        return AddressItemWidget(
          address: address,
          isSelectable: isSelectable,
          onEdit: () => onEdit(address.id),
          onDelete: () => onDelete(address.id),
          index: index,
          onSetDefault: () => onSetDefault(address.id),
          onSelect: isSelectable && onSelect != null
              ? () => onSelect!(address)
              : null,
        );
      },
    );
  }
}
