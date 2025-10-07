import '../../../domain/set products/entities/set_product_details.dart';
import '../../../domain/set products/entities/set_products_response.dart';
import '../../../domain/set products/repositories/set_products_repository.dart';
import '../datasources/set_products_remote_datasource.dart';
import '../datasources/set_products_local_datasource.dart';
import '../models/set_product_details_model.dart';

class SetProductsRepositoryImpl implements SetProductsRepository {
  final SetProductsRemoteDataSource remoteDataSource;
  final SetProductsLocalDataSource localDataSource;

  SetProductsRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<SetProductsResponse> getSetProducts({
    int page = 1,
    bool needUpdate = false,
  }) async {
    print('Repository getSetProducts called - page: $page, needUpdate: $needUpdate');
    
    // Temporarily bypass cache for debugging
    const collectionType = 'set_products';
    
    // Always fetch from remote for now to debug pagination
    final model = await remoteDataSource.getSetProducts(page: page);
    final products = model.data?.data ?? [];
    final totalPages = model.data?.lastPage ?? 1;
    
    print('Repository response - products count: ${products.length}, lastPage: $totalPages, total: ${model.data?.total}');
    
    // Update cache
    await localDataSource.saveCollection(
      collectionType,
      page,
      products,
      totalPages,
    );
    
    final response = model.toEntity();
    print('Repository returning - products count: ${response.products.length}, lastPage: ${response.lastPage}, total: ${response.total}');
    
    return response;
  }

  @override
  Future<SetProductDetailsEntity> getSetProductDetails({
    required String slug,
  }) async {
    final model = await remoteDataSource.getSetProductDetails(slug: slug);
    return model.toEntity();
  }

  @override
  Future<SetProductsResponse> getRelatedSetProducts({
    required int productId,
  }) async {
    final model = await remoteDataSource.getRelatedSetProducts(productId: productId);
    return model.toEntity();
  }

  @override
  Future<CalculatePriceResponseEntity> calculatePrice({
    required CalculatePriceRequest request,
  }) async {
    final requestModel = CalculatePriceRequestModel(
      productId: request.productId,
      components: request.components
          .map(
            (c) => ComponentRequestModel(
              productId: c.productId,
              quantity: c.quantity,
            ),
          )
          .toList(),
    );

    final model = await remoteDataSource.calculatePrice(request: requestModel);
    return model.toEntity();
  }

  @override
  Future<Map<String, dynamic>> addFullSetToCart({
    required int productId,
    required int quantity,
  }) async {
    return await remoteDataSource.addFullSetToCart(
      productId: productId,
      quantity: quantity,
    );
  }

  @override
  Future<Map<String, dynamic>> addCustomSetToCart({
    required int productId,
    required int quantity,
    required List<ComponentRequest> components,
  }) async {
    final componentModels = components
        .map(
          (c) => ComponentRequestModel(
            productId: c.productId,
            quantity: c.quantity,
          ),
        )
        .toList();

    return await remoteDataSource.addCustomSetToCart(
      productId: productId,
      quantity: quantity,
      components: componentModels,
    );
  }
}
