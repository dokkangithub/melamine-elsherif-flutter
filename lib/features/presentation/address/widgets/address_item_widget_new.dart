import 'package:flutter/material.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../domain/address/entities/address.dart';
import 'address_item_actions.dart';
import 'address_item_details.dart';

class AddressItemWidget extends StatelessWidget {
  final Address address;
  final bool isSelectable;
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;
  final VoidCallback? onSelect;

  const AddressItemWidget({
    Key? key,
    required this.address,
    this.isSelectable = false,
    this.showActions = true,
    this.onEdit,
    this.onDelete,
    this.onSetDefault,
    this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            address.isDefault
                ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
                : BorderSide.none,
      ),
      child: InkWell(
        onTap: isSelectable ? onSelect : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address details section
              AddressItemDetails(address: address),

              // Action buttons section
              if (showActions) ...[
                const SizedBox(height: 16),
                AddressItemActions(
                  isDefault: address.isDefault,
                  onEdit: onEdit,
                  onDelete: onDelete,
                  onSetDefault: onSetDefault,
                ),
              ],

              // Select button for selectable mode
              if (isSelectable && !showActions) ...[
                const SizedBox(height: 16),
                const Divider(),
                Center(
                  child: ElevatedButton(
                    onPressed: onSelect,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text('use_this_address'.tr(context)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
