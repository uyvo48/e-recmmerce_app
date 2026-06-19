import 'package:e_commerce_app/feature/product/data/model/product_model.dart';

abstract class ProductDataSource {
  Future<List<ProductModel>> getProducts();
}
