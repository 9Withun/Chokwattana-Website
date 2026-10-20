import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/appUI/ui.dart';
import 'package:project/data/category_repository.dart';
import 'package:project/data/product.dart';

Product _product(String name, String? type) => Product.fromJson({
  'product_name': name,
  'product_type': type,
  'price': 100,
});

final _products = [
  _product('Speaker', 'อุปกรณ์ไฟฟ้า'),
  _product('Kettle', ' อุปกรณ์ไฟฟ้า '),
  _product('Rice mill', 'เครื่องมือเกษตร'),
  _product('Pipe', 'อุปกรณ์ประปา'),
  _product('Lan plug', null),
];

void main() {
  test('filterByCategory matches product_type, trimmed', () {
    final names = CategoryRepository.filterByCategory(
      _products,
      'อุปกรณ์ไฟฟ้า',
    ).map((p) => p.productName);
    expect(names, ['Speaker', 'Kettle']);
  });

  test('filterByCategory maps database aliases to the menu name', () {
    final names = CategoryRepository.filterByCategory(
      _products,
      'เครื่องมือการเกษตร',
    ).map((p) => p.productName);
    expect(names, ['Rice mill']);
  });

  Future<void> showCategory(WidgetTester tester, String name) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: CategoryProductPage(
          categoryName: name,
          productsFuture: Future.value(_products),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('category page shows only that category', (tester) async {
    await showCategory(tester, 'อุปกรณ์ประปา');

    expect(find.byType(ProductCard), findsOneWidget);
    expect(find.text('Pipe'), findsOneWidget);
    expect(find.text('Speaker'), findsNothing);
  });

  testWidgets('category page with no products says so', (tester) async {
    await showCategory(tester, 'กระเบื้อง');

    expect(find.byType(ProductCard), findsNothing);
    expect(find.text('ไม่มีสินค้าในหมวดนี้'), findsOneWidget);
  });
}
