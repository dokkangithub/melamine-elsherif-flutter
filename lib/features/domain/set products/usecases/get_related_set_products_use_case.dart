import '../entities/set_products_response.dart';
import '../repositories/set_products_repository.dart';

class GetRelatedSetProductsUseCase {
  final SetProductsRepository repository;

  GetRelatedSetProductsUseCase(this.repository);

  Future<SetProductsResponse> call({required int productId}) async {
    return await repository.getRelatedSetProducts(productId: productId);
  }
}
