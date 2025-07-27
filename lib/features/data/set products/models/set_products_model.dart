import '../../../domain/set products/entities/set_products.dart';
import '../../../domain/set products/entities/set_products_response.dart';

class SetProductsModel {
  final bool? success;
  final DataModel? data;

  SetProductsModel({
    this.success,
    this.data,
  });

  factory SetProductsModel.fromJson(Map<String, dynamic> json) {
    return SetProductsModel(
      success: json["success"],
      data: json["data"] == null ? null : DataModel.fromJson(json["data"]),
    );
  }

  SetProductsResponse toEntity() {
    return SetProductsResponse(
      success: success,
      products: data?.data.map((datum) => datum.toEntity()).toList() ?? [],
      currentPage: data?.currentPage,
      lastPage: data?.lastPage,
      total: data?.total,
      perPage: data?.perPage,
      nextPageUrl: data?.nextPageUrl,
      prevPageUrl: data?.prevPageUrl,
    );
  }
}

class DataModel {
  final int? currentPage;
  final List<DatumModel> data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final dynamic prevPageUrl;
  final int? to;
  final int? total;

  DataModel({
    this.currentPage,
    required this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      currentPage: json["current_page"],
      data: json["data"] == null
          ? []
          : List<DatumModel>.from(json["data"]!.map((x) => DatumModel.fromJson(x))),
      firstPageUrl: json["first_page_url"],
      from: json["from"],
      lastPage: json["last_page"],
      lastPageUrl: json["last_page_url"],
      nextPageUrl: json["next_page_url"],
      path: json["path"],
      perPage: json["per_page"],
      prevPageUrl: json["prev_page_url"],
      to: json["to"],
      total: json["total"],
    );
  }
}

class DatumModel {
  final int? id;
  final String? name;
  final String? slug;
  final String? description;
  final int? fullSetPrice;
  final bool? hasDiscount;
  final String? discount;
  final String? mainPrice;
  final String? discountedPrice;
  final int? calculablePrice;
  final String? thumbnailImage;
  final int? mainCategoryId;
  final String? mainCategoryName;
  final int? componentCount;
  final bool? published;
  final bool? approved;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DatumModel({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.fullSetPrice,
    this.hasDiscount,
    this.discount,
    this.mainPrice,
    this.discountedPrice,
    this.calculablePrice,
    this.thumbnailImage,
    this.mainCategoryId,
    this.mainCategoryName,
    this.componentCount,
    this.published,
    this.approved,
    this.createdAt,
    this.updatedAt,
  });

  factory DatumModel.fromJson(Map<String, dynamic> json) {
    return DatumModel(
      id: json["id"],
      name: json["name"],
      slug: json["slug"],
      description: json["description"],
      fullSetPrice: json["full_set_price"],
      hasDiscount: json["has_discount"],
      discount: json["discount"],
      mainPrice: json["main_price"],
      discountedPrice: json["discounted_price"],
      calculablePrice: json["calculable_price"],
      thumbnailImage: json["thumbnail_image"],
      mainCategoryId: json["main_category_id"],
      mainCategoryName: json["main_category_name"],
      componentCount: json["component_count"],
      published: json["published"],
      approved: json["approved"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
    );
  }

  SetProduct toEntity() {
    return SetProduct(
      id: id,
      name: name,
      slug: slug,
      description: description,
      fullSetPrice: fullSetPrice,
      hasDiscount: hasDiscount,
      discount: discount,
      mainPrice: mainPrice,
      discountedPrice: discountedPrice,
      calculablePrice: calculablePrice,
      thumbnailImage: thumbnailImage,
      mainCategoryId: mainCategoryId,
      mainCategoryName: mainCategoryName,
      componentCount: componentCount,
      published: published,
      approved: approved,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
