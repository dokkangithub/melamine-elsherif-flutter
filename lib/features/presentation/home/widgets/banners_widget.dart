import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/shimmer/banner_shimmer_widget.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/widgets/custom_cached_image.dart';
import '../../slider/controller/provider.dart';

class SimpleBannerCarousel extends StatefulWidget {
  const SimpleBannerCarousel({super.key});

  @override
  State<SimpleBannerCarousel> createState() => _SimpleBannerCarouselState();
}

class _SimpleBannerCarouselState extends State<SimpleBannerCarousel> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSliders();
    });
  }

  void _loadSliders() {
    final sliderProvider = Provider.of<SliderProvider>(context, listen: false);
    sliderProvider.getSliders();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SliderProvider>(
      builder: (context, sliderProvider, child) {
        // Show loading state with dedicated shimmer
        if (sliderProvider.slidersState == SliderLoadingState.loading ||
            sliderProvider.slidersState == SliderLoadingState.initial) {
          return const BannerShimmer();
        }

        // Show error state
        if (sliderProvider.slidersState == SliderLoadingState.error) {
          return const SizedBox.shrink();
        }

        // Show loaded state
        final sliders = sliderProvider.slidersResponse?.data ?? [];
        if (sliders.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              CarouselSlider.builder(
                itemCount: sliders.length,
                options: CarouselOptions(
                  height: 150,
                  aspectRatio: 16 / 9,
                  viewportFraction: 1,
                  initialPage: 0,
                  enableInfiniteScroll: sliders.length > 1,
                  reverse: false,
                  autoPlay: sliders.length > 1,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                itemBuilder: (BuildContext context, int index, int realIndex) {
                  final slider = sliders[index];
                  final imageUrl = slider.photo ?? '';

                  return Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1), // Fixed from withValues
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () {},
                        child: CustomImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
              // if (sliders.length > 1) ...[
              //   const SizedBox(height: 12),
              //   Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: sliders.asMap().entries.map((entry) {
              //       return Container(
              //         width: 8.0,
              //         height: 8.0,
              //         margin: const EdgeInsets.symmetric(horizontal: 4.0),
              //         decoration: BoxDecoration(
              //           shape: BoxShape.circle,
              //           color: Theme.of(context).primaryColor.withOpacity(
              //             _currentIndex == entry.key ? 1.0 : 0.4,
              //           ), // Fixed from withValues
              //         ),
              //       );
              //     }).toList(),
              //   ),
              // ],
            ],
          ),
        );
      },
    );
  }
}