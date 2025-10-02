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
  Future<SetProductsModel> getRelatedSetProducts({required int productId});
  Future<CalculatePriceResponseModel> calculatePrice({
    required CalculatePriceRequestModel request,
  });
  Future<Map<String, dynamic>> addFullSetToCart({
    required int productId,
    required int quantity,
  });
  Future<Map<String, dynamic>> addCustomSetToCart({
    required int productId,
    required int quantity,
    required List<ComponentRequestModel> components,
  });
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
  Future<SetProductDetailsModel> getSetProductDetails({
    required String slug,
  }) async {
    final response = await apiProvider.get(
      '${LaravelApiEndPoint.setProducts}/$slug/details',
    );

    if (response.data != null) {
      return SetProductDetailsModel.fromJson(response.data);
    }
    throw Exception('Invalid set product details response');
  }

  @override
  Future<SetProductsModel> getRelatedSetProducts({
    required int productId,
  }) async {
    // First try to get related set products
    try {
      final response = await apiProvider.get(
        '${LaravelApiEndPoint.setProductsRelated}$productId',
      );

    if (response.data != null) {
      print('Related products API response type: ${response.data.runtimeType}');
      print('Related products API response: $response.data');
      
      // Handle the case where API returns a list directly
      if (response.data is List) {
        print('API returned a list, wrapping it...');
        // Wrap the list in the expected structure
        final wrappedData = {
          "success": true,
          "data": {
            "data": response.data,
            "current_page": 1,
            "last_page": 1,
            "total": (response.data as List).length,
            "per_page": (response.data as List).length,
            "next_page_url": null,
            "prev_page_url": null,
          }
        };
        print('Wrapped data: $wrappedData');
        return SetProductsModel.fromJson(wrappedData);
      } else if (response.data is Map<String, dynamic>) {
        print('API returned an object, checking structure...');
        final responseData = response.data as Map<String, dynamic>;
        
        // Check if the response has the expected nested structure
        if (responseData.containsKey('data') && 
            responseData['data'] is Map<String, dynamic> &&
            (responseData['data'] as Map<String, dynamic>).containsKey('data')) {
          print('API has nested data structure, using it directly...');
          try {
            return SetProductsModel.fromJson(responseData);
          } catch (e) {
            print('Error parsing nested data: $e');
            throw Exception('Failed to parse nested API response: $e');
          }
        } else if (responseData.containsKey('data') && responseData['data'] is List) {
          print('API has flat structure with data array, wrapping it...');
          // Wrap the flat structure in the expected format
          final dataList = responseData['data'] as List;
          final wrappedData = {
            "success": responseData["success"] ?? true,
            "data": {
              "data": dataList,
              "current_page": 1,
              "last_page": 1,
              "total": dataList.length,
              "per_page": dataList.length,
              "next_page_url": null,
              "prev_page_url": null,
            }
          };
          print('Wrapped data: $wrappedData');
          try {
            return SetProductsModel.fromJson(wrappedData);
          } catch (e) {
            print('Error parsing wrapped data: $e');
            throw Exception('Failed to parse API response: $e');
          }
        } else {
          print('API has unexpected structure, wrapping it...');
          // Wrap the entire response in the expected format
          final wrappedData = {
            "success": responseData["success"] ?? true,
            "data": {
              "data": responseData,
              "current_page": 1,
              "last_page": 1,
              "total": 1,
              "per_page": 1,
              "next_page_url": null,
              "prev_page_url": null,
            }
          };
          print('Wrapped data: $wrappedData');
          try {
            return SetProductsModel.fromJson(wrappedData);
          } catch (e) {
            print('Error parsing unexpected structure: $e');
            throw Exception('Failed to parse unexpected API response: $e');
          }
        }
      } else {
        print('Unexpected response type, throwing error...');
        throw Exception('Unexpected API response format');
      }
    }
    throw Exception('Invalid related set products response');
    } catch (e) {
      print('Error getting related set products: $e');
      // Fallback: get general set products instead
      print('Falling back to general set products...');
      try {
        final fallbackResponse = await apiProvider.get(
          '${LaravelApiEndPoint.setProducts}?page=1&limit=6',
        );
        
        if (fallbackResponse.data != null) {
          return SetProductsModel.fromJson(fallbackResponse.data);
        }
      } catch (fallbackError) {
        print('Fallback also failed: $fallbackError');
      }
      throw Exception('Failed to get related or fallback set products');
    }
  }

  @override
  Future<CalculatePriceResponseModel> calculatePrice({
    required CalculatePriceRequestModel request,
  }) async {
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
  Future<Map<String, dynamic>> addFullSetToCart({
    required int productId,
    required int quantity,
  }) async {
    final userParams = await _getUserParams();
    final response = await apiProvider.post(
      '/cart/add-full-set',
      data: {'product_id': productId, 'quantity': quantity, ...userParams},
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
    required List<ComponentRequestModel> components,
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
