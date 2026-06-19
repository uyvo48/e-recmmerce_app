import 'package:e_commerce_app/feature/product/data/model/product_model.dart';

abstract class ProductDataSource {
  Future<List<ProductModel>> getProducts({int offset = 0, int limit = 10});
  Future<ProductModel> getProductById(String id);
  Future<List<ProductModel>> getRelatedProducts(String slug);
  Future<ProductModel> createProduct({
    required String title,
    required double price,
    required String description,
    required int categoryId,
    required List<String> images,
  });
  Future<ProductModel> updateProduct({
    required String id,
    required String title,
    required double price,
    required String description,
    required int categoryId,
    required List<String> images,
  });
  Future<bool> deleteProduct(String id);
}
