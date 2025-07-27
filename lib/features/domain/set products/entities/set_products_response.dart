import 'package:melamine_elsherif/features/domain/set%20products/entities/set_products.dart';

class SetProductsResponse {
  final bool? success;
  final List<SetProduct> products;
  final int? currentPage;
  final int? lastPage;
  final int? total;
  final int? perPage;
  final String? nextPageUrl;
  final String? prevPageUrl;

  SetProductsResponse({
    this.success,
    required this.products,
    this.currentPage,
    this.lastPage,
    this.total,
    this.perPage,
    this.nextPageUrl,
    this.prevPageUrl,
  });
}