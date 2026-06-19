import 'package:bloc/bloc.dart';
import 'package:e_commerce_app/feature/product/domain/entity/product_entity.dart';
import 'package:e_commerce_app/feature/product/domain/usecase/create_product_usecase.dart';
import 'package:e_commerce_app/feature/product/domain/usecase/get_products_usecase.dart';
import 'package:flutter/foundation.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final CreateProductUseCase createProductUseCase;
  int _currentOffset = 0;
  static const int _pageSize = 20;

  ProductCubit({
    required this.getProductsUseCase,
    required this.createProductUseCase,
  }) : super(ProductInitial());

  Future<void> getProducts() async {
    emit(ProductLoading());
    _currentOffset = 0;

    try {
      final products = await getProductsUseCase(offset: 0, limit: _pageSize);
      _currentOffset = products.length;
      emit(ProductSuccess(
        products: products,
        hasMore: products.length >= _pageSize,
      ));
    } catch (error) {
      emit(ProductFailure(error.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> loadMoreProducts() async {
    final currentState = state;
    if (currentState is! ProductSuccess ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }
    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final newProducts = await getProductsUseCase(
        offset: _currentOffset,
        limit: _pageSize,
      );

      _currentOffset += newProducts.length;

      emit(ProductSuccess(
        products: [...currentState.products, ...newProducts],
        hasMore: newProducts.length >= _pageSize,
        isLoadingMore: false,
      ));
    } catch (error) {
      emit(currentState.copyWith(isLoadingMore: false));
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
}
