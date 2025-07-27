import '../repositories/set_products_repository.dart';

class AddFullSetToCartUseCase {
  final SetProductsRepository repository;

  AddFullSetToCartUseCase(this.repository);

  Future<Map<String, dynamic>> call({required int productId, required int quantity}) async {
    return await repository.addFullSetToCart(
      productId: productId,
      quantity: quantity,
    );
  }
}