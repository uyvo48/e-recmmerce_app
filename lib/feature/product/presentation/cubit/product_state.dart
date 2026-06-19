part of 'product_cubit.dart';

@immutable
sealed class ProductState {}

final class ProductInitial extends ProductState {}

final class ProductLoading extends ProductState {}

final class ProductSuccess extends ProductState {
  final List<ProductEntity> products;
  final bool hasMore;
  final bool isLoadingMore;

  ProductSuccess({
    required this.products,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  ProductSuccess copyWith({
    List<ProductEntity>? products,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ProductSuccess(
      products: products ?? this.products,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final class ProductFailure extends ProductState {
  final String message;

  ProductFailure(this.message);
}
