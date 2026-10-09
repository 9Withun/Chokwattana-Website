import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/appUI/ui.dart';
import 'package:project/data/banner.dart';

void main() {
  final banners = [
    _banner(1, 'Portrait', 'Ads'),
    _banner(2, 'Landscape', 'Product'),
    _banner(3, 'Landscape', 'Product'),
    _banner(4, 'Landscape', 'Product'),
    _banner(5, 'Landscape', 'Ads'),
    _banner(6, '1:1', 'Product'),
    _banner(7, '1:1', 'Product'),
    _banner(8, '1:1', 'Ads'),
  ];

  testWidgets('home content is centered with a desktop max width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1365, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox.expand(
          child: HomeContentContainer(
            child: SizedBox(key: const ValueKey('home-content'), height: 10),
          ),
        ),
      ),
    );

    final content = tester.getRect(find.byKey(const ValueKey('home-content')));
    expect(content.width, HomeContentContainer.maxWidth);
    expect(content.left, closeTo((1365 - HomeContentContainer.maxWidth) / 2, 1));
  });

  testWidgets('home content uses available width on mobile', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox.expand(
          child: HomeContentContainer(
            child: SizedBox(key: const ValueKey('home-content'), height: 10),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('home-content'))).width,
      390,
    );
  });

  testWidgets('banner advances automatically and loops back to the first', (
    tester,
  ) async {
    final carouselBanners = [
      _banner(20, 'Landscape', 'Ads'),
      _banner(21, 'Landscape', 'Ads'),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 400,
            child: BannerCarousel(
              banners: carouselBanners,
              aspectRatio: 4,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final pageController = tester
        .widget<PageView>(find.byType(PageView))
        .controller!;
    expect(pageController.page, 0);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 500));
    expect(pageController.page, closeTo(1, 0.01));

    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 500));
    expect(pageController.page, closeTo(0, 0.01));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('desktop displays API banners grouped by image alignment', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: SingleChildScrollView(
          child: BannerCardLayout(bannersFuture: Future.value(banners)),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('home-banner-vertical')), findsOneWidget);
    final portraitSize = tester.getSize(
      find.byKey(const ValueKey('home-banner-vertical')),
    );
    expect(portraitSize.height, closeTo(portraitSize.width * 2, 1));
    expect(find.byKey(const ValueKey('home-banner-Ads')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-banner-Product')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('home-promotion-carousel')),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is BannerCarousel && widget.banners.length == 3,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is PromotionCarousel && widget.banners.length == 3,
      ),
      findsOneWidget,
    );
  });

  testWidgets('mobile displays landscape and square API banners', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: SingleChildScrollView(
          child: BannerCardLayout(bannersFuture: Future.value(banners)),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('home-banner-vertical')), findsNothing);
    expect(find.byKey(const ValueKey('home-banner-Ads')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-banner-Product')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('home-promotion-carousel')),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is BannerCarousel && widget.banners.length == 3,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is PromotionCarousel && widget.banners.length == 3,
      ),
      findsOneWidget,
    );
  });

  testWidgets('tablet uses full-width banners and smaller promotion cards', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(768, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: SingleChildScrollView(
          child: BannerCardLayout(bannersFuture: Future.value(banners)),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('home-banner-vertical')), findsNothing);
    final promotionImage = find.descendant(
      of: find.byKey(const ValueKey('home-promotion-carousel')),
      matching: find.byType(Image),
    ).first;
    final promotionSize = tester.getSize(promotionImage);
    expect(promotionSize.width, greaterThan(150));
    expect(promotionSize.width, lessThan(220));
  });
}

BannerItem _banner(int id, String align, String type) {
  return BannerItem(
    id: id,
    name: 'Banner $id',
    align: align,
    type: type,
    imageUrl: 'https://example.test/banner-$id.png',
    dateStart: '2026-10-07',
    dateEnd: null,
  );
}
