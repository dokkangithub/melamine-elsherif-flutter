import 'package:melamine_elsherif/core/utils/constants/app_strings.dart';
import '../../../../core/api/api_provider.dart';
import '../../../../core/utils/constants/app_endpoints.dart';
import '../../../../core/utils/local_storage/local_storage_keys.dart';
import '../../../../core/utils/local_storage/secure_storage.dart';
import '../models/set_products_model.dart';
import '../models/set_product_details_model.dart';

abstract class SetProductsRemoteDataSource {
  Future<SetProductsModel> getSetProducts({int page = 1});
  Future<SetProductDetailsModel> getSetProductDetails({required String slug});
  Future<CalculatePriceResponseModel> calculatePrice({required CalculatePriceRequestModel request});
  Future<Map<String, dynamic>> addFullSetToCart({required int productId, required int quantity});
  Future<Map<String, dynamic>> addCustomSetToCart({required int productId, required int quantity, required List<ComponentRequestModel> components});
}

class SetProductsRemoteDataSourceImpl implements SetProductsRemoteDataSource {
  final ApiProvider apiProvider;

  SetProductsRemoteDataSourceImpl(this.apiProvider);

  Future<Map<String, dynamic>> _getUserParams() async {
    return {
      if (AppStrings.userId == null && AppStrings.tempUserId != null)
        'temp_user_id': AppStrings.tempUserId,
      if (AppStrings.userId != null) 'user_id': AppStrings.userId.toString(),
    };
  }

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

  @override
  Future<Map<String, dynamic>> addFullSetToCart({required int productId, required int quantity}) async {
    final userParams = await _getUserParams();
    final response = await apiProvider.post(
      '/cart/add-full-set',
      data: {
        'product_id': productId,
        'quantity': quantity,
        ...userParams,
      },
    );

    // Check for temp_user_id and save it if provided
    if (response.data != null && response.data['temp_user_id'] != null) {
      await SecureStorage().save(
        LocalStorageKey.tempUserId,
        response.data['temp_user_id'],
      );
      // Update the static variable as well
      AppStrings.tempUserId = response.data['temp_user_id'];
    }

    return response.data;
  }

  @override
  Future<Map<String, dynamic>> addCustomSetToCart({
    required int productId,
    required int quantity,
    required List<ComponentRequestModel> components
  }) async {
    final userParams = await _getUserParams();
    final response = await apiProvider.post(
      '/cart/add-custom-set',
      data: {
        'product_id': productId,
        'quantity': quantity,
        'components': components.map((c) => c.toJson()).toList(),
        ...userParams,
      },
    );

    // Check for temp_user_id and save it if provided
    if (response.data != null && response.data['temp_user_id'] != null) {
      await SecureStorage().save(
        LocalStorageKey.tempUserId,
        response.data['temp_user_id'],
      );
      // Update the static variable as well
      AppStrings.tempUserId = response.data['temp_user_id'];
    }

    return response.data;
  }
}