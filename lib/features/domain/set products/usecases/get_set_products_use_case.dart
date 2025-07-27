import '../entities/set_products_response.dart';
import '../repositories/set_products_repository.dart';

class GetSetProductsUseCase {
  final SetProductsRepository repository;

  GetSetProductsUseCase(this.repository);

  Future<SetProductsResponse> call({int page = 1}) async {
    return await repository.getSetProducts(page: page);
  }
}