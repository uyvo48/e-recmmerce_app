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
    final category = json['category'];
    final images = json['images'] as List<dynamic>? ?? [];

    return ProductModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      imageCover: images.isNotEmpty ? images[0] as String? ?? '' : '',
      brandName: '',
      categoryName: category is Map<String, dynamic>
          ? category['name'] as String? ?? ''
          : '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      ratingsAverage: 0,
      ratingsQuantity: 0,
      sold: 0,
    );
  }
}
