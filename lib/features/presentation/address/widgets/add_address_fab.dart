import 'package:flutter/material.dart';

class AddAddressFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const AddAddressFAB({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton(
        onPressed: onPressed,
        child: const Icon(Icons.add),
      ),
    );
  }
}
