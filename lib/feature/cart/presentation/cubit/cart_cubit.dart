import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_app/feature/cart/domain/entity/cart_item_entity.dart';
import 'package:e_commerce_app/feature/product/domain/entity/product_entity.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState(items: []));

  void addToCart(ProductEntity product, {int quantity = 1}) {
    final currentItems = List<CartItemEntity>.from(state.items);
    final existingIndex = currentItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      final existingItem = currentItems[existingIndex];
      currentItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      currentItems.add(CartItemEntity(product: product, quantity: quantity));
    }

    emit(state.copyWith(items: currentItems));
  }

  void removeFromCart(int productId) {
    final currentItems = List<CartItemEntity>.from(state.items);
    currentItems.removeWhere((item) => item.product.id == productId);
    emit(state.copyWith(items: currentItems));
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final currentItems = List<CartItemEntity>.from(state.items);
    final index = currentItems.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      currentItems[index] = currentItems[index].copyWith(quantity: quantity);
      emit(state.copyWith(items: currentItems));
    }
  }

  void clearCart() {
    emit(state.copyWith(items: []));
  }
}
