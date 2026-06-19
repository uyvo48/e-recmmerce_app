import 'package:e_commerce_app/feature/product/domain/entity/product_entity.dart';
import 'package:e_commerce_app/feature/product/domain/repository/product_repository.dart';

class CreateProductUseCase {
  final ProductRepository repository;

  CreateProductUseCase({required this.repository});

  Future<ProductEntity> call({
    required String title,
    required double price,
    required String description,
    required int categoryId,
    required List<String> images,
  }) {
    return repository.createProduct(
      title: title,
      price: price,
      description: description,
      categoryId: categoryId,
      images: images,
    );
  }
}
