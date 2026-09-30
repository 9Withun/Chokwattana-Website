import '../models/product_model.dart';
import 'listmenu.dart';

class CategoryRepository {
  static List<String> get categoryNames => List<String>.from(listMenu);

  static List<ProductCategory> get categories =>
      categoryNames.map((name) => ProductCategory(
            id: name,
            name: name,
            products: _defaultProductsFor(name),
          )).toList();

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
