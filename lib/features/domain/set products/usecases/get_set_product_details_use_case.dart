import '../entities/set_product_details.dart';
import '../repositories/set_products_repository.dart';

class GetSetProductDetailsUseCase {
  final SetProductsRepository repository;

  GetSetProductDetailsUseCase(this.repository);

  Future<SetProductDetailsEntity> call({required String slug}) async {
    return await repository.getSetProductDetails(slug: slug);
  }
}