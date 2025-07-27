import '../entities/set_product_details.dart';
import '../repositories/set_products_repository.dart';

class AddCustomSetToCartUseCase {
  final SetProductsRepository repository;

  AddCustomSetToCartUseCase(this.repository);

  Future<Map<String, dynamic>> call({
    required int productId,
    required int quantity,
    required List<ComponentRequest> components
  }) async {
    return await repository.addCustomSetToCart(
      productId: productId,
      quantity: quantity,
      components: components,
    );
  }
}