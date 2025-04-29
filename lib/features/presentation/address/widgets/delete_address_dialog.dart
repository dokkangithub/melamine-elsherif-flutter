import 'package:flutter/material.dart';
import '../../../../core/utils/extension/translate_extension.dart';

class DeleteAddressDialog extends StatelessWidget {
  final VoidCallback onDelete;

  const DeleteAddressDialog({Key? key, required this.onDelete})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('delete_address'.tr(context)),
      content: Text('delete_address_confirmation'.tr(context)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr(context)),
        ),
        TextButton(
          onPressed: () {
            onDelete();
            Navigator.pop(context);
          },
          child: Text(
            'delete'.tr(context),
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
