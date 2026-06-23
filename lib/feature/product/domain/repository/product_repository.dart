import 'package:e_commerce_app/feature/product/domain/entity/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts({
    int offset = 0,
    int limit = 10,
    num? price,
    num? priceMin,
    num? priceMax,
    int? categoryId,
  });
  Future<ProductEntity> getProductById(String id);
  Future<List<ProductEntity>> getRelatedProducts(String slug);
  Future<ProductEntity> createProduct({
    required String title,
    required double price,
    required String description,
    required int categoryId,
    required List<String> images,
  });
  Future<ProductEntity> updateProduct({
    required String id,
    required String title,
    required double price,
    required String description,
    required int categoryId,
    required List<String> images,
  });
  Future<bool> deleteProduct(String id);
}
