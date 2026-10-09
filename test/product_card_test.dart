import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/appUI/ui.dart';
import 'package:project/data/product.dart';

void main() {
  testWidgets('product card shows large image, details, and price', (
    tester,
  ) async {
    final product = Product.fromJson({
      'product_name': 'PD-Name',
      'product_detail':
          'detail-detail-detail-detail-detail detail-detail-detail-detail-detail',
      'price': 1250,
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 220,
              height: 380,
              child: ProductCard(apiProduct: product),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('product-card-image')), findsOneWidget);
    expect(find.text('Product Image'), findsOneWidget);
    expect(find.text('PD-Name'), findsOneWidget);
    expect(find.textContaining('detail-detail'), findsOneWidget);
    expect(find.text('1,250 ฿'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_basket_outlined), findsNothing);

    final imageArea = tester.getSize(
      find.byKey(const ValueKey('product-card-image')),
    );
    expect(imageArea.height, greaterThan(180));
    final imageContainer = tester.widget<Container>(
      find.byKey(const ValueKey('product-card-image')),
    );
    final imageDecoration = imageContainer.decoration! as BoxDecoration;
    expect(imageDecoration.border, isNull);
    expect(imageDecoration.color, Colors.white);
  });

  testWidgets('product price adds thousands separators only when needed', (
    tester,
  ) async {
    Future<void> showPrice(int price) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 300,
              child: ProductCard(
                apiProduct: Product.fromJson({
                  'product_name': 'Product',
                  'price': price,
                }),
              ),
            ),
          ),
        ),
      );
    }

    await showPrice(999);
    expect(find.text('999 ฿'), findsOneWidget);

    await showPrice(1000);
    expect(find.text('1,000 ฿'), findsOneWidget);

    await showPrice(1250000);
    expect(find.text('1,250,000 ฿'), findsOneWidget);
  });

  testWidgets('mobile product list scrolls vertically with two cards per row', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final products = List.generate(
      5,
      (index) => Product.fromJson({
        'product_name': 'Product $index',
        'product_detail': 'Product detail',
        'price': 100 + index,
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ApiProductSection(productsFuture: Future.value(products)),
          ),
        ),
      ),
    );
    await tester.pump();

    final cards = find.byType(ProductCard);
    expect(cards, findsAtLeastNWidgets(2));
    expect(find.byKey(const ValueKey('mobile-product-grid')), findsOneWidget);

    final firstCard = tester.getRect(cards.at(0));
    final secondCard = tester.getRect(cards.at(1));
    expect(firstCard.width, closeTo(173, 1));
    expect(secondCard.left - firstCard.right, closeTo(12, 1));
    expect(secondCard.right, closeTo(374, 1));
    expect(secondCard.top, closeTo(firstCard.top, 1));

    final thirdCard = tester.getRect(cards.at(2));
    expect(thirdCard.left, closeTo(firstCard.left, 1));
    expect(thirdCard.top, greaterThan(firstCard.bottom));

    final outerScroll = find.byType(SingleChildScrollView);
    await tester.drag(outerScroll, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(cards.at(0)).dy, lessThan(firstCard.top));
  });

  testWidgets('desktop product list uses a vertical multi-column grid', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final products = List.generate(
      48,
      (index) => Product.fromJson({
        'product_name': 'Product $index',
        'product_detail': 'Product detail',
        'price': 100 + index,
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ApiProductSection(productsFuture: Future.value(products)),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('desktop-product-grid')), findsOneWidget);
    final cards = find.byType(ProductCard);
    final firstCard = tester.getRect(cards.at(0));
    final secondCard = tester.getRect(cards.at(1));
    expect(secondCard.left, greaterThan(firstCard.right));
    expect(secondCard.top, closeTo(firstCard.top, 1));

    final grid = tester.widget<GridView>(
      find.byKey(const ValueKey('desktop-product-grid')),
    );
    expect(grid.scrollDirection, Axis.vertical);
    expect(grid.physics, isA<NeverScrollableScrollPhysics>());

    final outerScroll = find.byType(SingleChildScrollView);
    await tester.drag(outerScroll, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(cards.at(0)).dy, lessThan(firstCard.top));
  });
}
