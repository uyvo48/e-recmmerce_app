import 'package:e_commerce_app/feature/product/domain/entity/product_entity.dart';
import 'package:e_commerce_app/feature/product/domain/repository/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase({required this.repository});

  Future<List<ProductEntity>> call({
    int offset = 0,
    int limit = 10,
    num? price,
    num? priceMin,
    num? priceMax,
    int? categoryId,
  }) {
    return repository.getProducts(
      offset: offset,
      limit: limit,
      price: price,
      priceMin: priceMin,
      priceMax: priceMax,
      categoryId: categoryId,
    );
  }
}
