import '../entities/set_products_response.dart';

abstract class SetProductsRepository {
  Future<SetProductsResponse> getSetProducts({int page = 1});
}