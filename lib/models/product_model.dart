class ProductItem {
  const ProductItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final String description;
}

class ProductCategory {
  const ProductCategory({
    required this.id,
    required this.name,
    required this.products,
  });

  final String id;
  final String name;
  final List<ProductItem> products;
}
