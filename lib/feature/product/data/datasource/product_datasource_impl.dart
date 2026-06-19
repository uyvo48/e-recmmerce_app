import 'package:dio/dio.dart';
import 'package:e_commerce_app/feature/product/data/datasource/product_datasource.dart';
import 'package:e_commerce_app/feature/product/data/model/product_model.dart';

class ProductDataSourceImpl implements ProductDataSource {
  final Dio dio;

  ProductDataSourceImpl({required this.dio});

  @override
  Future<List<ProductModel>> getProducts(
      {int offset = 0, int limit = 10}) async {
    try {
      final response = await dio.get('/products');

      List<dynamic> data;

      if (response.data is List) {
        data = response.data as List<dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        data = (map['data'] ?? map['products'] ?? map['items'] ?? [])
            as List<dynamic>;
      } else {
        throw Exception('Unexpected response format');
      }

      // Apply pagination manually
      final startIndex = offset;
      final endIndex = (startIndex + limit).clamp(0, data.length);
      final paginatedData = data.sublist(startIndex, endIndex);

      final products = paginatedData
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList();
      return products;
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message'].toString());
      }
      throw Exception('Khong tai duoc danh sach san pham.');
    } catch (error) {
      throw Exception('Du lieu san pham khong hop le.');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await dio.get('/products/$id');

      final data = response.data as Map<String, dynamic>;
      return ProductModel.fromJson(data);
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message'].toString());
      }
      throw Exception('Khong tai duoc thong tin san pham.');
    } catch (error) {
      throw Exception('Du lieu san pham khong hop le.');
    }
  }

  @override
  Future<ProductModel> createProduct({
    required String title,
    required double price,
    required String description,
    required int categoryId,
    required List<String> images,
  }) async {
    try {
      final response = await dio.post('/products/', data: {
        'title': title,
        'price': price,
        'description': description,
        'categoryId': categoryId,
        'images': images,
      });

      final data = response.data as Map<String, dynamic>;
      return ProductModel.fromJson(data);
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message'].toString());
      }
      throw Exception('Khong tao duoc san pham.');
    } catch (error) {
      throw Exception('Khong tao duoc san pham.');
    }
  }

  @override
  Future<ProductModel> updateProduct({
    required String id,
    required String title,
    required double price,
    required String description,
    required int categoryId,
    required List<String> images,
  }) async {
    try {
      final response = await dio.put('/products/$id', data: {
        'title': title,
        'price': price,
        'description': description,
        'categoryId': categoryId,
        'images': images,
      });

      final data = response.data as Map<String, dynamic>;
      return ProductModel.fromJson(data);
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message'].toString());
      }
      throw Exception('Khong cap nhat duoc san pham.');
    } catch (error) {
      throw Exception('Khong cap nhat duoc san pham.');
    }
  }

  @override
  Future<bool> deleteProduct(String id) async {
    try {
      final response = await dio.delete('/products/$id');

      return response.statusCode == 200;
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message'].toString());
      }
      throw Exception('Khong xoa duoc san pham.');
    } catch (error) {
      throw Exception('Khong xoa duoc san pham.');
    }
  }

  @override
  Future<List<ProductModel>> getRelatedProducts(String slug) async {
    try {
      final response = await dio.get('/products/slug/$slug/related');

      final data = response.data as List<dynamic>;

      return data
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList();
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message'].toString());
      }
      throw Exception('Khong tai duoc san pham lien quan.');
    } catch (error) {
      throw Exception('Du lieu khong hop le.');
    }
  }
}
