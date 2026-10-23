import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/appUI/cart_page.dart';
import 'package:project/data/callapi.dart';
import 'package:project/data/cart.dart';
import 'package:project/data/product.dart';
import 'package:project/data/user.dart';

void main() {
  final cart = CartStore.instance;

  Product createProduct(int id, String name, num price, {num? proPrice}) =>
      Product.fromJson({
        'id': id,
        'product_id': 'P$id',
        'product_name': name,
        'product_brand': 'Brand',
        'price': price,
        'pro_price': proPrice,
      });

  UserItem member(int id, {String? address, String? paymentMethod}) =>
      UserItem.fromJson({
        'id': id,
        'member_id': '0000000$id',
        'username': 'user$id',
        'phonenumber': '081000000$id',
        'address': address,
        'payment_method': paymentMethod,
      });

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    AuthService.currentUser.value = null;
    cart.clear();
    cart.add(createProduct(1, 'สว่านไร้สาย 12V', 3290));
    cart.add(createProduct(2, 'สีทาภายใน TOA', 1890));
    cart.add(createProduct(3, 'ตลับเมตร STANLEY', 600, proPrice: 550));
  });

  Future<void> pumpCart(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: CartPage()));
  }

  test('totals apply promotion prices and follow selection', () {
    expect(cart.subtotal, 3290 + 1890 + 600);
    expect(cart.discount, 50);
    expect(cart.total, 5730);

    cart.toggle(cart.items.first, false);
    expect(cart.total, 2440);

    cart.add(createProduct(2, 'สีทาภายใน TOA', 1890));
    expect(cart.items, hasLength(3));
    expect(cart.items[1].quantity, 2);
  });

  testWidgets('desktop cart shows items and summary', (tester) async {
    await pumpCart(tester, const Size(1440, 1400));

    expect(find.text('ตะกร้าสินค้า'), findsOneWidget);
    expect(find.text('สว่านไร้สาย 12V'), findsOneWidget);
    expect(find.text('5,730 บาท', findRichText: true), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pump();
    expect(find.text('9,020 บาท', findRichText: true), findsOneWidget);
  });

  testWidgets('mobile cart lays out without overflow', (tester) async {
    await pumpCart(tester, const Size(390, 2400));

    expect(find.text('สรุปคำสั่งซื้อ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('per-account data', () {
    setUp(cart.clear);

    Future<void> loginAs(UserItem? user) async {
      AuthService.currentUser.value = user;
      await cart.pendingWork;
    }

    test('cart, address and payment are restored for the same account',
        () async {
      await loginAs(member(1));
      cart.add(createProduct(1, 'สว่านไร้สาย 12V', 3290), quantity: 2);
      cart.setAddress(' 99 ถ.สุขุมวิท กรุงเทพฯ ');
      cart.setPaymentMethod(PaymentMethod.scb);
      cart.setDeliveryMethod(DeliveryMethod.storePickup);
      await cart.pendingWork;

      await loginAs(null);
      expect(cart.items, isEmpty);
      expect(cart.address, isNull);

      await loginAs(member(2));
      expect(cart.items, isEmpty);
      expect(cart.paymentMethod, isNull);

      await loginAs(member(1));
      expect(cart.items, hasLength(1));
      expect(cart.items.single.product.productName, 'สว่านไร้สาย 12V');
      expect(cart.items.single.quantity, 2);
      expect(cart.address, '99 ถ.สุขุมวิท กรุงเทพฯ');
      expect(cart.paymentMethod, PaymentMethod.scb);
      expect(cart.deliveryMethod, DeliveryMethod.storePickup);
    });

    test('guest items are merged into the account on login', () async {
      await loginAs(member(3));
      cart.add(createProduct(1, 'สว่านไร้สาย 12V', 3290));
      await cart.pendingWork;
      await loginAs(null);

      cart.add(createProduct(1, 'สว่านไร้สาย 12V', 3290));
      cart.add(createProduct(2, 'สีทาภายใน TOA', 1890));
      await loginAs(member(3));

      expect(cart.items, hasLength(2));
      expect(cart.totalQuantity, 3);
    });

    test('profile address and payment are used until changed', () async {
      await loginAs(
        member(4, address: '1 ถ.พหลโยธิน', paymentMethod: 'PromptPay'),
      );
      expect(cart.address, '1 ถ.พหลโยธิน');
      expect(cart.paymentMethod, PaymentMethod.promptPay);
    });
  });
}
