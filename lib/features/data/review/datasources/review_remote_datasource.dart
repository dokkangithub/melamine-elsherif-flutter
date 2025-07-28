import 'package:melamine_elsherif/core/utils/constants/app_strings.dart';

import '../../../../core/api/api_provider.dart';
import '../../../../core/utils/constants/app_endpoints.dart';
import '../models/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<ReviewResponseModel> getProductReviews(int productId, {int page = 1});

  Future<Map<String, dynamic>> submitReview(int productId, double rating, String comment);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final ApiProvider apiProvider;

  ReviewRemoteDataSourceImpl(this.apiProvider);

  @override
  Future<ReviewResponseModel> getProductReviews(
      int productId, {
        int page = 1,
      }) async {
    final response = await apiProvider.get(
      '${LaravelApiEndPoint.productReviews}$productId?page=$page',
    );

    if (response.data != null) {
      return ReviewResponseModel.fromJson(response.data);
    }
    throw Exception('Failed to fetch reviews');
  }

  @override
  Future<Map<String, dynamic>> submitReview(
      int productId,
      double rating,
      String comment,
      ) async {
    final Map<String, dynamic> body = {
      'product_id': productId,
      'user_id': AppStrings.userId,
      'rating': rating.toString(),
      'comment': comment,
    };
    final response = await apiProvider.post(
      LaravelApiEndPoint.submitReview,
      data: body,
    );

    // Return the full response data including result and message
    return {
      'result': response.data['result'] ?? false,
      'message': response.data['message'] ?? 'Unknown error occurred',
    };
  }
}