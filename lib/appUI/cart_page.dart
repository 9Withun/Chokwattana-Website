import 'package:flutter/material.dart';
import 'package:project/appUI/ui.dart';
import 'package:project/data/callapi.dart';
import 'package:project/data/cart.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  static const brandGreen = Color(0xFF159B12);
  static const priceGreen = Color(0xFF1E8E2E);
  static const _pageBackground = Color(0xFFF3F5F7);
  static const _quoteViolet = Color(0xFF8B7CF6);

  @override
  Widget build(BuildContext context) {
    final cart = CartStore.instance;
    final isCompact =
        MediaQuery.sizeOf(context).width <
        HomeContentContainer.compactBreakpoint;

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: HomeTopBar.appBar(context),
      body: ListenableBuilder(
        listenable: cart,
        builder: (context, _) {
          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 12 : 24,
              vertical: isCompact ? 16 : 24,
            ),
            children: [
              HomeContentContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _CartHeader(),
                    const SizedBox(height: 20),
                    if (isCompact)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _CartItemsPanel(cart: cart, compact: true),
                          const SizedBox(height: 16),
                          _OrderSummaryPanel(cart: cart),
                        ],
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _CartItemsPanel(cart: cart, compact: false),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: 420,
                            child: _OrderSummaryPanel(cart: cart),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.shopping_cart, color: CartPage.brandGreen, size: 52),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ตะกร้าสินค้า',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2A37),
                ),
              ),
              Text(
                'รายการสินค้าที่คุณเลือกไว้',
                style: TextStyle(fontSize: 16, color: Color(0xFF4B5563)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(20)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CartItemsPanel extends StatelessWidget {
  const _CartItemsPanel({required this.cart, required this.compact});

  final CartStore cart;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final items = cart.items;
    final hasSelection = cart.selectedItems.isNotEmpty;

    return _Panel(
      padding: EdgeInsets.all(compact ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _GreenCheckbox(
                value: cart.allSelected,
                onChanged: items.isEmpty ? null : cart.toggleAll,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'เลือกทั้งหมด ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: '(${items.length} รายการ)',
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: hasSelection
                    ? () => _confirmRemoveSelected(context)
                    : null,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                icon: const Icon(Icons.delete_outline),
                label: Text(compact ? 'ลบ' : 'ลบสินค้าที่เลือก'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const _EmptyCart()
          else
            for (final item in items) ...[
              _CartItemRow(cart: cart, item: item, compact: compact),
              const SizedBox(height: 12),
            ],
          const SizedBox(height: 12),
          const Text(
            'วิธีการจัดส่ง',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _DeliveryOptions(cart: cart, compact: compact),
          const SizedBox(height: 16),
          _AddressBox(cart: cart),
        ],
      ),
    );
  }

  Future<void> _confirmRemoveSelected(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบสินค้าที่เลือก'),
        content: Text(
          'ต้องการลบสินค้า ${cart.selectedItems.length} รายการออกจากตะกร้าหรือไม่?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    if (confirmed == true) cart.removeSelected();
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(
            Icons.remove_shopping_cart_outlined,
            size: 56,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'ยังไม่มีสินค้าในตะกร้า',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            style: OutlinedButton.styleFrom(
              foregroundColor: CartPage.brandGreen,
              side: const BorderSide(color: CartPage.brandGreen),
            ),
            child: const Text('เลือกซื้อสินค้า'),
          ),
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({
    required this.cart,
    required this.item,
    required this.compact,
  });

  final CartStore cart;
  final CartItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final subtitle = [
      if (product.productBrand.isNotEmpty) 'ยี่ห้อ ${product.productBrand}',
      if (product.productId.isNotEmpty) 'รุ่น ${product.productId}',
    ].join(' ');
    final imageSize = compact ? 80.0 : 120.0;

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.productName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 15 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
        const SizedBox(height: 8),
        _StockChip(inStock: item.inStock),
      ],
    );

    final price = Column(
      crossAxisAlignment: compact
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          '${formatBaht(item.unitPrice)} บาท',
          style: TextStyle(
            fontSize: compact ? 17 : 22,
            fontWeight: FontWeight.bold,
            color: CartPage.priceGreen,
          ),
        ),
        if (item.discountPerUnit > 0)
          Text(
            '${formatBaht(product.price)} บาท',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF9CA3AF),
              decoration: TextDecoration.lineThrough,
            ),
          ),
        const Text(
          '(ต่อชิ้น)',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
      ],
    );

    final stepper = _QuantityStepper(
      dense: compact,
      quantity: item.quantity,
      max: product.stock,
      onChanged: (value) => cart.setQuantity(item, value),
    );

    final deleteButton = IconButton(
      tooltip: 'ลบสินค้า',
      onPressed: () => cart.remove(item),
      icon: const Icon(Icons.delete_outline, color: Color(0xFF6B7280)),
    );

    return Container(
      padding: EdgeInsets.all(compact ? 10 : 14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _GreenCheckbox(
            value: item.selected,
            onChanged: (value) => cart.toggle(item, value),
          ),
          SizedBox(width: compact ? 6 : 14),
          _CartItemImage(url: _imageUrl, size: imageSize),
          SizedBox(width: compact ? 10 : 20),
          Expanded(
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      info,
                      const SizedBox(height: 8),
                      price,
                      const SizedBox(height: 8),
                      Row(children: [stepper, const Spacer(), deleteButton]),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: info),
                      const SizedBox(width: 16),
                      price,
                      const SizedBox(width: 32),
                      stepper,
                      const SizedBox(width: 16),
                      deleteButton,
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String get _imageUrl {
    final product = item.product;
    if (product.imageUrl.isNotEmpty) return product.imageUrl;
    final images = [...product.images]
      ..sort((a, b) {
        if (a.isPrimary != b.isPrimary) return a.isPrimary ? -1 : 1;
        return a.sortOrder.compareTo(b.sortOrder);
      });
    for (final image in images) {
      if (image.imageUrl.isNotEmpty) return image.imageUrl;
    }
    return '';
  }
}

class _CartItemImage extends StatelessWidget {
  const _CartItemImage({required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final placeholder = Icon(
      Icons.image_outlined,
      size: size * 0.4,
      color: Colors.grey.shade400,
    );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(6),
      child: url.isEmpty
          ? placeholder
          : Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => placeholder,
            ),
    );
  }
}

class _StockChip extends StatelessWidget {
  const _StockChip({required this.inStock});

  final bool inStock;

  @override
  Widget build(BuildContext context) {
    final color = inStock ? CartPage.brandGreen : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            inStock ? Icons.check_circle : Icons.cancel,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              inStock ? 'มีสินค้าในสต็อก' : 'สินค้าหมด',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onChanged,
    this.max,
    this.dense = false,
  });

  final bool dense;
  final int quantity;
  final int? max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final canIncrease = max == null || max! <= 0 || quantity < max!;
    const borderColor = Color(0xFFD1D5DB);

    Widget button(IconData icon, VoidCallback? onTap) {
      return SizedBox(
        width: dense ? 36 : 44,
        height: dense ? 40 : 48,
        child: IconButton(
          onPressed: onTap,
          padding: EdgeInsets.zero,
          icon: Icon(icon, size: 20),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(
            Icons.remove,
            quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          Container(
            width: dense ? 40 : 56,
            height: dense ? 40 : 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: borderColor),
              ),
            ),
            child: Text(
              '$quantity',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          button(Icons.add, canIncrease ? () => onChanged(quantity + 1) : null),
        ],
      ),
    );
  }
}

class _GreenCheckbox extends StatelessWidget {
  const _GreenCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      activeColor: CartPage.brandGreen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      onChanged: onChanged == null
          ? null
          : (value) => onChanged!(value ?? false),
    );
  }
}

class _DeliveryOptions extends StatelessWidget {
  const _DeliveryOptions({required this.cart, required this.compact});

  final CartStore cart;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final home = _SelectableTile(
      selected: cart.deliveryMethod == DeliveryMethod.homeDelivery,
      onTap: () => cart.setDeliveryMethod(DeliveryMethod.homeDelivery),
      leading: const Icon(
        Icons.local_shipping_outlined,
        size: 44,
        color: CartPage.brandGreen,
      ),
      title: 'จัดส่งถึงบ้าน',
      subtitle: 'จัดส่งภายใน 1-3 วันทำการ',
    );
    final pickup = _SelectableTile(
      selected: cart.deliveryMethod == DeliveryMethod.storePickup,
      onTap: () => cart.setDeliveryMethod(DeliveryMethod.storePickup),
      leading: const Icon(
        Icons.storefront_outlined,
        size: 44,
        color: CartPage.brandGreen,
      ),
      title: 'รับสินค้าที่ร้าน',
      subtitle: 'รับได้ที่สาขาที่เลือก',
    );

    if (compact) {
      return Column(children: [home, const SizedBox(height: 10), pickup]);
    }
    return Row(
      children: [
        Expanded(child: home),
        const SizedBox(width: 16),
        Expanded(child: pickup),
      ],
    );
  }
}

class _SelectableTile extends StatelessWidget {
  const _SelectableTile({
    required this.selected,
    required this.onTap,
    required this.leading,
    required this.title,
    required this.subtitle,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget leading;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFF0FAF0) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selected ? CartPage.brandGreen : const Color(0xFFE5E7EB),
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? CartPage.brandGreen : const Color(0xFFBDBDBD),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressBox extends StatelessWidget {
  const _AddressBox({required this.cart});

  final CartStore cart;

  @override
  Widget build(BuildContext context) {
    final address = cart.address;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: CartPage.brandGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ที่อยู่จัดส่ง',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  address ?? 'ยังไม่ได้ระบุที่อยู่จัดส่ง',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => _editAddress(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: CartPage.brandGreen,
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFBFDCBF)),
            ),
            icon: const Icon(Icons.edit, size: 18),
            label: Text(address == null ? 'เพิ่มที่อยู่' : 'เปลี่ยนที่อยู่'),
          ),
        ],
      ),
    );
  }

  Future<void> _editAddress(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _AddressDialog(initial: cart.address ?? ''),
    );
    if (result == null) return;
    cart.setAddress(result);
    if (!context.mounted) return;
    final loggedIn = AuthService.currentUser.value != null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          loggedIn
              ? 'บันทึกที่อยู่จัดส่งในบัญชีแล้ว'
              : 'เข้าสู่ระบบเพื่อบันทึกที่อยู่ไว้ในบัญชี',
        ),
      ),
    );
  }
}

class _AddressDialog extends StatefulWidget {
  const _AddressDialog({required this.initial});

  final String initial;

  @override
  State<_AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<_AddressDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ที่อยู่จัดส่ง'),
      content: SizedBox(
        width: 420,
        child: TextField(
          key: const ValueKey('address-field'),
          controller: _controller,
          autofocus: true,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'บ้านเลขที่ ถนน ตำบล อำเภอ จังหวัด รหัสไปรษณีย์',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          style: FilledButton.styleFrom(backgroundColor: CartPage.brandGreen),
          child: const Text('บันทึก'),
        ),
      ],
    );
  }
}

class _OrderSummaryPanel extends StatelessWidget {
  const _OrderSummaryPanel({required this.cart});

  final CartStore cart;

  @override
  Widget build(BuildContext context) {
    final selectedCount = cart.selectedItems.length;
    final canCheckout = selectedCount > 0;

    return _Panel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(
                Icons.assignment_outlined,
                color: CartPage.brandGreen,
                size: 34,
              ),
              SizedBox(width: 12),
              Flexible(
                child: Text(
                  'สรุปคำสั่งซื้อ',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _summaryRow(
            'รวมสินค้าทั้งหมด ($selectedCount รายการ)',
            '${formatBaht(cart.subtotal)} บาท',
            valueStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          _summaryRow(
            'ส่วนลด',
            '- ${formatBaht(cart.discount)} บาท',
            valueStyle: const TextStyle(
              color: CartPage.priceGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          _summaryRow(
            'ค่าจัดส่ง',
            cart.shippingFee == 0
                ? 'ฟรี'
                : '${formatBaht(cart.shippingFee)} บาท',
            valueStyle: const TextStyle(
              color: CartPage.priceGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  'ยอดชำระทั้งหมด',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Text.rich(
                TextSpan(
                  text: formatBaht(cart.total),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: CartPage.priceGreen,
                  ),
                  children: const [
                    TextSpan(text: ' บาท', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: canCheckout ? () => _checkout(context) : null,
            style: FilledButton.styleFrom(
              backgroundColor: CartPage.brandGreen,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.shopping_cart),
            label: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'ดำเนินการต่อเพื่อชำระเงิน',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: canCheckout
                ? () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ส่งคำขอใบเสนอราคาแล้ว')),
                  )
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: CartPage._quoteViolet,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.request_quote_outlined),
            label: const Text(
              'ขอใบเสนอราคา',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),
          const Text.rich(
            TextSpan(
              text: 'วิธีการชำระเงิน ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4338CA),
              ),
              children: [
                TextSpan(
                  text: '(ขั้นตอนถัดไป)',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _PaymentOption(
            selected: cart.paymentMethod == PaymentMethod.promptPay,
            onTap: () => cart.setPaymentMethod(PaymentMethod.promptPay),
            logo: const _PaymentLogo(
              label: 'PromptPay',
              background: Color(0xFF113566),
            ),
            title: 'พร้อมเพย์',
            subtitle: 'สแกน QR หรือโอนเงิน',
          ),
          const SizedBox(height: 10),
          _PaymentOption(
            selected: cart.paymentMethod == PaymentMethod.scb,
            onTap: () => cart.setPaymentMethod(PaymentMethod.scb),
            logo: const _PaymentLogo(
              label: 'SCB',
              background: Color(0xFF4E2A84),
            ),
            title: 'SCB ไทยพาณิชย์',
            subtitle: 'ชำระผ่านบัญชีธนาคาร',
          ),
        ],
      ),
    );
  }

  void _checkout(BuildContext context) {
    final message = cart.paymentMethod == null
        ? 'กรุณาเลือกวิธีการชำระเงิน'
        : 'กำลังดำเนินการชำระเงิน ${formatBaht(cart.total)} บาท';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _summaryRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Color(0xFF374151)),
            ),
          ),
          Text(value, style: const TextStyle(fontSize: 16).merge(valueStyle)),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.selected,
    required this.onTap,
    required this.logo,
    required this.title,
    required this.subtitle,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget logo;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? CartPage.brandGreen : const Color(0xFFE5E7EB),
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? CartPage.brandGreen : const Color(0xFFBDBDBD),
              ),
              const SizedBox(width: 12),
              logo,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentLogo extends StatelessWidget {
  const _PaymentLogo({required this.label, required this.background});

  final String label;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

String formatBaht(double value) {
  final integer = value.round();
  final sign = integer < 0 ? '-' : '';
  final digits = integer.abs().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '$sign$digits';
}
