import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetFlashDealProductsUseCase {
  final ProductRepository productRepository;

  GetFlashDealProductsUseCase(this.productRepository);

  Future<ProductsResponse> call({bool needUpdate = false}) async {
    return await productRepository.getFlashDealProducts(needUpdate: needUpdate);
  }
}
