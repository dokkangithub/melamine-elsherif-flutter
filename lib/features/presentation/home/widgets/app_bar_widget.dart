import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/app_config.dart/app_config.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:provider/provider.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import '../../main layout/controller/layout_provider.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {

  const AppBarWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return AppBar(
      backgroundColor: AppTheme.white,
      elevation: 0,
      leadingWidth: double.infinity,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 15),
          CustomImage(
            assetPath: AppImages.home_logo,
            width: 110,
            height: 140,
            fit: BoxFit.cover,
          ),

        ],
      ),
      actions: [
        InkWell(
          child: CustomImage(
            assetPath: AppSvgs.search_icon,
          ),
          onTap: () {
            AppRoutes.navigateTo(context, AppRoutes.searchScreen);
          },
        ),
        SizedBox(width: 15),
        InkWell(
          child: CustomImage(
            assetPath: AppSvgs.cart_icon,
          ),
          onTap: () {
            Provider.of<LayoutProvider>(context,listen: false).currentIndex=3;
          },
        ),
        SizedBox(width: 15),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}