import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetFlashDealProductsUseCase {
  final ProductRepository productRepository;

  GetFlashDealProductsUseCase(this.productRepository);

  Future<ProductsResponse> call(int id,{bool needUpdate = false}) async {
    return await productRepository.getFlashDealProducts(id,needUpdate: needUpdate);
  }
}
