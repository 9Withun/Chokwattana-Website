import 'dart:async';

import 'package:flutter/material.dart';
import 'package:project/appUI/login_page.dart';
import 'package:project/data/banner.dart';
import 'package:project/data/callapi.dart';
import 'package:project/data/product.dart';
import 'package:project/data/user.dart';
import 'package:project/models/product_model.dart';
import 'package:project/process/process.dart';

class HomeTopBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeTopBar({super.key, this.showNavigation = true});

  static const _green = Color(0xFF159B12);
  static const _yellow = Color(0xFFFFE500);

  final bool showNavigation;

  static const double desktopHeight = 141;
  static const double mobileHeight = 124;

  static double heightFor(double width) =>
      width < HomeContentContainer.compactBreakpoint
      ? mobileHeight
      : desktopHeight;

  /// Width-aware app bar used by every page so they share one top bar.
  static PreferredSizeWidget appBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(
        heightFor(MediaQuery.sizeOf(context).width),
      ),
      child: const HomeTopBar(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(desktopHeight);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _green,
      elevation: 2,
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact =
                constraints.maxWidth < HomeContentContainer.compactBreakpoint;
            return isCompact
                ? _MobileHeader(showNavigation: showNavigation)
                : const _DesktopHeader();
          },
        ),
      ),
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1255),
        child: Column(
          children: [
            SizedBox(
              height: 101,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const _BrandLogo(width: 220, height: 96),
                    const SizedBox(width: 35),
                    const Expanded(child: _SearchBox(compact: false)),
                    const SizedBox(width: 24),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _AccountButton(compact: false),
                                SizedBox(width: 14),
                                _LanguageSwitch(),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'ติดต่อโครงการ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                _CartButton(size: 60),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40, child: _DesktopNavigation()),
          ],
        ),
      ),
    );
  }
}

class _LanguageSwitch extends StatelessWidget {
  const _LanguageSwitch();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'ไทย',
          style: TextStyle(
            color: Color(0xFF1B1B8F),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(' | ', style: TextStyle(color: Colors.black87)),
        Text(
          'EN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _MobileHeader extends StatelessWidget {
  const _MobileHeader({required this.showNavigation});

  final bool showNavigation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: showNavigation ? 124 : 100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 380;
            final menuSize = isNarrow ? 30.0 : 36.0;
            final cartSize = isNarrow ? 58.0 : 68.0;
            return Row(
              children: [
                SizedBox(
                  width: menuSize,
                  child: const Icon(Icons.menu, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 0),
                _BrandLogo(width: isNarrow ? 67 : 86, height: 46),
                const SizedBox(width: 6),
                const Expanded(child: _SearchBox(compact: true)),
                const SizedBox(width: 4),
                const _AccountButton(compact: true),
                _CartButton(size: cartSize),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Shows "เข้าสู่ระบบ" when logged out, or the member's name with a logout
/// menu when logged in.
class _AccountButton extends StatelessWidget {
  const _AccountButton({required this.compact});

  final bool compact;

  Future<void> _openLogin(BuildContext context) {
    return Navigator.of(context)
        .push(MaterialPageRoute<bool>(builder: (_) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserItem?>(
      valueListenable: AuthService.currentUser,
      builder: (context, user, _) {
        if (user == null) {
          return compact
              ? IconButton(
                  key: const ValueKey('account-login'),
                  tooltip: 'เข้าสู่ระบบ',
                  onPressed: () => _openLogin(context),
                  icon: const Icon(Icons.person_outline, color: Colors.white),
                )
              : InkWell(
                  key: const ValueKey('account-login'),
                  onTap: () => _openLogin(context),
                  child: const Text(
                    'เข้าสู่ระบบ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
        }
        return PopupMenuButton<String>(
          key: const ValueKey('account-menu'),
          tooltip: user.username,
          onSelected: (_) => AuthService.logout(),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'logout', child: Text('ออกจากระบบ')),
          ],
          child: compact
              ? const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.person, color: Colors.white),
                )
              : ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Text(
                    user.username,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo({this.width = 154, this.height = 62});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
      child: SizedBox(
        width: width,
        height: height,
        child: Image.asset('lib/Images/Logo.png', fit: BoxFit.contain),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 44 : 52,
      child: TextField(
        style: const TextStyle(color: Colors.black87, fontSize: 17),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'ซื้อสินค้า, สิ่งที่อยากได้',
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18),
          suffixIcon: Container(
            width: compact ? 52 : 68,
            decoration: const BoxDecoration(
              color: HomeTopBar._yellow,
              borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
            ),
            child: const Icon(Icons.search, color: Colors.black54, size: 34),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton({this.size = 58});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.shopping_cart_outlined,
            color: Colors.white,
            size: size * 0.55,
          ),
        ),
        Positioned(
          right: -3,
          top: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '0',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DesktopNavigation extends StatefulWidget {
  const _DesktopNavigation();

  @override
  State<_DesktopNavigation> createState() => _DesktopNavigationState();
}

class _DesktopNavigationState extends State<_DesktopNavigation> {
  bool _isCategoryMenuOpen = false;
  final GlobalKey _categoryMenuButtonKey = GlobalKey();

  void _onCategorySelected(String categoryName) {
    setState(() {
      _isCategoryMenuOpen = false;
    });

    final products = CategoryMenuProcess.productsForCategory(categoryName);
    if (!mounted) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            CategoryProductPage(categoryName: categoryName, products: products),
      ),
    );
  }

  Future<void> _showCategoryMenu() async {
    final buttonContext = _categoryMenuButtonKey.currentContext;
    final renderObject = buttonContext?.findRenderObject();
    if (renderObject is! RenderBox) return;

    setState(() => _isCategoryMenuOpen = true);
    final screenSize = MediaQuery.sizeOf(context);
    final menuWidth = screenSize.width < 436 ? screenSize.width - 16 : 420.0;
    final selectedCategory = await showMenu<String>(
      context: context,
      position: CategoryMenuProcess.getMenuPosition(context, renderObject),
      constraints: BoxConstraints(
        minWidth: menuWidth,
        maxWidth: menuWidth,
        maxHeight: screenSize.height * 0.72,
      ),
      items: CategoryMenuProcess.buildMenuItems(),
    );

    if (!mounted) return;
    setState(() => _isCategoryMenuOpen = false);
    if (selectedCategory != null) {
      _onCategorySelected(selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 37),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: 230,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _CategoryMenuButton(
                  key: _categoryMenuButtonKey,
                  isOpen: _isCategoryMenuOpen,
                  onTap: _showCategoryMenu,
                ),
              ),
            ),
            const _NavigationItem(label: 'สินค้าตามแบรนด์', width: 234),
            const _NavigationItem(label: 'สินค้าตามห้อง', width: 201),
            const _NavigationItem(label: 'สินค้าClearance', width: 220),
          ],
        ),
      ),
    );
  }
}

class _CategoryMenuButton extends StatelessWidget {
  const _CategoryMenuButton({
    super.key,
    required this.isOpen,
    required this.onTap,
  });

  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.grid_view, color: Colors.white, size: 22),
          const SizedBox(width: 4),
          const Flexible(
            child: Text(
              'หมวดหมู่สินค้า',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Icon(
            isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: Colors.white,
            size: 28,
          ),
        ],
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({required this.label, required this.width});

  final String label;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.white, size: 28),
        ],
      ),
    );
  }
}

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({
    super.key,
    required this.banners,
    required this.aspectRatio,
  });

  final List<BannerItem> banners;
  final double aspectRatio;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  static const _autoAdvanceInterval = Duration(seconds: 5);
  static const _transitionDuration = Duration(milliseconds: 450);

  late final PageController _pageController;
  Timer? _autoAdvanceTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoAdvance();
  }

  @override
  void didUpdateWidget(covariant BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) {
      _startAutoAdvance();
    }
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    if (widget.banners.length < 2) return;

    _autoAdvanceTimer = Timer.periodic(_autoAdvanceInterval, (_) {
      if (!_pageController.hasClients) return;
      final nextPage = (_currentPage + 1) % widget.banners.length;
      _pageController.animateToPage(
        nextPage,
        duration: _transitionDuration,
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.banners.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final banner = widget.banners[index];
                return Image.network(
                  banner.imageUrl,
                  fit: BoxFit.cover,
                  semanticLabel: banner.name,
                  errorBuilder: (_, _, _) => const ColoredBox(
                    color: Color(0xFFE5E7EB),
                    child: Center(
                      child: Icon(Icons.broken_image_outlined, size: 36),
                    ),
                  ),
                );
              },
            ),
            if (widget.banners.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: _BannerPageIndicators(
                  count: widget.banners.length,
                  currentPage: _currentPage,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BannerPageIndicators extends StatelessWidget {
  const _BannerPageIndicators({required this.count, required this.currentPage});

  final int count;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          count,
          (index) => Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: index == currentPage ? Colors.white : Colors.white54,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class HomeContentContainer extends StatelessWidget {
  const HomeContentContainer({super.key, required this.child});

  static const maxWidth = 1280.0;
  static const compactBreakpoint = 900.0;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: SizedBox(
            width: constraints.maxWidth < maxWidth
                ? constraints.maxWidth
                : maxWidth,
            child: child,
          ),
        );
      },
    );
  }
}

class BannerCardLayout extends StatefulWidget {
  const BannerCardLayout({super.key, this.bannersFuture});

  final Future<List<BannerItem>>? bannersFuture;

  @override
  State<BannerCardLayout> createState() => _BannerCardLayoutState();
}

class _BannerCardLayoutState extends State<BannerCardLayout> {
  late Future<List<BannerItem>> _bannersFuture;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  void _loadBanners() {
    _bannersFuture = widget.bannersFuture ?? BannerService.fetchBanners();
  }

  void _retry() {
    setState(_loadBanners);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BannerItem>>(
      future: _bannersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(48),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text('โหลดแบนเนอร์ไม่สำเร็จ'),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
                const SizedBox(height: 8),
                OutlinedButton(onPressed: _retry, child: const Text('ลองใหม่')),
              ],
            ),
          );
        }

        return _buildBannerLayout(snapshot.data ?? const []);
      },
    );
  }

  Widget _buildBannerLayout(List<BannerItem> banners) {
    final portraitBanners = _bannersWithAlign(banners, 'Portrait');
    final landscapeGroups = _landscapeGroups(banners);
    final squareBanners = _bannersWithAlign(banners, '1:1');

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            constraints.maxWidth < HomeContentContainer.compactBreakpoint;
        final landscapeContent = Column(
          children: [
            for (final entry in landscapeGroups.entries) ...[
              if (entry.key != landscapeGroups.keys.first)
                const SizedBox(height: 12),
              BannerCarousel(
                key: ValueKey('home-banner-${entry.key}'),
                banners: entry.value,
                aspectRatio: 4,
              ),
            ],
            if (squareBanners.isNotEmpty) ...[
              const SizedBox(height: 24),
              PromotionCarousel(
                key: const ValueKey('home-promotion-carousel'),
                banners: squareBanners,
              ),
            ],
            if (landscapeGroups.isEmpty && squareBanners.isEmpty)
              const Center(child: Text('ยังไม่มีแบนเนอร์ที่ใช้งานอยู่')),
          ],
        );

        if (isCompact) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              constraints.maxWidth < 500 ? 16 : 24,
              8,
              constraints.maxWidth < 500 ? 16 : 24,
              0,
            ),
            child: landscapeContent,
          );
        }

        if (portraitBanners.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: landscapeContent,
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: BannerCarousel(
                  key: const ValueKey('home-banner-vertical'),
                  banners: portraitBanners,
                  aspectRatio: 0.5,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(flex: 5, child: landscapeContent),
            ],
          ),
        );
      },
    );
  }

  List<BannerItem> _bannersWithAlign(List<BannerItem> banners, String align) {
    return banners.where((banner) => banner.align == align).toList();
  }

  Map<String, List<BannerItem>> _landscapeGroups(List<BannerItem> banners) {
    final groups = <String, List<BannerItem>>{};
    for (final banner in banners.where(
      (banner) => banner.align == 'Landscape',
    )) {
      groups.putIfAbsent(banner.type, () => []).add(banner);
    }
    return groups;
  }
}

class PromotionCarousel extends StatefulWidget {
  const PromotionCarousel({super.key, required this.banners});

  final List<BannerItem> banners;

  @override
  State<PromotionCarousel> createState() => _PromotionCarouselState();
}

class _PromotionCarouselState extends State<PromotionCarousel> {
  final _scrollController = ScrollController();
  bool _canScrollPrevious = false;
  bool _canScrollNext = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateArrowVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateArrowVisibility();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateArrowVisibility);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateArrowVisibility() {
    if (!_scrollController.hasClients) {
      return;
    }

    final canScrollPrevious = PromotionCarouselProcess.canScrollPrevious(
      _scrollController.offset,
    );
    final canScrollNext = PromotionCarouselProcess.canScrollNext(
      _scrollController.offset,
      _scrollController.position.maxScrollExtent,
    );

    if (canScrollPrevious == _canScrollPrevious &&
        canScrollNext == _canScrollNext) {
      return;
    }

    if (mounted) {
      setState(() {
        _canScrollPrevious = canScrollPrevious;
        _canScrollNext = canScrollNext;
      });
    }
  }

  void _showNextCard(double cardWidth) {
    _scrollController.animateTo(
      PromotionCarouselProcess.nextOffset(
        _scrollController.offset,
        cardWidth,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _showPreviousCard(double cardWidth) {
    _scrollController.animateTo(
      PromotionCarouselProcess.previousOffset(
        _scrollController.offset,
        cardWidth,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth < 500
            ? constraints.maxWidth * 0.44
            : (constraints.maxWidth * 0.28).clamp(150.0, 220.0);

        return Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 68, bottom: 22),
              child: Row(
                children: [
                  for (
                    var index = 0;
                    index < widget.banners.length;
                    index++
                  ) ...[
                    if (index > 0) const SizedBox(width: 8),
                    _promotionCard(cardWidth, widget.banners[index]),
                  ],
                ],
              ),
            ),
            if (_canScrollPrevious)
              Positioned(
                left: 0,
                top: cardWidth * 0.34,
                child: Material(
                  color: Colors.white,
                  elevation: 3,
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: 'ดูโปรโมชั่นก่อนหน้า',
                    onPressed: () => _showPreviousCard(cardWidth),
                    icon: const Icon(Icons.chevron_left, size: 42),
                  ),
                ),
              ),
            if (_canScrollNext)
              Positioned(
                right: 0,
                top: cardWidth * 0.34,
                child: Material(
                  color: Colors.white,
                  elevation: 3,
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: 'ดูโปรโมชั่นถัดไป',
                    onPressed: () => _showNextCard(cardWidth),
                    icon: const Icon(Icons.chevron_right, size: 42),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _promotionCard(double width, BannerItem banner) {
    return SizedBox(
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          banner.imageUrl,
          width: width,
          height: width,
          fit: BoxFit.cover,
          semanticLabel: banner.name,
          errorBuilder: (_, _, _) => const ColoredBox(
            color: Color(0xFFE5E7EB),
            child: Center(child: Icon(Icons.broken_image_outlined, size: 36)),
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, this.product, this.apiProduct});

  static const _imageBackgroundColor = Color(0xFFFFFFFF);

  final ProductItem? product;
  final Product? apiProduct;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 700;
    final item = product;
    final remoteItem = apiProduct;
    final productName =
        remoteItem?.productName ?? item?.name ?? 'PD-Name && detail';
    final productDetail = remoteItem?.productDetail ?? item?.description ?? '';
    final productPrice = remoteItem?.price ?? item?.price ?? 0;
    final productImage = remoteItem?.imageUrl ?? '';

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                ProductDetailPage(product: item, apiProduct: remoteItem),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade400, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x44000000),
              blurRadius: 8,
              offset: Offset(3, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Container(
                key: const ValueKey('product-card-image'),
                width: double.infinity,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _imageBackgroundColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child: productImage.isEmpty
                    ? Center(
                        child: Text(
                          'Product Image',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'serif',
                            fontSize: isCompact ? 18 : 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Image.network(
                        productImage,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'serif',
                        fontSize: isCompact ? 13 : 15,
                        fontWeight: FontWeight.bold,
                        height: 1.12,
                      ),
                    ),
                    if (productDetail.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Expanded(
                        child: Text(
                          productDetail,
                          maxLines: isCompact ? 3 : 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'serif',
                            fontSize: isCompact ? 11 : 13,
                            fontWeight: FontWeight.bold,
                            height: 1.12,
                          ),
                        ),
                      ),
                    ] else
                      const Spacer(),
                    Text(
                      '${_formatPrice(productPrice)} ฿',
                      style: TextStyle(
                        color: Color(0xFFD88A00),
                        fontFamily: 'serif',
                        fontSize: isCompact ? 17 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, this.product, this.apiProduct})
    : assert(product != null || apiProduct != null);

  final ProductItem? product;
  final Product? apiProduct;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedImage = 0;

  static const _pageBackground = Color(0xFFEEEEEE);
  static const _panelBackground = Color(0xFFF0F0F0);
  static const _brandGreen = Color(0xFF159B12);
  static const _priceOrange = Color(0xFFE59A00);
  static const _messengerBlue = Color(0xFF0866FF);

  Product? get _apiProduct => widget.apiProduct;
  ProductItem? get _product => widget.product;

  String get _name =>
      _apiProduct?.productName ?? _product?.name ?? 'Product Name';
  String get _brand => _apiProduct?.productBrand ?? '';
  String get _detail =>
      _apiProduct?.productDetail ?? _product?.description ?? '';
  double get _price => _apiProduct?.price ?? _product?.price ?? 0;
  List<String> get _imageUrls {
    final remoteProduct = _apiProduct;
    if (remoteProduct == null) return const [];

    final images = [...remoteProduct.images]
      ..sort((a, b) {
        if (a.isPrimary != b.isPrimary) return a.isPrimary ? -1 : 1;
        return a.sortOrder.compareTo(b.sortOrder);
      });
    final urls = images
        .map((image) => image.imageUrl)
        .where((url) => url.isNotEmpty)
        .toList();
    if (urls.isEmpty && remoteProduct.imageUrl.isNotEmpty) {
      urls.add(remoteProduct.imageUrl);
    }
    return urls;
  }

  int? get _stock => _apiProduct?.stock;

  void _showPurchaseMessage({required bool orderNow}) {
    final stock = _stock;
    if (stock != null && stock < 1) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('สินค้าหมด')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          orderNow
              ? 'เลือกสั่งซื้อ $_name แล้ว'
              : 'เพิ่ม $_name ไปยังรถเข็นแล้ว',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompact =
        MediaQuery.sizeOf(context).width <
        HomeContentContainer.compactBreakpoint;

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: HomeTopBar.appBar(context),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1444),
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.fromLTRB(
                      isCompact ? 8 : 12,
                      isCompact ? 4 : 16,
                      isCompact ? 8 : 12,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isCompact)
                          _buildMobileProductContent()
                        else
                          _buildDesktopProductContent(),
                        SizedBox(height: isCompact ? 48 : 48),
                        _buildBrandSection(isCompact),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!isCompact)
            Positioned(
              right: 16,
              bottom: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _messengerBlue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'สอบถามเพิ่มเติม',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildMessengerButton(size: 56),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessengerButton({required double size}) {
    return Material(
      color: _messengerBlue,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ติดต่อสอบถามเพิ่มเติม')),
          );
        },
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(Icons.messenger, color: Colors.white, size: size * 0.55),
        ),
      ),
    );
  }

  Widget _buildDesktopProductContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 570, child: _buildGallery(compact: false)),
        const SizedBox(width: 12),
        Expanded(flex: 698, child: _buildProductInformation(compact: false)),
        const Spacer(flex: 147),
      ],
    );
  }

  Widget _buildMobileProductContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildGallery(compact: true),
        const SizedBox(height: 24),
        _buildProductInformation(compact: true),
      ],
    );
  }

  Widget _buildGallery({required bool compact}) {
    final urls = _imageUrls;
    return Column(
      children: [
        AspectRatio(
          aspectRatio: compact ? 1.55 : 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _ProductPhoto(
                key: const ValueKey('product-detail-image'),
                imageUrl: urls.isEmpty ? null : urls[_selectedImage],
                label: 'Product Image',
              ),
              if (compact)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      urls.isEmpty ? 5 : urls.length,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: GestureDetector(
                          onTap: () {
                            if (urls.isNotEmpty) {
                              setState(() => _selectedImage = index);
                            }
                          },
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: index == _selectedImage
                                  ? Colors.grey.shade500
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black87,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (compact)
          const SizedBox.shrink()
        else if (urls.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: List.generate(
                urls.length > 6 ? 6 : urls.length,
                (index) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedImage = index),
                    child: Container(
                      height: 66,
                      margin: EdgeInsets.only(right: index == 5 ? 0 : 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: index == _selectedImage
                              ? _brandGreen
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Image.network(
                        urls[index],
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        else if (!compact)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: List.generate(
                6,
                (_) => const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _ProductPhoto(label: ''),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductInformation({required bool compact}) {
    final detailLines = _detail
        .split(RegExp(r'[\n\r]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                _name,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: compact ? 21 : 34,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
            if (compact) _buildMessengerButton(size: 42),
          ],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: compact ? 0.42 : 1,
            child: Container(
              height: compact ? 50 : 100,
              padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 18),
              alignment: Alignment.centerLeft,
              color: _panelBackground,
              child: Text(
                '${_formatPrice(_price)} ฿',
                style: TextStyle(
                  color: _priceOrange,
                  fontFamily: 'serif',
                  fontSize: compact ? 26 : 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: compact ? 6 : 12),
        Container(
          height: compact ? 109 : 425,
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          color: _panelBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detail',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: detailLines.isEmpty
                    ? const SizedBox.shrink()
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: detailLines.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(left: 34, bottom: 2),
                          child: Text(
                            detailLines[index],
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 15,
                              height: 1.15,
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          children: [
            Text(
              'จำนวนสินค้าคงเหลือ',
              style: TextStyle(
                fontSize: compact ? 20 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              key: const ValueKey('product-quantity'),
              width: compact ? 90 : 64,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black26),
              ),
              child: Text(
                _stock?.toString() ?? '-',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Text(
              'ชิ้น',
              style: TextStyle(
                fontSize: compact ? 20 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: compact ? double.infinity : 394,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showPurchaseMessage(orderNow: false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _brandGreen,
                      side: const BorderSide(color: _brandGreen),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      minimumSize: Size(0, compact ? 58 : 57),
                    ),
                    child: const Text(
                      'เพิ่มไปยังรถเข็น',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _showPurchaseMessage(orderNow: true),
                    style: FilledButton.styleFrom(
                      backgroundColor: _brandGreen,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      minimumSize: Size(0, compact ? 58 : 57),
                    ),
                    child: const Text(
                      'ซื้อสินค้า',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandSection(bool compact) {
    return Row(
      children: [
        SizedBox(
          width: compact ? 132 : 132,
          height: compact ? 132 : 132,
          child: const _ProductPhoto(label: 'logo Brand'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _brand.isEmpty ? 'Brand' : _brand,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: compact ? 34 : 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('กำลังแสดงสินค้าทั้งหมด')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.grey.shade400),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Text(
                  'สินค้าทั้งหมด',
                  style: TextStyle(
                    fontSize: compact ? 20 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductPhoto extends StatelessWidget {
  const _ProductPhoto({super.key, this.imageUrl, required this.label});

  final String? imageUrl;
  final String label;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return CustomPaint(
      painter: _PhotoPlaceholderPainter(),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _PhotoPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF111111)
      ..strokeWidth = 1;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFD9D9D9),
    );
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _PhotoPlaceholderPainter oldDelegate) => false;
}

String _formatPrice(double price) {
  final integerPrice = price.toInt();
  final sign = integerPrice < 0 ? '-' : '';
  final digits = integerPrice.abs().toString();
  final groupedDigits = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '$sign$groupedDigits';
}

class ApiProductSection extends StatefulWidget {
  const ApiProductSection({super.key, this.productsFuture});

  final Future<List<Product>>? productsFuture;

  @override
  State<ApiProductSection> createState() => _ApiProductSectionState();
}

class _ApiProductSectionState extends State<ApiProductSection> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    _productsFuture = widget.productsFuture ?? ProductService.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text('โหลดข้อมูลสินค้าไม่สำเร็จ'),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    setState(_loadProducts);
                  },
                  child: const Text('ลองใหม่'),
                ),
              ],
            ),
          );
        }

        final products = snapshot.data ?? const <Product>[];
        if (products.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('ไม่พบข้อมูลสินค้า')),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 700;
            final horizontalPadding = isMobile ? 16.0 : 24.0;
            return GridView.builder(
              key: ValueKey(
                isMobile ? 'mobile-product-grid' : 'desktop-product-grid',
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 12,
              ),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                childAspectRatio: isMobile ? 0.58 : 0.62,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) =>
                  ProductCard(apiProduct: products[index]),
            );
          },
        );
      },
    );
  }
}

class CategoryProductPage extends StatefulWidget {
  const CategoryProductPage({
    super.key,
    required this.categoryName,
    required this.products,
  });

  final String categoryName;
  final List<ProductItem> products;

  @override
  State<CategoryProductPage> createState() => _CategoryProductPageState();
}

class _CategoryProductPageState extends State<CategoryProductPage> {
  late final Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeTopBar.appBar(context),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.categoryName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return _buildProductGrid(apiProducts: snapshot.data!);
                }

                return _buildProductGrid(staticProducts: widget.products);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid({
    List<Product>? apiProducts,
    List<ProductItem>? staticProducts,
  }) {
    final itemCount = apiProducts?.length ?? staticProducts?.length ?? 0;
    if (itemCount == 0) {
      return const Center(child: Text('ไม่มีสินค้าในหมวดนี้'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (apiProducts != null) {
          return ProductCard(apiProduct: apiProducts[index]);
        }
        return ProductCard(product: staticProducts![index]);
      },
    );
  }
}
