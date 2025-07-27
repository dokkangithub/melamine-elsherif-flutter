import '../../../domain/set products/entities/set_products_response.dart';
import '../../../domain/set products/repositories/set_products_repository.dart';
import '../datasources/set_products_remote_datasource.dart';

class SetProductsRepositoryImpl implements SetProductsRepository {
  final SetProductsRemoteDataSource remoteDataSource;

  SetProductsRepositoryImpl(this.remoteDataSource);

  @override
  Future<SetProductsResponse> getSetProducts({int page = 1}) async {
    final model = await remoteDataSource.getSetProducts(page: page);
    return model.toEntity();
  }
}
