import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/enums/loading_state.dart';
import '../../review/controller/reviews_provider.dart';
import '../../review/screens/products_review_screen.dart';

class ReviewsSectionWidget extends StatefulWidget {
  final int productId;
   ReviewsSectionWidget({super.key, required this.productId});

  @override
  State<ReviewsSectionWidget> createState() => _ReviewsSectionWidgetState();
}

class _ReviewsSectionWidgetState extends State<ReviewsSectionWidget> {
  double _rating = 0.0;

  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text('customer_reviews'.tr(context),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showReviewDialog(context, widget.productId),
                    child: Text('write_review'.tr(context)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Reviews
              if (reviewProvider.reviewState == LoadingState.loading)
                const Center(child: CircularProgressIndicator())
              else if (reviewProvider.reviews.isEmpty)
                 Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('no_reviews_yet_be'.tr(context)),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviewProvider.reviews.length > 3
                      ? 3  // Show only 3 reviews initially
                      : reviewProvider.reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviewProvider.reviews[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                review.avatar==''?const CustomImage(assetPath: '',height: 80,width: 80,): CircleAvatar(
                                  backgroundImage: NetworkImage(review.avatar),
                                  radius: 20,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review.userName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      review.time,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: review.rating,
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  itemCount: 5,
                                  itemSize: 16.0,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  review.rating.toString(),
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              review.comment,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              // See all reviews button
              if (reviewProvider.reviews.length > 3)
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Navigate to a separate screen with all reviews
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllReviewsScreen(productId: widget.productId),
                        ),
                      );
                    },
                    child: Text('See All ${reviewProvider.totalReviews} Reviews'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showReviewDialog(BuildContext context, int productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('write_review'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('rate_this_product_details'.tr(context)),
              const SizedBox(height: 8),
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  _rating = rating;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _reviewController,
                decoration:  InputDecoration(
                  labelText: 'your_review'.tr(context),
                  hintText: 'share_your_experience_with'.tr(context),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _reviewController.clear();
              _rating = 0.0;
            },
            child: Text('cancel'.tr(context)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_rating > 0 && _reviewController.text.isNotEmpty) {
                final success = await Provider.of<ReviewProvider>(context, listen: false)
                    .submitNewReview(productId, _rating, _reviewController.text);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text('review_submitted_successfully'.tr(context))),
                  );
                  Navigator.pop(context);
                  _reviewController.clear();
                  _rating = 0.0;
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('failed_to_submit_review'.tr(context))),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                    content: Text('please_rate_the_product'.tr(context)),
                  ),
                );
              }
            },
            child: Text('submit'.tr(context)),
          ),
        ],
      ),
    );
  }
}
