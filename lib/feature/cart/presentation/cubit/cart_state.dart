import 'package:e_commerce_app/feature/cart/domain/entity/cart_item_entity.dart';

class CartState {
  final List<CartItemEntity> items;

  CartState({required this.items});

  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  int get totalCount => items.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({
    List<CartItemEntity>? items,
  }) {
    return CartState(
      items: items ?? this.items,
    );
  }
}
