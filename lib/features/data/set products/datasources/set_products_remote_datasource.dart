import '../../../../core/api/api_provider.dart';
import '../../../../core/utils/constants/app_endpoints.dart';
import '../models/set_products_model.dart';

abstract class SetProductsRemoteDataSource {
  Future<SetProductsModel> getSetProducts({int page = 1});
}

class SetProductsRemoteDataSourceImpl implements SetProductsRemoteDataSource {
  final ApiProvider apiProvider;

  SetProductsRemoteDataSourceImpl(this.apiProvider);

  @override
  Future<SetProductsModel> getSetProducts({int page = 1}) async {
    final response = await apiProvider.get(
      '${LaravelApiEndPoint.setProducts}?page=$page',
    );

    if (response.data != null) {
      return SetProductsModel.fromJson(response.data);
    }
    throw Exception('Invalid set products response');
  }
}