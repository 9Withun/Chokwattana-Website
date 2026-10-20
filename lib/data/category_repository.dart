import '../models/product_model.dart';
import 'listmenu.dart';
import 'product.dart';

class CategoryRepository {
  static List<String> get categoryNames => List<String>.from(listMenu);

  // product_type values in the database that differ from the menu name.
  static const _productTypeAliases = {
    'เครื่องมือการเกษตร': ['เครื่องมือเกษตร'],
  };

  static bool productInCategory(Product product, String categoryName) {
    final type = product.productType;
    return type == categoryName ||
        (_productTypeAliases[categoryName]?.contains(type) ?? false);
  }

  static List<Product> filterByCategory(
    List<Product> products,
    String categoryName,
  ) {
    return products
        .where((product) => productInCategory(product, categoryName))
        .toList();
  }

  static List<ProductCategory> get categories => categoryNames
      .map(
        (name) => ProductCategory(
          id: name,
          name: name,
          products: _defaultProductsFor(name),
        ),
      )
      .toList();

  static ProductCategory? findByName(String name) {
    return categories.where((category) => category.name == name).firstOrNull;
  }

  static List<ProductItem> getProductsByCategoryName(String name) {
    final category = findByName(name);
    return category?.products ?? _defaultProductsFor(name);
  }

  static List<ProductItem> _defaultProductsFor(String categoryName) {
    return [
      ProductItem(
        id: '$categoryName-1',
        name: 'สินค้า $categoryName',
        category: categoryName,
        price: 150,
        description: 'สินค้าในหมวด $categoryName',
      ),
      ProductItem(
        id: '$categoryName-2',
        name: 'สินค้าขายดี $categoryName',
        category: categoryName,
        price: 320,
        description: 'สินค้าแนะนำสำหรับ $categoryName',
      ),
    ];
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
