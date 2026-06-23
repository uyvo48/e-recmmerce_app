import 'package:e_commerce_app/feature/product/data/model/category_model.dart';
import 'package:e_commerce_app/feature/product/domain/entity/product_entity.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    required super.id,
    required super.title,
    required super.slug,
    required super.price,
    required super.description,
    required super.category,
    required super.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'];
    final imagesJson = json['images'] as List<dynamic>? ?? [];

    return ProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
      category: categoryJson is Map<String, dynamic>
          ? CategoryModel.fromJson(categoryJson)
          : CategoryModel(id: 0, name: '', image: '', slug: ''),
      images: imagesJson
          .whereType<String>()
          .toList(),
    );
  }
}
