import 'dart:async';
import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/product%20cards/custom_product_card.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:provider/provider.dart';
import 'package:melamine_elsherif/core/utils/widgets/see_all_widget.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/utils/enums/loading_state.dart';
import 'package:melamine_elsherif/core/utils/enums/products_type.dart';
import 'package:melamine_elsherif/features/presentation/home/controller/home_provider.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/shimmer/new_products_shimmer.dart';
import 'package:melamine_elsherif/core/utils/product cards/custom_product_row.dart';
import 'package:melamine_elsherif/features/domain/product/entities/flash_deal.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';

class FlashDealsWidget extends StatelessWidget {
  const FlashDealsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        // Show shimmer while loading
        if (homeProvider.flashDealProductsState == LoadingState.loading) {
          return const NewProductsShimmer();
        }

        // Show error state
        if (homeProvider.flashDealProductsState == LoadingState.error) {
          return const SizedBox.shrink();
        }

        // Get flash deals data
        final deals = homeProvider.flashDeals;

        // Show empty state if no deals
        if (deals.isEmpty) {
          return const SizedBox.shrink();
        }

        // Create a list of sections, one for each flash deal
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              deals
                  .map((deal) => _buildFlashDealSection(context, deal))
                  .toList(),
        );
      },
    );
  }

  Widget _buildFlashDealSection(BuildContext context, FlashDeal deal) {
    // Filter published products
    final products = deal.products;

    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner image if available
        if (deal.banner.isNotEmpty &&
            !deal.banner.toString().contains('placeholder'))
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomImage(
                imageUrl: deal.banner,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

        // Row with title, countdown timer, and see all
        // Row(
        //   children: [
        //
        //     // Countdown timer
        //     FlashDealCountdown(endDate: deal.date),
        //     SeeAllWidget(
        //       title: deal.title,
        //       onTap: () {
        //         AppRoutes.navigateTo(
        //           context,
        //           AppRoutes.allProductsByTypeScreen,
        //           arguments: {
        //             'productType': ProductType.flashDeal,
        //             'title': deal.title,
        //           },
        //         );
        //       },
        //     ),
        //     const SizedBox(height: 10),
        //   ],
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              deal.title,

              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            Row(
              children: [

                InkWell(
                  onTap: () {
                    AppRoutes.navigateTo(
                      context,
                      AppRoutes.allProductsByTypeScreen,
                      arguments: {
                        'productType': ProductType.flashDeal,
                        'title': deal.title,
                      },
                    );
                  },
                  child: FlashDealCountdown(endDate: deal.date),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Products list
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder:
                (context, index) => ProductCard(
                  product: products[index],
                  isOutlinedAddToCart: true,
                ),
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}

class FlashDealCountdown extends StatefulWidget {
  final int endDate;

  const FlashDealCountdown({super.key, required this.endDate});

  @override
  State<FlashDealCountdown> createState() => _FlashDealCountdownState();
}

class _FlashDealCountdownState extends State<FlashDealCountdown> {
  late Timer _timer;
  late Duration _remainingTime;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _calculateRemainingTime() {
    final now = DateTime.now();
    final endDate = DateTime.fromMillisecondsSinceEpoch(widget.endDate * 1000);

    if (endDate.isAfter(now)) {
      _remainingTime = endDate.difference(now);
    } else {
      _remainingTime = Duration.zero;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        _calculateRemainingTime();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final hours = _remainingTime.inHours;
    final minutes = _remainingTime.inMinutes % 60;
    final seconds = _remainingTime.inSeconds % 60;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.access_time_rounded,
          size: 16,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 4),
        Text(
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: context.headlineSmall?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
