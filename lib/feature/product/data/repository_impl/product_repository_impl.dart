import 'package:e_commerce_app/feature/product/data/datasource/product_datasource.dart';
import 'package:e_commerce_app/feature/product/domain/entity/product_entity.dart';
import 'package:e_commerce_app/feature/product/domain/repository/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDataSource dataSource;

  ProductRepositoryImpl({required this.dataSource});

  @override
  Future<List<ProductEntity>> getProducts({int offset = 0, int limit = 10}) {
    return dataSource.getProducts(offset: offset, limit: limit);
  }

  @override
  Future<ProductEntity> getProductById(String id) {
    return dataSource.getProductById(id);
  }
}
