import 'package:e_commerce_app/feature/product/domain/entity/category_entity.dart';

class ProductEntity {
  final int id;
  final String title;
  final String slug;
  final num price;
  final String description;
  final CategoryEntity category;
  final List<String> images;

  ProductEntity({
    required this.id,
    required this.title,
    required this.slug,
    required this.price,
    required this.description,
    required this.category,
    required this.images,
  });

  String get imageCover => images.isNotEmpty ? images.first : '';

  String get categoryName => category.name;
}
