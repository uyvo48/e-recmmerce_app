import 'package:dio/dio.dart';
import 'package:e_commerce_app/feature/product/data/datasource/product_datasource.dart';
import 'package:e_commerce_app/feature/product/data/model/product_model.dart';

class ProductDataSourceImpl implements ProductDataSource {
  final Dio dio;

  ProductDataSourceImpl({required this.dio});

  @override
  Future<List<ProductModel>> getProducts({int offset = 0, int limit = 10}) async {
    try {
      print('🔵 [API] Calling: /products');
      final response = await dio.get('/products');
      print('🟢 [API] Status: ${response.statusCode}');
      print('🟢 [API] Response type: ${response.data.runtimeType}');
      
      List<dynamic> data;
      
      if (response.data is List) {
        data = response.data as List<dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        data = (map['data'] ?? map['products'] ?? map['items'] ?? []) as List<dynamic>;
      } else {
        throw Exception('Unexpected response format');
      }
      
      print('🟢 [API] Products count: ${data.length}');
      
      // Apply pagination manually
      final startIndex = offset;
      final endIndex = (startIndex + limit).clamp(0, data.length);
      final paginatedData = data.sublist(startIndex, endIndex);

      final products = paginatedData
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList();
      
      print('🟢 [API] Parsed products: ${products.length}');
      return products;
    } on DioException catch (error) {
      print('🔴 [API] DioException: ${error.type}');
      print('🔴 [API] Status code: ${error.response?.statusCode}');
      
      final data = error.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message'].toString());
      }
      throw Exception('Khong tai duoc danh sach san pham.');
    } catch (error, stackTrace) {
      print('🔴 [API] General error: $error');
      throw Exception('Du lieu san pham khong hop le.');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      print('🔵 [API] Calling: /products/$id');
      final response = await dio.get('/products/$id');
      print('🟢 [API] Status: ${response.statusCode}');
      
      final data = response.data as Map<String, dynamic>;
      return ProductModel.fromJson(data);
    } on DioException catch (error) {
      print('🔴 [API] DioException: ${error.type}');
      
      final data = error.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message'].toString());
      }
      throw Exception('Khong tai duoc thong tin san pham.');
    } catch (error) {
      print('🔴 [API] General error: $error');
      throw Exception('Du lieu san pham khong hop le.');
    }
  }
}
