import '../../../../core/api/api_provider.dart';
import '../../../../core/utils/constants/app_endpoints.dart';
import '../models/set_products_model.dart';
import '../models/set_product_details_model.dart';

abstract class SetProductsRemoteDataSource {
  Future<SetProductsModel> getSetProducts({int page = 1});
  Future<SetProductDetailsModel> getSetProductDetails({required String slug});
  Future<CalculatePriceResponseModel> calculatePrice({required CalculatePriceRequestModel request});
}

class SetProductsRemoteDataSourceImpl implements SetProductsRemoteDataSource {
  final ApiProvider apiProvider;

  SetProductsRemoteDataSourceImpl(this.apiProvider);

  @override
  Future<SetProductsModel> getSetProducts({int page = 1}) async {
    final response = await apiProvider.get(
      '${LaravelApiEndPoint.setProducts}?page=$page',
    );

    if (response.data != null) {
      return SetProductsModel.fromJson(response.data);
    }
    throw Exception('Invalid set products response');
  }

  @override
  Future<SetProductDetailsModel> getSetProductDetails({required String slug}) async {
    final response = await apiProvider.get(
      '${LaravelApiEndPoint.setProducts}/$slug/details',
    );

    if (response.data != null) {
      return SetProductDetailsModel.fromJson(response.data);
    }
    throw Exception('Invalid set product details response');
  }

  @override
  Future<CalculatePriceResponseModel> calculatePrice({required CalculatePriceRequestModel request}) async {
    final response = await apiProvider.post(
      '${LaravelApiEndPoint.setProducts}/calculate-price',
      data: request.toJson(),
    );

    if (response.data != null) {
      return CalculatePriceResponseModel.fromJson(response.data);
    }
    throw Exception('Invalid calculate price response');
  }
}