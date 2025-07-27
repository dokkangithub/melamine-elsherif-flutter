import '../entities/set_product_details.dart';
import '../entities/set_products_response.dart';

abstract class SetProductsRepository {
  Future<SetProductsResponse> getSetProducts({int page = 1, bool needUpdate = false});
  Future<SetProductDetailsEntity> getSetProductDetails({required String slug});
  Future<CalculatePriceResponseEntity> calculatePrice({required CalculatePriceRequest request});
  Future<Map<String, dynamic>> addFullSetToCart({required int productId, required int quantity});
  Future<Map<String, dynamic>> addCustomSetToCart({required int productId, required int quantity, required List<ComponentRequest> components});
}