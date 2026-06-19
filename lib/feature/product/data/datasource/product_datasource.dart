import 'package:e_commerce_app/feature/product/data/model/product_model.dart';

abstract class ProductDataSource {
  Future<List<ProductModel>> getProducts({int offset = 0, int limit = 10});
  Future<ProductModel> getProductById(String id);
}
