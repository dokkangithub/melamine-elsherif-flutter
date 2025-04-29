import 'package:flutter/material.dart';
import '../../../../core/utils/extension/translate_extension.dart';

class AddressItemActions extends StatelessWidget {
  final bool isDefault;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;

  const AddressItemActions({
    super.key,
    required this.isDefault,
    this.onEdit,
    this.onDelete,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Edit button
            if (onEdit != null)
              Expanded(
                child: TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text('edit_address'.tr(context).split(' ')[0]),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),

            // Delete button
            if (onDelete != null)
              Expanded(
                child: TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18),
                  label: Text('delete'.tr(context)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),

            // Set as default button
            if (onSetDefault != null && !isDefault)
              Expanded(
                child: TextButton.icon(
                  onPressed: onSetDefault,
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: Text('default'.tr(context)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
