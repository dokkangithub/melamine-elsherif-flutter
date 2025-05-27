import 'package:flutter/material.dart';

class CustomConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final IconData? icon;
  final Color confirmButtonColor;
  final Color cancelButtonColor;
  final Color confirmTextColor;
  final Color cancelTextColor;

  const CustomConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    this.cancelText = 'Cancel',
    this.confirmText = 'Remove',
    required this.onCancel,
    required this.onConfirm,
    this.icon = Icons.delete_outline,
    this.confirmButtonColor = const Color(0xFFCB997E),
    this.cancelButtonColor = Colors.transparent,
    this.confirmTextColor = Colors.white,
    this.cancelTextColor = Colors.black54,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 28,
              color: Colors.black54,
            ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    backgroundColor: cancelButtonColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Text(
                    cancelText,
                    style: TextStyle(
                      color: cancelTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton(
                  onPressed: onConfirm,
                  style: TextButton.styleFrom(
                    backgroundColor: confirmButtonColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    confirmText,
                    style: TextStyle(
                      color: confirmTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper function to show the dialog easily
Future<bool?> showCustomConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String cancelText = 'Cancel',
  String confirmText = 'Remove',
  required VoidCallback onConfirm,
  IconData? icon = Icons.delete_outline,
  Color confirmButtonColor = const Color(0xFFCB997E),
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return CustomConfirmationDialog(
        title: title,
        message: message,
        cancelText: cancelText,
        confirmText: confirmText,
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () {
          onConfirm();
          Navigator.of(context).pop(true);
        },
        icon: icon,
        confirmButtonColor: confirmButtonColor,
      );
    },
  );
} 