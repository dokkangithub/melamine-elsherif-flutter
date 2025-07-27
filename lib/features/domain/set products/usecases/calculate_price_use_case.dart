import '../entities/set_product_details.dart';
import '../repositories/set_products_repository.dart';

class CalculatePriceUseCase {
  final SetProductsRepository repository;

  CalculatePriceUseCase(this.repository);

  Future<CalculatePriceResponseEntity> call({required CalculatePriceRequest request}) async {
    return await repository.calculatePrice(request: request);
  }
}