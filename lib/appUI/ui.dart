import 'package:flutter/material.dart';
import 'package:project/data/callapi.dart';
import 'package:project/data/product.dart';
import 'package:project/models/product_model.dart';
import 'package:project/process/process.dart';

class HomeTopBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeTopBar({super.key});

  static const _green = Color(0xFF159B12);
  static const _yellow = Color(0xFFFFE500);

  @override
  Size get preferredSize => const Size.fromHeight(122);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _green,
      elevation: 2,
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 700;
            return isCompact ? const _MobileHeader() : const _DesktopHeader();
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
    return Column(
      children: [
        SizedBox(
          height: 70,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Row(
              children: [
                const _BrandLogo(),
                const SizedBox(width: 28),
                const Expanded(child: _SearchBox(compact: false)),
                const SizedBox(width: 34),
                const Text(
                  'เข้าสู่ระบบ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 20),
                const _CartButton(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 52, child: _DesktopNavigation()),
      ],
    );
  }
}

class _MobileHeader extends StatelessWidget {
  const _MobileHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 124,
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
                _BrandLogo(
                  width: isNarrow ? 67 : 86,
                  height: 46,
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: _SearchBox(compact: true),
                ),
                const SizedBox(width: 8),
                _CartButton(size: cartSize),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo({this.width = 154, this.height = 62});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Image.asset(
        'lib/Images/Logo.png',
        fit: BoxFit.contain,
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
      height: 44,
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
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
        builder: (_) => CategoryProductPage(
          categoryName: categoryName,
          products: products,
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            height: 52,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _CategoryMenuButton(
                    key: _categoryMenuButtonKey,
                    isOpen: _isCategoryMenuOpen,
                    onTap: _showCategoryMenu,
                  ),
                  const _NavigationItem(label: 'สินค้าตามแบรนด์V'),
                  const _NavigationItem(label: 'สินค้าตามห้องV'),
                  const _NavigationItem(label: 'สินค้า ClearanceV'),
                  const _NavigationItem(label: 'ติดต่อโครงการ'),
                ],
              ),
            ),
          ),
        ],
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.grid_view, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'หมวดหมู่สินค้า',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 38),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class BannerCard extends StatelessWidget {
  const BannerCard({
    super.key,
    required this.label,
    required this.aspectRatio,
    this.fontSize = 20,
  });

  final String label;
  final double aspectRatio;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFD0D0D0),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade500),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ).copyWith(fontSize: fontSize),
        ),
      ),
    );
  }
}

class BannerCardLayout extends StatelessWidget {
  const BannerCardLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        const horizontalAspectRatio = 4.0;
        const verticalAspectRatio = 0.4;

        if (isMobile) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Column(
              children: [
                BannerCard(
                  label: 'BANNER โฆษณา',
                  aspectRatio: horizontalAspectRatio,
                ),
                SizedBox(height: 8),
                BannerCard(
                  label: 'BANNER สินค้า',
                  aspectRatio: horizontalAspectRatio,
                ),
                SizedBox(height: 8),
                BannerCard(
                  label: 'BANNER สินค้า',
                  aspectRatio: horizontalAspectRatio,
                ),
                SizedBox(height: 8),
                BannerCard(
                  label: 'Event & เงื่อนไขเข้าร่วม',
                  aspectRatio: horizontalAspectRatio,
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                flex: 2,
                child: BannerCard(
                  label: 'BANNER แนวตั้ง',
                  aspectRatio: verticalAspectRatio,
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                flex: 5,
                child: Column(
                  children: const [
                    BannerCard(
                      label: 'BANNER โฆษณา',
                      aspectRatio: horizontalAspectRatio,
                    ),
                    SizedBox(height: 12),
                    BannerCard(
                      label: 'BANNER สินค้า',
                      aspectRatio: horizontalAspectRatio,
                    ),
                    SizedBox(height: 12),
                    BannerCard(
                      label: 'BANNER สินค้า',
                      aspectRatio: horizontalAspectRatio,
                    ),
                    SizedBox(height: 12),
                    BannerCard(
                      label: 'Event & เงื่อนไขเข้าร่วม',
                      aspectRatio: horizontalAspectRatio,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PromotionCarousel extends StatefulWidget {
  const PromotionCarousel({super.key});

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
        final cardWidth = constraints.maxWidth < 700
          ? constraints.maxWidth * 0.45
            : (constraints.maxWidth * 0.285).clamp(220.0, 480.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Stack(
            children: [
              Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 68, bottom: 22),
                  child: Row(
                    children: [
                      _promotionCard(cardWidth, 'โปรโมชั่น A'),
                      const SizedBox(width: 16),
                      _promotionCard(cardWidth, 'โปรโมชั่น B'),
                      const SizedBox(width: 16),
                      _promotionCard(cardWidth, 'โปรโมชั่น C'),
                      const SizedBox(width: 16),
                      _promotionCard(cardWidth, 'โปรโมชั่น D'),
                    ],
                  ),
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
          ),
        );
      },
    );
  }

  Widget _promotionCard(double width, String label) {
    return SizedBox(
      width: width,
      child: BannerCard(
        label: label,
        aspectRatio: 1,
        fontSize: width < 300 ? 24 : 32,
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    this.product,
    this.apiProduct,
  });

  final ProductItem? product;
  final Product? apiProduct;

  @override
  Widget build(BuildContext context) {
    final item = product;
    final remoteItem = apiProduct;
    final productName = remoteItem?.productName ?? item?.name ?? 'PD-Name && detail';
    final productPrice = remoteItem?.price ?? item?.price ?? 0;
    final productImage = remoteItem?.imageUrl ?? '';

    return Container(
      constraints: const BoxConstraints(maxWidth: 162),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.grey.shade400, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 5,
            offset: Offset(2, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 117,
            width: double.infinity,
            color: const Color(0xFFFFFFFF),
            child: productImage.isEmpty
                ? const Center(
                    child: Text(
                      'PD.Image',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'serif',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Image.network(
                    productImage,
                  fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Center(
                      child: Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 3, 8, 0),
            child: Text(
              productName,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 15, 8, 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    '${productPrice.toInt()} ฿',
                    style: const TextStyle(
                      color: Color(0xFFD88A00),
                      fontFamily: 'serif',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _AddToCartButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ApiProductSection extends StatefulWidget {
  const ApiProductSection({super.key});

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
    _productsFuture = ProductService.fetchProducts();
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
                  style: const TextStyle(color: Colors.red, fontSize: 12),
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

        return SizedBox(
          height: 220,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return ProductCard(apiProduct: products[index]);
            },
          ),
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
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: HomeTopBar._green,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Product>>(
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
        childAspectRatio: 0.72,
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

class _AddToCartButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: const BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.shopping_basket_outlined,
            color: Colors.white,
            size: 19,
          ),
        ),
        Positioned(
          right: -1,
          top: -4,
          child: Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.black, size: 12),
          ),
        ),
      ],
    );
  }
}



