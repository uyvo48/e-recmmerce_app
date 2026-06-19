import 'package:dio/dio.dart';
import 'package:e_commerce_app/feature/product/data/datasource/product_datasource.dart';
import 'package:e_commerce_app/feature/product/data/model/product_model.dart';

class ProductDataSourceImpl implements ProductDataSource {
  final Dio dio;

  ProductDataSourceImpl({required this.dio});

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await dio.get('/products');
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as List<dynamic>? ?? [];

      return data
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList();
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message'].toString());
      }
      throw Exception('Khong tai duoc danh sach san pham.');
    } catch (_) {
      throw Exception('Du lieu san pham khong hop le.');
    }
  }
}
