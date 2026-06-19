import 'package:bloc/bloc.dart';
import 'package:e_commerce_app/feature/product/domain/entity/product_entity.dart';
import 'package:e_commerce_app/feature/product/domain/usecase/get_products_usecase.dart';
import 'package:flutter/foundation.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final GetProductsUseCase getProductsUseCase;
  int _currentOffset = 0;
  static const int _pageSize = 20;

  ProductCubit({required this.getProductsUseCase}) : super(ProductInitial());

  Future<void> getProducts() async {
    print('🟡 [Cubit] Loading products...');
    emit(ProductLoading());
    _currentOffset = 0;

    try {
      final products = await getProductsUseCase(offset: 0, limit: _pageSize);
      print('🟢 [Cubit] Success: ${products.length} products loaded');
      _currentOffset = products.length;
      emit(ProductSuccess(
        products: products,
        hasMore: products.length >= _pageSize,
      ));
    } catch (error) {
      print('🔴 [Cubit] Failed: $error');
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

    print('🟡 [Cubit] Loading more products from offset $_currentOffset');
    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final newProducts = await getProductsUseCase(
        offset: _currentOffset,
        limit: _pageSize,
      );
      print('🟢 [Cubit] Loaded ${newProducts.length} more products');
      
      _currentOffset += newProducts.length;
      
      emit(ProductSuccess(
        products: [...currentState.products, ...newProducts],
        hasMore: newProducts.length >= _pageSize,
        isLoadingMore: false,
      ));
    } catch (error) {
      print('🔴 [Cubit] Load more failed: $error');
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }
}
