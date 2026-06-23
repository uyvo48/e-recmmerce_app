import 'package:e_commerce_app/feature/product/domain/repository/product_repository.dart';

class DeleteProductUseCase {
  final ProductRepository repository;

  DeleteProductUseCase({required this.repository});

  Future<bool> call(String id) {
    return repository.deleteProduct(id);
  }
}
