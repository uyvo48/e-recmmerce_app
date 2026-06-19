import 'package:e_commerce_app/feature/product/domain/entity/product_entity.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    required super.id,
    required super.title,
    required super.imageCover,
    required super.brandName,
    required super.categoryName,
    required super.price,
    required super.ratingsAverage,
    required super.ratingsQuantity,
    required super.sold,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final brand = json['brand'];
    final category = json['category'];

    return ProductModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      imageCover: json['imageCover'] as String? ?? '',
      brandName:
          brand is Map<String, dynamic> ? brand['name'] as String? ?? '' : '',
      categoryName: category is Map<String, dynamic>
          ? category['name'] as String? ?? ''
          : '',
      price: json['price'] as num? ?? 0,
      ratingsAverage: json['ratingsAverage'] as num? ?? 0,
      ratingsQuantity: json['ratingsQuantity'] as int? ?? 0,
      sold: json['sold'] as int? ?? 0,
    );
  }
}
