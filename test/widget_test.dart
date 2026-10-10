// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project/main.dart';
import 'package:project/appUI/ui.dart';

void main() {
  testWidgets('Category menu opens when tapping category item', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());

    expect(find.text('หมวดหมู่สินค้า'), findsOneWidget);

    await tester.tap(find.text('หมวดหมู่สินค้า'));
    await tester.pumpAndSettle();

    expect(find.text('วัสดุก่อสร้าง'), findsWidgets);
    expect(find.text('อุปกรณ์ตกแต่งบ้าน'), findsOneWidget);
  });

  testWidgets('Selecting a category navigates to that category page', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('หมวดหมู่สินค้า'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('อุปกรณ์ตกแต่งบ้าน'));
    await tester.pumpAndSettle();

    expect(find.byType(CategoryProductPage), findsOneWidget);
    expect(find.text('อุปกรณ์ตกแต่งบ้าน'), findsOneWidget);
  });
}
