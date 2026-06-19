import 'package:e_commerce_app/feature/product/domain/entity/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts({int offset = 0, int limit = 10});
  Future<ProductEntity> getProductById(String id);
}
