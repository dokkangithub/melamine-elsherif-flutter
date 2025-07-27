import '../entities/set_product_details.dart';
import '../entities/set_products_response.dart';

abstract class SetProductsRepository {
  Future<SetProductsResponse> getSetProducts({int page = 1, bool needUpdate = false});
  Future<SetProductDetailsEntity> getSetProductDetails({required String slug});
  Future<CalculatePriceResponseEntity> calculatePrice({required CalculatePriceRequest request});
}