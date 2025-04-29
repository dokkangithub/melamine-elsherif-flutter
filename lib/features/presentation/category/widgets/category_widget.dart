import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:melamine_elsherif/core/config/app_config.dart/app_config.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_form_field.dart';
import 'package:melamine_elsherif/features/domain/category/entities/category.dart';
import 'category_card_widget.dart';

class CategoryWidget extends StatefulWidget {
  final List<Category> categories;

  const CategoryWidget({super.key, required this.categories});

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: AppTheme.primaryColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return Center(child: Text('no_categories_available'.tr(context)));
    }

    return Scaffold(
      body: Column(
        spacing: 15,
        children: [
          Stack(
            children: [
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withValues(alpha: 0.95),
                      ],
                    )
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    spacing: 6,
                    children: [
                      const SizedBox(height: 10),
                      CustomImage(
                        assetPath: AppSvgs.category_star,
                      ),
                      Text(
                        AppConfig().appName.toUpperCase(),
                        style: context.displayMedium?.copyWith(color: AppTheme.white),
                      ),
                      Text(
                        'ancient_beauty_rituals'.tr(context),
                        style: context.titleMedium?.copyWith(color: AppTheme.lightDividerColor),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: (){
                          AppRoutes.navigateTo(context, AppRoutes.searchScreen);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            spacing: 10,
                            children: [
                              CustomImage(
                                assetPath: AppSvgs.category_search_icon,
                              ),
                              Text(
                                'search_skin_care_products'.tr(context),
                                style: context.bodySmall?.copyWith(color: AppTheme.primaryColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 50,
                right: 50,
                child: Opacity(
                  opacity: 0.2,
                  child: CustomImage(
                    assetPath: AppSvgs.category_1,
                  ),
                ),
              ),
              Positioned(
                top: 50,
                right: 50,
                child: Opacity(
                  opacity: 0.2,
                  child: CustomImage(
                    assetPath: AppSvgs.category_1,
                  ),
                ),
              ),
              Positioned(
                top: 30,
                left: 30,
                child: Opacity(
                  opacity: 0.2,
                  child: CustomImage(
                    assetPath: AppSvgs.category_2,
                  ),
                ),
              ),
              Positioned(
                top: 50,
                right: 100,
                child: Opacity(
                  opacity: 0.2,
                  child: CustomImage(
                    assetPath: AppSvgs.category_3,
                  ),
                ),
              ),
              Positioned(
                top: 110,
                left: 20,
                child: Opacity(
                  opacity: 0.2,
                  child: CustomImage(
                    assetPath: AppSvgs.category_4,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1,
                ),
                itemCount: widget.categories.length,
                itemBuilder: (context, index) {
                  final category = widget.categories[index];
                  return CategoryCardInCategoryScreen(
                    category: category,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}