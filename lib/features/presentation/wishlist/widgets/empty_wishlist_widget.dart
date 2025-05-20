import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
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
          Lottie.asset(AppAnimations.emptyWishlist,fit: BoxFit.contain),
          Text(
            'wishlist_empty_message'.tr(context),
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          CustomButton(
            onPressed: () {
              Provider.of<LayoutProvider>(context,listen: false).currentIndex=0;
            },
            isGradient: true,
            child: Text('browse_products'.tr(context),style: context.titleSmall!.copyWith(color: AppTheme.white,fontWeight: FontWeight.w700),),
          ),
        ],
      ),
    );
  }
}
