import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetBrandProductsUseCase {
  final ProductRepository productRepository;

  GetBrandProductsUseCase(this.productRepository);

  Future<ProductsResponse> call(int id, int page, {String? name, bool needUpdate = false}) async {
    return await productRepository.getBrandProducts(id, page, name: name,needUpdate: needUpdate);
  }
}