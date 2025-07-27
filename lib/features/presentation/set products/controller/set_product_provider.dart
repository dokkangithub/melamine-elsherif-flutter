import 'package:flutter/material.dart';
import '../../../domain/set products/entities/set_products.dart';
import '../../../domain/set products/entities/set_products_response.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../domain/set products/usecases/get_set_products_use_case.dart';

class SetProductsProvider extends ChangeNotifier {
  final GetSetProductsUseCase getSetProductsUseCase;

  SetProductsProvider({
    required this.getSetProductsUseCase,
  });

  LoadingState setProductsState = LoadingState.loading;
  List<SetProduct> setProducts = [];
  String setProductsError = '';

  // Pagination properties
  int currentPage = 1;
  int? lastPage;
  int? total;
  bool hasMorePages = true;
  bool isLoadingMore = false;

  Future<void> getSetProducts({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage = 1;
        hasMorePages = true;
        setProducts.clear();
      }

      setProductsState = LoadingState.loading;
      notifyListeners();

      final SetProductsResponse response = await getSetProductsUseCase(page: currentPage);

      if (isRefresh) {
        setProducts = response.products;
      } else {
        setProducts.addAll(response.products);
      }

      lastPage = response.lastPage;
      total = response.total;
      hasMorePages = currentPage < (lastPage ?? 1);

      setProductsState = LoadingState.loaded;
    } catch (e) {
      setProductsState = LoadingState.error;
      setProductsError = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadMoreProducts() async {
    if (!hasMorePages || isLoadingMore) return;

    try {
      isLoadingMore = true;
      notifyListeners();

      currentPage++;
      final SetProductsResponse response = await getSetProductsUseCase(page: currentPage);

      setProducts.addAll(response.products);
      hasMorePages = currentPage < (lastPage ?? 1);

      isLoadingMore = false;
    } catch (e) {
      currentPage--; // Revert page increment on error
      setProductsError = e.toString();
      isLoadingMore = false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> refreshSetProducts() async {
    await getSetProducts(isRefresh: true);
  }

}