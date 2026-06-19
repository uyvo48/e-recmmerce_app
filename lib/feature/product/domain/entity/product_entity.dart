class ProductEntity {
  final String id;
  final String title;
  final String imageCover;
  final String brandName;
  final String categoryName;
  final num price;
  final num ratingsAverage;
  final int ratingsQuantity;
  final int sold;

  ProductEntity({
    required this.id,
    required this.title,
    required this.imageCover,
    required this.brandName,
    required this.categoryName,
    required this.price,
    required this.ratingsAverage,
    required this.ratingsQuantity,
    required this.sold,
  });
}
