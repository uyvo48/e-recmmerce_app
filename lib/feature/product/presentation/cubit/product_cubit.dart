import 'package:bloc/bloc.dart';
import 'package:e_commerce_app/feature/product/domain/entity/product_entity.dart';
import 'package:e_commerce_app/feature/product/domain/usecase/create_product_usecase.dart';
import 'package:e_commerce_app/feature/product/domain/usecase/delete_product_usecase.dart';
import 'package:e_commerce_app/feature/product/domain/usecase/get_products_usecase.dart';
import 'package:flutter/foundation.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final CreateProductUseCase createProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  num? _price;
  num? _priceMin;
  num? _priceMax;
  int? _categoryId;
  static const int _pageSize = 10;

  /// Tổng số sản phẩm ước tính – được cập nhật khi API trả về ít hơn _pageSize.
  int _estimatedTotal = 0;

  ProductCubit({
    required this.getProductsUseCase,
    required this.createProductUseCase,
    required this.deleteProductUseCase,
  }) : super(ProductInitial());

  Future<void> getProducts({
    num? price,
    num? priceMin,
    num? priceMax,
    int? categoryId,
    bool keepCurrentFilters = true,
  }) async {
    emit(ProductLoading());

    if (!keepCurrentFilters) {
      _price = price;
      _priceMin = priceMin;
      _priceMax = priceMax;
      _categoryId = categoryId;
    }

    try {
      final products = await getProductsUseCase(
        offset: 0,
        limit: _pageSize,
        price: _price,
        priceMin: _priceMin,
        priceMax: _priceMax,
        categoryId: _categoryId,
      );

      final hasMore = products.length >= _pageSize;

      // Ước tính totalPages: nếu có thêm data thì giả sử ít nhất 2 trang
      if (!hasMore) {
        _estimatedTotal = products.length;
      } else {
        // Chưa biết tổng chính xác, đặt lớn để cho phép chuyển trang tiếp
        _estimatedTotal = _pageSize * 100;
      }

      emit(ProductSuccess(
        products: products,
        currentPage: 1,
        totalPages: (_estimatedTotal / _pageSize).ceil().clamp(1, 999),
        hasMore: hasMore,
        price: _price,
        priceMin: _priceMin,
        priceMax: _priceMax,
        categoryId: _categoryId,
      ));
    } catch (error) {
      emit(ProductFailure(error.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> goToPage(int page) async {
    if (page < 1) return;
    final currentState = state;

    emit(ProductLoading());

    try {
      final offset = (page - 1) * _pageSize;
      final products = await getProductsUseCase(
        offset: offset,
        limit: _pageSize,
        price: _price,
        priceMin: _priceMin,
        priceMax: _priceMax,
        categoryId: _categoryId,
      );

      final hasMore = products.length >= _pageSize;

      if (!hasMore) {
        // Đây là trang cuối – cập nhật tổng chính xác
        _estimatedTotal = offset + products.length;
      } else if (page * _pageSize >= _estimatedTotal) {
        // Mở rộng ước tính nếu cần
        _estimatedTotal = page * _pageSize + _pageSize;
      }


      if (products.isEmpty && page > 1) {
        // Không có sản phẩm ở trang này, quay lại trang trước
        return goToPage(page - 1);
      }

      emit(ProductSuccess(
        products: products,
        currentPage: page,
        totalPages: (_estimatedTotal / _pageSize).ceil().clamp(1, 999),
        hasMore: hasMore,
        price: _price,
        priceMin: _priceMin,
        priceMax: _priceMax,
        categoryId: _categoryId,
      ));
    } catch (error) {
      // Nếu lỗi, khôi phục state cũ nếu có
      if (currentState is ProductSuccess) {
        emit(currentState);
      } else {
        emit(ProductFailure(error.toString().replaceFirst('Exception: ', '')));
      }
    }
  }

  Future<void> nextPage() async {
    final currentState = state;
    if (currentState is ProductSuccess && currentState.hasNext) {
      await goToPage(currentState.currentPage + 1);
    }
  }

  Future<void> previousPage() async {
    final currentState = state;
    if (currentState is ProductSuccess && currentState.hasPrevious) {
      await goToPage(currentState.currentPage - 1);
    }
  }

  Future<bool> createProduct({
    required String title,
    required double price,
    required String description,
    required int categoryId,
    required List<String> images,
  }) async {
    try {
      await createProductUseCase(
        title: title,
        price: price,
        description: description,
        categoryId: categoryId,
        images: images,
      );
      await getProducts(); // Refresh list
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<void> applyFilters({
    num? priceMin,
    num? priceMax,
    int? categoryId,
  }) {
    _estimatedTotal = 0;
    return getProducts(
      priceMin: priceMin,
      priceMax: priceMax,
      categoryId: categoryId,
      keepCurrentFilters: false,
    );
  }

  Future<void> clearFilters() {
    _estimatedTotal = 0;
    _price = null;
    _priceMin = null;
    _priceMax = null;
    _categoryId = null;
    return getProducts(keepCurrentFilters: false);
  }

  Future<bool> deleteProduct(String id) async {
    final currentState = state;

    try {
      final deleted = await deleteProductUseCase(id);
      if (!deleted) {
        return false;
      }

      if (currentState is ProductSuccess) {
        final products =
            currentState.products.where((product) => product.id.toString() != id).toList();

        if (products.isEmpty && currentState.currentPage > 1) {
          // Trang hiện tại hết sản phẩm → quay lại trang trước
          await goToPage(currentState.currentPage - 1);
        } else {
          // Refresh trang hiện tại
          await goToPage(currentState.currentPage);
        }
      } else {
        await getProducts();
      }

      return true;
    } catch (error) {
      if (currentState is ProductSuccess) {
        emit(currentState);
      } else {
        emit(ProductFailure(error.toString().replaceFirst('Exception: ', '')));
      }
      return false;
    }
  }
}
