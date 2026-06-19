import 'package:e_commerce_app/feature/product/domain/entity/product_entity.dart';
import 'package:e_commerce_app/feature/product/domain/repository/product_repository.dart';

class GetProductDetailUseCase {
  final ProductRepository repository;

  GetProductDetailUseCase({required this.repository});

  Future<ProductEntity> call(String id) {
    return repository.getProductById(id);
  }
}
