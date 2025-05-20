import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../widgets/empty_wishlist_widget.dart';
import '../widgets/wishlist_widget.dart';
import '../widgets/shimmer/wishlist_screen_shimmer.dart';
import '../controller/wishlist_provider.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WishlistProvider>(
        builder: (context, provider, child) {
         if (provider.wishlistState == LoadingState.error) {
            return const SizedBox.shrink();
          } else {
            return WishlistWidget(provider: provider);
          }
        },
      ),
    );
  }
}
