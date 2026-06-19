import 'package:bloc/bloc.dart';
import 'package:e_commerce_app/feature/product/domain/entity/product_entity.dart';
import 'package:e_commerce_app/feature/product/domain/usecase/get_products_usecase.dart';
import 'package:flutter/foundation.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final GetProductsUseCase getProductsUseCase;

  ProductCubit({required this.getProductsUseCase}) : super(ProductInitial());

  Future<void> getProducts() async {
    emit(ProductLoading());

    try {
      final products = await getProductsUseCase();
      emit(ProductSuccess(products));
    } catch (error) {
      emit(ProductFailure(error.toString().replaceFirst('Exception: ', '')));
    }
  }
}
