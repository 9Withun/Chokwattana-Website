import 'package:flutter/material.dart';
import 'package:project/data/category_repository.dart';
import 'package:project/data/listmenu.dart';
import 'package:project/models/product_model.dart';

class CategoryMenuProcess {
  static List<String> get categoryNames => CategoryRepository.categoryNames;

  static RelativeRect getMenuPosition(
    BuildContext context,
    RenderBox renderBox,
  ) {
    final offset = renderBox.localToGlobal(Offset.zero);
    return RelativeRect.fromRect(
      Rect.fromLTWH(
        offset.dx,
        offset.dy + renderBox.size.height,
        renderBox.size.width,
        renderBox.size.height,
      ),
      Offset.zero & MediaQuery.sizeOf(context),
    );
  }

  static List<PopupMenuEntry<String>> buildMenuItems() {
    return categoryNames
        .map(
          (item) => PopupMenuItem<String>(
            key: ValueKey('menu-category-$item'),
            value: item,
            child: Container(
              width: 240,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }

  static String selectedMessage(String selected) => 'เลือก: $selected';

  static List<ProductItem> productsForCategory(String categoryName) {
    return CategoryRepository.getProductsByCategoryName(categoryName);
  }
}

class PromotionCarouselProcess {
  static bool canScrollPrevious(double offset) => offset > 0.5;

  static bool canScrollNext(double offset, double maxScrollExtent) =>
      maxScrollExtent - offset > 0.5;

  static double nextOffset(
    double currentOffset,
    double cardWidth,
    double maxScrollExtent,
  ) {
    return (currentOffset + cardWidth + 8).clamp(0, maxScrollExtent);
  }

  static double previousOffset(
    double currentOffset,
    double cardWidth,
    double maxScrollExtent,
  ) {
    return (currentOffset - cardWidth - 8).clamp(0, maxScrollExtent);
  }
}

class CategoryPageData {
  const CategoryPageData({required this.categoryName, required this.products});

  final String categoryName;
  final List<ProductItem> products;

  static CategoryPageData fromCategoryName(String categoryName) {
    final products = CategoryMenuProcess.productsForCategory(categoryName);
    return CategoryPageData(categoryName: categoryName, products: products);
  }
}

class ProductListProcess {
  static List<ProductItem> filterProductsByCategory(String categoryName) {
    return CategoryRepository.getProductsByCategoryName(categoryName);
  }

  static List<String> categoryMenuList() => listMenu;
}
