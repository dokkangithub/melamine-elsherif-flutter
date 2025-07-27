// lib/features/data/set products/models/set_product_details_model.dart

import '../../../domain/set products/entities/set_product_details.dart';

class SetProductDetailsModel {
  final bool? success;
  final SetProductDetailsDataModel? data;

  SetProductDetailsModel({
    this.success,
    this.data,
  });

  factory SetProductDetailsModel.fromJson(Map<String, dynamic> json) {
    return SetProductDetailsModel(
      success: json["success"],
      data: json["data"] == null ? null : SetProductDetailsDataModel.fromJson(json["data"]),
    );
  }

  SetProductDetailsEntity toEntity() {
    return SetProductDetailsEntity(
      success: success,
      data: data?.toEntity(),
    );
  }
}

class SetProductDetailsDataModel {
  final int? id;
  final String? name;
  final String? slug;
  final String? description;
  final dynamic customDescription;
  final int? fullSetPrice;
  final bool? hasDiscount;
  final String? discount;
  final String? mainPrice;
  final String? discountedPrice;
  final int? calculablePrice;
  final int? minimumCustomPrice;
  final String? thumbnailImage;
  final dynamic sku;
  final List<dynamic> specification;
  final List<ComponentModel> components;
  final int? componentCount;
  final int? requiredComponents;
  final List<ReviewModel> reviews;
  final int? reviewCount;

  SetProductDetailsDataModel({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.customDescription,
    this.fullSetPrice,
    this.hasDiscount,
    this.discount,
    this.mainPrice,
    this.discountedPrice,
    this.calculablePrice,
    this.minimumCustomPrice,
    this.thumbnailImage,
    this.sku,
    this.specification = const [],
    this.components = const [],
    this.componentCount,
    this.requiredComponents,
    this.reviews = const [],
    this.reviewCount,
  });

  factory SetProductDetailsDataModel.fromJson(Map<String, dynamic> json) {
    return SetProductDetailsDataModel(
      id: json["id"],
      name: json["name"],
      slug: json["slug"],
      description: json["description"],
      customDescription: json["custom_description"],
      fullSetPrice: json["full_set_price"],
      hasDiscount: json["has_discount"],
      discount: json["discount"],
      mainPrice: json["main_price"],
      discountedPrice: json["discounted_price"],
      calculablePrice: json["calculable_price"],
      minimumCustomPrice: json["minimum_custom_price"],
      thumbnailImage: json["thumbnail_image"],
      sku: json["sku"],
      specification: json["specification"] == null ? [] : List<dynamic>.from(json["specification"]!.map((x) => x)),
      components: json["components"] == null ? [] : List<ComponentModel>.from(json["components"]!.map((x) => ComponentModel.fromJson(x))),
      componentCount: json["component_count"],
      requiredComponents: json["required_components"],
      reviews: json["reviews"] == null ? [] : List<ReviewModel>.from(json["reviews"].map((x) => ReviewModel.fromJson(x))),
      reviewCount: json["review_count"],
    );
  }

  SetProductDetailsData toEntity() {
    return SetProductDetailsData(
      id: id,
      name: name,
      slug: slug,
      description: description,
      customDescription: customDescription,
      fullSetPrice: fullSetPrice,
      hasDiscount: hasDiscount,
      discount: discount,
      mainPrice: mainPrice,
      discountedPrice: discountedPrice,
      calculablePrice: calculablePrice,
      minimumCustomPrice: minimumCustomPrice,
      thumbnailImage: thumbnailImage,
      sku: sku,
      specification: specification,
      components: components.map((c) => c.toEntity()).toList(),
      componentCount: componentCount,
      requiredComponents: requiredComponents,
      reviews: reviews.map((r) => r.toEntity()).toList(),
      reviewCount: reviewCount,
    );
  }
}

class ComponentModel {
  final int? id;
  final String? name;
  final String? slug;
  final int? price;
  final int? originalPrice;
  final bool? hasDiscount;
  final String? discount;
  final String? mainPrice;
  final String? discountedPrice;
  final int? calculablePrice;
  final int? finalPrice;
  final int? minQuantity;
  final int? maxQuantity;
  final int? initialQuantity;
  final bool? isRequired;
  final String? thumbnailImage;
  final String? description;
  final int? stock;
  final dynamic sku;
  final List<dynamic> specification;

  ComponentModel({
    this.id,
    this.name,
    this.slug,
    this.price,
    this.originalPrice,
    this.hasDiscount,
    this.discount,
    this.mainPrice,
    this.discountedPrice,
    this.calculablePrice,
    this.finalPrice,
    this.minQuantity,
    this.maxQuantity,
    this.initialQuantity,
    this.isRequired,
    this.thumbnailImage,
    this.description,
    this.stock,
    this.sku,
    this.specification = const [],
  });

  factory ComponentModel.fromJson(Map<String, dynamic> json) {
    return ComponentModel(
      id: json["id"],
      name: json["name"],
      slug: json["slug"],
      price: json["price"],
      originalPrice: json["original_price"],
      hasDiscount: json["has_discount"],
      discount: json["discount"],
      mainPrice: json["main_price"],
      discountedPrice: json["discounted_price"],
      calculablePrice: json["calculable_price"],
      finalPrice: json["final_price"],
      minQuantity: json["min_quantity"],
      maxQuantity: json["max_quantity"],
      initialQuantity: json["initial_quantity"],
      isRequired: json["is_required"],
      thumbnailImage: json["thumbnail_image"],
      description: json["description"],
      stock: json["stock"],
      sku: json["sku"],
      specification: json["specification"] == null ? [] : List<dynamic>.from(json["specification"]!.map((x) => x)),
    );
  }

  Component toEntity() {
    return Component(
      id: id,
      name: name,
      slug: slug,
      price: price,
      originalPrice: originalPrice,
      hasDiscount: hasDiscount,
      discount: discount,
      mainPrice: mainPrice,
      discountedPrice: discountedPrice,
      calculablePrice: calculablePrice,
      finalPrice: finalPrice,
      minQuantity: minQuantity,
      maxQuantity: maxQuantity,
      initialQuantity: initialQuantity,
      isRequired: isRequired,
      thumbnailImage: thumbnailImage,
      description: description,
      stock: stock,
      sku: sku,
      specification: specification,
    );
  }
}

class ReviewModel {
  final String? userName;
  final String? type;
  final int? rating;
  final String? comment;
  final String? time;

  ReviewModel({
    this.userName,
    this.type,
    this.rating,
    this.comment,
    this.time,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      userName: json["user_name"],
      type: json["type"],
      rating: json["rating"],
      comment: json["comment"],
      time: json["time"],
    );
  }

  Review toEntity() {
    return Review(
      userName: userName,
      type: type,
      rating: rating,
      comment: comment,
      time: time,
    );
  }
}

// Calculate Price Models
class CalculatePriceRequestModel {
  final int productId;
  final List<ComponentRequestModel> components;

  CalculatePriceRequestModel({
    required this.productId,
    required this.components,
  });

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "components": components.map((x) => x.toJson()).toList(),
  };
}

class ComponentRequestModel {
  final int productId;
  final int quantity;

  ComponentRequestModel({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "quantity": quantity,
  };
}

class CalculatePriceResponseModel {
  final bool? success;
  final CalculatedPriceDataModel? data;

  CalculatePriceResponseModel({
    this.success,
    this.data,
  });

  factory CalculatePriceResponseModel.fromJson(Map<String, dynamic> json) {
    return CalculatePriceResponseModel(
      success: json["success"],
      data: json["data"] == null ? null : CalculatedPriceDataModel.fromJson(json["data"]),
    );
  }

  CalculatePriceResponseEntity toEntity() {
    return CalculatePriceResponseEntity(
      success: success,
      data: data?.toEntity(),
    );
  }
}

class CalculatedPriceDataModel {
  final int? totalPrice;
  final List<CalculatedComponentModel> components;
  final int? componentCount;

  CalculatedPriceDataModel({
    this.totalPrice,
    this.components = const [],
    this.componentCount,
  });

  factory CalculatedPriceDataModel.fromJson(Map<String, dynamic> json) {
    return CalculatedPriceDataModel(
      totalPrice: json["total_price"],
      components: json["components"] == null ? [] : List<CalculatedComponentModel>.from(json["components"]!.map((x) => CalculatedComponentModel.fromJson(x))),
      componentCount: json["component_count"],
    );
  }

  CalculatedPriceData toEntity() {
    return CalculatedPriceData(
      totalPrice: totalPrice,
      components: components.map((c) => c.toEntity()).toList(),
      componentCount: componentCount,
    );
  }
}

class CalculatedComponentModel {
  final int? productId;
  final String? name;
  final int? quantity;
  final int? unitPrice;
  final int? totalPrice;

  CalculatedComponentModel({
    this.productId,
    this.name,
    this.quantity,
    this.unitPrice,
    this.totalPrice,
  });

  factory CalculatedComponentModel.fromJson(Map<String, dynamic> json) {
    return CalculatedComponentModel(
      productId: json["product_id"],
      name: json["name"],
      quantity: json["quantity"],
      unitPrice: json["unit_price"],
      totalPrice: json["total_price"],
    );
  }

  CalculatedComponent toEntity() {
    return CalculatedComponent(
      productId: productId,
      name: name,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
    );
  }
}