part of 'product_cubit.dart';

@immutable
sealed class ProductState {}

final class ProductInitial extends ProductState {}

final class ProductLoading extends ProductState {}

final class ProductSuccess extends ProductState {
  final List<ProductEntity> products;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final num? price;
  final num? priceMin;
  final num? priceMax;
  final int? categoryId;

  ProductSuccess({
    required this.products,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = true,
    this.price,
    this.priceMin,
    this.priceMax,
    this.categoryId,
  });

  bool get hasPrevious => currentPage > 1;
  bool get hasNext => currentPage < totalPages;

  ProductSuccess copyWith({
    List<ProductEntity>? products,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    num? price,
    num? priceMin,
    num? priceMax,
    int? categoryId,
  }) {
    return ProductSuccess(
      products: products ?? this.products,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      price: price ?? this.price,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}

final class ProductFailure extends ProductState {
  final String message;

  ProductFailure(this.message);
}
