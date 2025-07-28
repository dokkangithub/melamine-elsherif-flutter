import 'package:flutter/material.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../domain/review/entities/review.dart';
import '../../../domain/review/usecases/get_product_reviews_use_case.dart';
import '../../../domain/review/usecases/submit_review_use_case.dart';

class ReviewProvider extends ChangeNotifier {
  final GetProductReviewsUseCase getProductReviews;
  final SubmitReviewUseCase submitReview;

  ReviewProvider({
    required this.getProductReviews,
    required this.submitReview,
  });

  List<Review> reviews = [];
  LoadingState reviewState = LoadingState.loading;
  String reviewError = '';
  int page = 1;
  int totalReviews = 0;
  bool isLoadingMore = false;

  Future<void> fetchReviews(int productId) async {
    try {
      reviewState = LoadingState.loading;
      notifyListeners();

      final response = await getProductReviews(productId, page: page);
      reviews = response;
      reviewState = LoadingState.loaded;
    } catch (e) {
      reviewState = LoadingState.error;
      reviewError = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadMoreReviews(int productId) async {
    if (isLoadingMore || reviews.length >= totalReviews) return;

    try {
      isLoadingMore = true;
      notifyListeners();

      page++;
      final moreReviews = await getProductReviews(productId, page: page);
      reviews.addAll(moreReviews);
    } catch (e) {
      reviewError = e.toString();
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> submitNewReview(int productId, double rating, String comment) async {
    try {
      reviewState = LoadingState.loading;
      notifyListeners();

      final result = await submitReview(productId, rating, comment);
      if (result['result'] == true) {
        await fetchReviews(productId);
      }
      return result;
    } catch (e) {
      reviewError = e.toString();
      return {
        'result': false,
        'message': 'An error occurred while submitting review',
      };
    } finally {
      reviewState = LoadingState.loaded;
      notifyListeners();
    }
  }
}