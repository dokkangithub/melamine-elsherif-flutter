import '../../../domain/set products/entities/set_products_response.dart';
import '../../../domain/set products/repositories/set_products_repository.dart';
import '../datasources/set_products_remote_datasource.dart';
import '../datasources/set_products_local_datasource.dart';
import '../models/set_products_model.dart';

class SetProductsRepositoryImpl implements SetProductsRepository {
  final SetProductsRemoteDataSource remoteDataSource;
  final SetProductsLocalDataSource localDataSource;

  SetProductsRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<SetProductsResponse> getSetProducts({int page = 1, bool needUpdate = false}) async {
    const collectionType = 'set_products';
    if (!needUpdate) {
      final isCacheValid = await localDataSource.isCollectionCacheValid(collectionType, page);
      if (isCacheValid) {
        final cached = await localDataSource.getCollectionFromCache(collectionType, page);
        if (cached != null) {
          return SetProductsResponse(
            success: true,
            products: cached.map((e) => e.toEntity()).toList(),
            currentPage: page,
            lastPage: page, // You may want to store this in cache as well
            total: cached.length,
            perPage: cached.length,
            nextPageUrl: null,
            prevPageUrl: null,
          );
        }
      }
    }
    // Fetch from remote and update cache
    final model = await remoteDataSource.getSetProducts(page: page);
    final products = model.data?.data ?? [];
    final totalPages = model.data?.lastPage ?? 1;
    await localDataSource.saveCollection(collectionType, page, products, totalPages);
    return model.toEntity();
  }
}
