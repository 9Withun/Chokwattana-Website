import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/appUI/ui.dart';
import 'package:project/data/product.dart';

void main() {
  Product createProduct() => Product.fromJson({
    'product_name': 'Product Name',
    'product_brand': 'Brand',
    'product_detail': 'First product detail\nSecond product detail',
    'price': 1250,
  });

  testWidgets('mobile product details stack below the image', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: ProductDetailPage(apiProduct: createProduct())),
    );

    expect(find.text('Product Name'), findsOneWidget);
    expect(find.text('1,250 ฿'), findsOneWidget);
    expect(find.text('First product detail'), findsOneWidget);
    expect(find.text('จำนวนสินค้าคงเหลือ'), findsOneWidget);
    expect(find.byKey(const ValueKey('product-quantity')), findsOneWidget);
    expect(find.text('สินค้าทั้งหมด'), findsOneWidget);

    final image = tester.getRect(
      find.byKey(const ValueKey('product-detail-image')),
    );
    final title = tester.getRect(find.text('Product Name'));
    expect(image.height, closeTo(image.width / 1.52, 1));
    expect(title.top, greaterThan(image.bottom));
  });

  testWidgets('desktop product details sit beside the image', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: ProductDetailPage(apiProduct: createProduct())),
    );

    final image = tester.getRect(
      find.byKey(const ValueKey('product-detail-image')),
    );
    final title = tester.getRect(find.text('Product Name'));
    expect(image.width, greaterThan(400));
    expect(image.height, closeTo(image.width, 1));
    expect(title.left, greaterThan(image.right));
  });

  testWidgets('tapping a product card opens its detail page', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 220,
            height: 380,
            child: ProductCard(apiProduct: createProduct()),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ProductCard));
    await tester.pumpAndSettle();

    expect(find.byType(ProductDetailPage), findsOneWidget);
    expect(find.text('Product Name'), findsOneWidget);
    expect(find.text('1,250 ฿'), findsOneWidget);
  });

  testWidgets('invalid quantity is rejected with a message', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: ProductDetailPage(apiProduct: createProduct())),
    );
    await tester.enterText(find.byKey(const ValueKey('product-quantity')), '0');
    await tester.ensureVisible(find.text('ซื้อสินค้า').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ซื้อสินค้า').first);
    await tester.pump();

    expect(find.text('กรุณาระบุจำนวนสินค้าอย่างน้อย 1 ชิ้น'), findsOneWidget);
  });
}
