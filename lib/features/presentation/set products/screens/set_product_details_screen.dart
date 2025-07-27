import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_loading.dart';
import 'package:provider/provider.dart';
import '../../../../../core/utils/enums/loading_state.dart';
import '../../../../../core/utils/widgets/custom_back_button.dart';
import '../../../../../features/domain/set products/entities/set_product_details.dart';
import '../controller/set_product_provider.dart';
import '../widgets/set_product_details_shimmer.dart';

class SetProductDetailsScreen extends StatefulWidget {
  final String slug;

  const SetProductDetailsScreen({
    super.key,
    required this.slug,
  });

  @override
  _SetProductDetailsScreenState createState() => _SetProductDetailsScreenState();
}

class _SetProductDetailsScreenState extends State<SetProductDetailsScreen>
    with TickerProviderStateMixin {
  Map<int, int> selectedQuantities = {};
  bool isDescriptionExpanded = false;
  bool isFullSet = true; // Default to full set
  late AnimationController _descriptionController;
  late AnimationController _priceAnimationController;
  late Animation<double> _descriptionAnimation;
  late Animation<double> _priceAnimation;

  @override
  void initState() {
    super.initState();
    _descriptionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _priceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _descriptionAnimation = CurvedAnimation(
      parent: _descriptionController,
      curve: Curves.easeInOut,
    );
    _priceAnimation = CurvedAnimation(
      parent: _priceAnimationController,
      curve: Curves.easeInOut,
    );

    // Reset state when entering the screen
    _resetScreenState();

    Future.microtask(() {
      final provider = Provider.of<SetProductsProvider>(context, listen: false);
      provider.getSetProductDetails(slug: widget.slug);
    });
  }

  void _resetScreenState() {
    selectedQuantities.clear();
    isDescriptionExpanded = false;
    isFullSet = true;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _priceAnimationController.dispose();
    final provider = Provider.of<SetProductsProvider>(context, listen: false);
    provider.clearSetProductDetails();
    provider.clearCalculatedPrice();
    super.dispose();
  }

  void _toggleDescription() {
    setState(() {
      isDescriptionExpanded = !isDescriptionExpanded;
      if (isDescriptionExpanded) {
        _descriptionController.forward();
      } else {
        _descriptionController.reverse();
      }
    });
  }

  void _toggleSetType(bool fullSet,SetProductsProvider provider) {
    if (isFullSet != fullSet) {
      setState(() {
        isFullSet = fullSet;
        if (!fullSet) {
          // Reset quantities to initial values for custom set
          _resetQuantitiesToInitial();
          // Calculate initial price for custom set
        } else {
          // Clear calculated price when switching to full set
          final provider = Provider.of<SetProductsProvider>(context, listen: false);
          provider.clearCalculatedPrice();
        }
      });
      _calculatePrice(provider);
      _priceAnimationController.forward().then((_) {
        _priceAnimationController.reverse();
      });
    }
  }

  void _resetQuantitiesToInitial() {
    final provider = Provider.of<SetProductsProvider>(context, listen: false);
    if (provider.setProductDetails != null) {
      selectedQuantities.clear();
      for (final component in provider.setProductDetails!.components) {
        selectedQuantities[component.id!] = component.initialQuantity ?? 1;
      }
      // Clear any previous calculated price when resetting
      provider.clearCalculatedPrice();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SetProductsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: _buildBody(provider),
          bottomNavigationBar: provider.setProductDetailsState == LoadingState.loaded &&
              provider.setProductDetails != null
              ? _buildBottomBar(context, provider)
              : null,
        );
      },
    );
  }



  Widget _buildProductHeader(SetProductDetailsData product) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight / 2.3; // 1/3 of screen height

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image with back button stack
        Stack(
          children: [
            CustomImage(
              imageUrl: product.thumbnailImage ?? '',
              height: imageHeight,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            // Back button positioned at top-left with safe area padding
            Positioned(
              top: MediaQuery.of(context).padding.top + 8, // Account for status bar
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 24,
                  ),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Product name
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            product.name ?? '',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Price section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Consumer<SetProductsProvider>(
            builder: (context, priceProvider, child) {
              String displayPrice;
              String? originalPrice;
              bool isLoading = false;

              if (isFullSet) {
                displayPrice = product.hasDiscount == true
                    ? product.discountedPrice ?? '${product.fullSetPrice} EGP'
                    : '${product.fullSetPrice} EGP';
                originalPrice = product.hasDiscount == true ? '${product.fullSetPrice} EGP' : null;
              } else {
                isLoading = priceProvider.calculatePriceState == LoadingState.loading;
                displayPrice = priceProvider.calculatedPrice != null
                    ? '${priceProvider.calculatedPrice!.totalPrice} EGP'
                    : (product.discountedPrice ?? '${product.minimumCustomPrice ?? 0} EGP');
                originalPrice = null;
              }

              return AnimatedBuilder(
                animation: _priceAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_priceAnimation.value * 0.1),
                    child: Row(
                      children: [
                        if (isLoading)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CustomLoadingWidget()
                          )
                        else
                          Text(
                            displayPrice,
                            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        const SizedBox(width: 12),
                        if (!isLoading && originalPrice != null)
                          Text(
                            originalPrice,
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: AppTheme.darkDividerColor,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

// Also update your _buildBody method to remove top padding:
  Widget _buildBody(SetProductsProvider provider) {
    if (provider.setProductDetailsState == LoadingState.loading) {
      return const SetProductDetailsShimmer();
    }

    if (provider.setProductDetailsState == LoadingState.error) {
      return Center(
        child: FadeIn(
          duration: const Duration(milliseconds: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(provider.setProductDetailsError),
              const SizedBox(height: 16),
              CustomButton(
                onPressed: () {
                  provider.getSetProductDetails(slug: widget.slug);
                },
                child: Text('retry'.tr(context)),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.setProductDetails == null) {
      return Center(
        child: Text('no_data_found'.tr(context)),
      );
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductHeader(provider.setProductDetails!),
            const SizedBox(height: 24),
            // Add padding to the rest of the content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductDescription(provider.setProductDetails!),
                  const SizedBox(height: 24),
                  _buildSetTypeSelector(provider),
                  const SizedBox(height: 24),
                  _buildComponentsList(provider.setProductDetails!, provider),
                  const SizedBox(height: 24),
                  _buildSelectedComponentsSummary(provider.setProductDetails!),
                  const SizedBox(height: 24),
                  _buildReviewsSection(provider.setProductDetails!),
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDescription(SetProductDetailsData product) {
    if (product.description == null || product.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _toggleDescription,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'description'.tr(context),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AnimatedRotation(
                  turns: isDescriptionExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.keyboard_arrow_down),
                ),
              ],
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: isDescriptionExpanded ? null : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isDescriptionExpanded ? 1.0 : 0.0,
            child: Container(
              padding: const EdgeInsets.only(top: 8),
              child: Html(
                data: product.description!,
                style: {
                  "body": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    fontSize: FontSize(16.0),
                    lineHeight: const LineHeight(1.5),
                    color: AppTheme.darkDividerColor,
                    fontFamily: Theme.of(context).textTheme.bodyLarge!.fontFamily,
                  ),
                  "p": Style(
                    margin: Margins.only(bottom: 12.0),
                    fontSize: FontSize(16.0),
                    lineHeight: const LineHeight(1.5),
                    color: AppTheme.darkDividerColor,
                  ),
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSetTypeSelector(SetProductsProvider provider) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: AppTheme.darkDividerColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _toggleSetType(true,provider),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isFullSet ? AppTheme.primaryColor : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(0),
                    bottomLeft: Radius.circular(0),
                  ),
                ),
                child: Text(
                  'full_set'.tr(context),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: isFullSet ? Colors.white : AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _toggleSetType(false,provider),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: !isFullSet ? AppTheme.primaryColor : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                ),
                child: Text(
                  'custom_set'.tr(context),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: !isFullSet ? Colors.white : AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentsList(SetProductDetailsData product, SetProductsProvider provider) {
    if (product.components.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'components'.tr(context),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: product.components.length,
          itemBuilder: (context, index) {
            final component = product.components[index];
            return _buildComponentCard(component, provider);
          },
        ),
      ],
    );
  }

  Widget _buildComponentCard(Component component, SetProductsProvider provider) {
    final int currentQuantity = selectedQuantities[component.id] ?? (component.initialQuantity ?? 1);
    final int minQty = component.minQuantity ?? 1;
    final int maxQty = component.maxQuantity ?? 99;
    final bool isEnabled = !isFullSet;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isEnabled ? 1.0 : 0.6,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        elevation: isEnabled ? 3 : 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomImage(
                    imageUrl: component.thumbnailImage ?? '',
                    height: 80,
                    width: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          component.name ?? '',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isEnabled ? null : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (component.isRequired == true)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(0),
                            ),
                            child: Text(
                              'required'.tr(context),
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          component.discountedPrice ?? '',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: isEnabled ? AppTheme.primaryColor : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'quantity'.tr(context),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isEnabled ? null : Colors.grey,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isEnabled ? AppTheme.darkDividerColor : Colors.grey.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.zero, // no radius
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: isEnabled && currentQuantity > minQty
                              ? () {
                            setState(() {
                              selectedQuantities[component.id!] = currentQuantity - 1;
                            });
                            _calculatePrice(provider);
                          }
                              : null,
                          child: Container(
                            color: Colors.transparent,
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.remove,
                              color: isEnabled ? null : Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: const BoxDecoration(
                            border: Border.symmetric(
                              vertical: BorderSide(width: 0.5, color: Colors.grey),
                            ),
                          ),
                          child: Text(
                            currentQuantity.toString(),
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isEnabled ? null : Colors.grey,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: isEnabled && currentQuantity < maxQty
                              ? () {
                            setState(() {
                              selectedQuantities[component.id!] = currentQuantity + 1;
                            });
                            _calculatePrice(provider);
                          }
                              : null,
                          child: Container(
                            color: Colors.transparent,
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.add,
                              color: isEnabled ? null : Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedComponentsSummary(SetProductDetailsData product) {
    if (isFullSet) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'full_set_components'.tr(context),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...product.components.map((component) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${component.name} (${component.initialQuantity ?? 1}x)',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ),
        ),
      );
    }

    final selectedComponents = product.components.where((component) {
      final quantity = selectedQuantities[component.id] ?? (component.initialQuantity ?? 1);
      return quantity > 0;
    }).toList();

    if (selectedComponents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'selected_components'.tr(context),
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...selectedComponents.map((component) {
              final quantity = selectedQuantities[component.id] ?? (component.initialQuantity ?? 1);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${component.name} (${quantity}x)',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Text(
                      '${(component.calculablePrice ?? 0) * quantity} EGP',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection(SetProductDetailsData product) {
    if (product.reviews.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'reviews'.tr(context),
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${product.reviewCount ?? product.reviews.length}',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: product.reviews.length,
          itemBuilder: (context, index) {
            final review = product.reviews[index];
            return Card(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          child: Text(
                            (review.userName ?? 'U').substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.userName ?? 'Anonymous',
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  ...List.generate(5, (i) => Icon(
                                    i < (review.rating ?? 0) ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 16,
                                  )),
                                  const SizedBox(width: 8),
                                  Text(
                                    review.time ?? '',
                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (review.comment != null && review.comment!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        review.comment!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, SetProductsProvider provider) {
    return Consumer<SetProductsProvider>(
      builder: (context, priceProvider, child) {
        String displayPrice;
        bool isLoading = false;

        if (isFullSet) {
          displayPrice = provider.setProductDetails!.hasDiscount == true
              ? provider.setProductDetails!.discountedPrice ?? '${provider.setProductDetails!.fullSetPrice} EGP'
              : '${provider.setProductDetails!.fullSetPrice} EGP';
        } else {
          isLoading = priceProvider.calculatePriceState == LoadingState.loading;
          displayPrice = priceProvider.calculatedPrice != null
              ? '${priceProvider.calculatedPrice!.totalPrice} EGP'
              : '${provider.setProductDetails!.minimumCustomPrice ?? 0} EGP';
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CustomLoadingWidget()
                )
              else
                Text(
                  displayPrice,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    // TODO: Implement add to cart functionality
                  },
                  child: Text('add_to_cart'.tr(context),textAlign: TextAlign.center,style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.bold,
                  ),),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  void _calculatePrice(SetProductsProvider provider) {
    final components = <ComponentRequest>[];

    for (final component in provider.setProductDetails!.components) {
      final quantity = selectedQuantities[component.id] ?? (component.initialQuantity ?? 1);
      components.add(
        ComponentRequest(
          productId: component.id!,
          quantity: quantity,
        ),
      );
    }

    final request = CalculatePriceRequest(
      productId: provider.setProductDetails!.id!,
      components: components,
    );

    provider.calculatePrice(request: request);
  }

}