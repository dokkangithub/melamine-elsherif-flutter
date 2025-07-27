// lib/features/domain/set products/entities/set_product_details.dart

class SetProductDetailsEntity {
  final bool? success;
  final SetProductDetailsData? data;

  SetProductDetailsEntity({
    this.success,
    this.data,
  });
}

class SetProductDetailsData {
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
  final List<Component> components;
  final int? componentCount;
  final int? requiredComponents;
  final List<Review> reviews;
  final int? reviewCount;

  SetProductDetailsData({
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
}

class Component {
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

  Component({
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
}

class Review {
  final String? userName;
  final String? type;
  final int? rating;
  final String? comment;
  final String? time;

  Review({
    this.userName,
    this.type,
    this.rating,
    this.comment,
    this.time,
  });
}

// Calculate Price Entities
class CalculatePriceRequest {
  final int productId;
  final List<ComponentRequest> components;

  CalculatePriceRequest({
    required this.productId,
    required this.components,
  });
}

class ComponentRequest {
  final int productId;
  final int quantity;

  ComponentRequest({
    required this.productId,
    required this.quantity,
  });
}

class CalculatePriceResponseEntity {
  final bool? success;
  final CalculatedPriceData? data;

  CalculatePriceResponseEntity({
    this.success,
    this.data,
  });
}

class CalculatedPriceData {
  final int? totalPrice;
  final List<CalculatedComponent> components;
  final int? componentCount;

  CalculatedPriceData({
    this.totalPrice,
    this.components = const [],
    this.componentCount,
  });
}

class CalculatedComponent {
  final int? productId;
  final String? name;
  final int? quantity;
  final int? unitPrice;
  final int? totalPrice;

  CalculatedComponent({
    this.productId,
    this.name,
    this.quantity,
    this.unitPrice,
    this.totalPrice,
  });
}