import 'package:flutter/material.dart';
import 'package:melamine_elsherif/features/presentation/main%20layout/screens/main_layout_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../main layout/controller/layout_provider.dart';

class EmptyWishlistWidget extends StatelessWidget {
  const EmptyWishlistWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'wishlist_empty'.tr(context),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'wishlist_empty_message'.tr(context),
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Provider.of<LayoutProvider>(context,listen: false).currentIndex=0;
            },
            child: Text('browse_products'.tr(context)),
          ),
        ],
      ),
    );
  }
}
