import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project/data/callapi.dart';
import 'package:project/data/product.dart';
import 'package:project/data/user.dart';

enum DeliveryMethod { homeDelivery, storePickup }

enum PaymentMethod { promptPay, scb }

class CartItem {
  CartItem({required this.product, this.quantity = 1, this.selected = true});

  final Product product;
  int quantity;
  bool selected;

  double get unitPrice {
    final promo = product.proPrice;
    return promo != null && promo > 0 && promo < product.price
        ? promo
        : product.price;
  }

  double get discountPerUnit => product.price - unitPrice;

  bool get inStock => product.stock == null || product.stock! > 0;

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
    'selected': selected,
  };

  static CartItem? fromJson(Object? json) {
    if (json is! Map || json['product'] is! Map) return null;
    final quantity = json['quantity'];
    return CartItem(
      product: Product.fromJson(Map<String, dynamic>.from(json['product'])),
      quantity: quantity is int && quantity > 0 ? quantity : 1,
      selected: json['selected'] != false,
    );
  }
}

/// Shopping cart shared by every page.
///
/// While a member is logged in, the cart, delivery address, delivery method
/// and payment method belong to that account: they are saved on the device
/// under the member's id and restored the next time the same member logs in.
/// A guest cart lives only in memory and is merged into the account on login.
class CartStore extends ChangeNotifier {
  CartStore._() {
    AuthService.currentUser.addListener(_onUserChanged);
    _onUserChanged();
  }

  static final CartStore instance = CartStore._();

  static const _storage = FlutterSecureStorage();

  static String _storageKey(int userId) => 'account_data_$userId';

  final List<CartItem> _items = [];
  DeliveryMethod deliveryMethod = DeliveryMethod.homeDelivery;
  PaymentMethod? paymentMethod;
  String? _address;

  /// Account whose data is in memory; null for a guest.
  int? _userId;

  /// Bumped on every account switch so a slow load for a previous account
  /// cannot overwrite the current one.
  int _generation = 0;
  Future<void> _pending = Future.value();

  List<CartItem> get items => List.unmodifiable(_items);

  /// Delivery address chosen in the cart, falling back to the member profile.
  String? get address => _address ?? AuthService.currentUser.value?.address;

  /// Completes when the current account's data is loaded and saved.
  @visibleForTesting
  Future<void> get pendingWork => _pending;

  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  List<CartItem> get selectedItems =>
      _items.where((item) => item.selected).toList();

  bool get allSelected =>
      _items.isNotEmpty && _items.every((item) => item.selected);

  /// Sum of full prices for the selected items.
  double get subtotal => selectedItems.fold(
    0,
    (sum, item) => sum + item.product.price * item.quantity,
  );

  double get discount => selectedItems.fold(
    0,
    (sum, item) => sum + item.discountPerUnit * item.quantity,
  );

  double get shippingFee => 0;

  double get total => subtotal - discount + shippingFee;

  void add(Product product, {int quantity = 1}) {
    final existing = _find(product);
    if (existing != null) {
      existing.quantity = _clampQuantity(product, existing.quantity + quantity);
      existing.selected = true;
    } else {
      _items.add(
        CartItem(product: product, quantity: _clampQuantity(product, quantity)),
      );
    }
    _changed();
  }

  void setQuantity(CartItem item, int quantity) {
    final next = _clampQuantity(item.product, quantity);
    if (next == item.quantity) return;
    item.quantity = next;
    _changed();
  }

  void toggle(CartItem item, bool selected) {
    item.selected = selected;
    _changed();
  }

  void toggleAll(bool selected) {
    for (final item in _items) {
      item.selected = selected;
    }
    _changed();
  }

  void remove(CartItem item) {
    _items.remove(item);
    _changed();
  }

  void removeSelected() {
    _items.removeWhere((item) => item.selected);
    _changed();
  }

  void setDeliveryMethod(DeliveryMethod method) {
    deliveryMethod = method;
    _changed();
  }

  void setPaymentMethod(PaymentMethod method) {
    paymentMethod = method;
    _changed();
  }

  void setAddress(String address) {
    final trimmed = address.trim();
    _address = trimmed.isEmpty ? null : trimmed;
    _changed();
  }

  /// Empties the in-memory state without touching saved account data.
  @visibleForTesting
  void clear() {
    _resetState();
    notifyListeners();
  }

  void _resetState() {
    _items.clear();
    deliveryMethod = DeliveryMethod.homeDelivery;
    paymentMethod = null;
    _address = null;
  }

  void _changed() {
    notifyListeners();
    _save();
  }

  void _onUserChanged() {
    final user = AuthService.currentUser.value;
    if (user?.id == _userId) {
      // Same account refreshed (e.g. resource=me): only profile defaults.
      if (user != null) _applyProfileDefaults(user);
      notifyListeners();
      return;
    }

    final guestItems = _userId == null ? List.of(_items) : <CartItem>[];
    _userId = user?.id;
    final generation = ++_generation;
    _resetState();
    notifyListeners();
    if (user == null) return;

    _pending = _pending.then((_) async {
      final saved = await _read(user.id);
      if (generation != _generation) return;
      // Guest items and anything added while loading go on top of the
      // saved cart.
      final unsaved = [...guestItems, ..._items];
      _resetState();
      _restore(saved);
      _applyProfileDefaults(user);
      for (final item in unsaved) {
        add(item.product, quantity: item.quantity);
      }
      notifyListeners();
    });
  }

  void _applyProfileDefaults(UserItem user) {
    paymentMethod ??= _paymentFromProfile(user.paymentMethod);
  }

  static PaymentMethod? _paymentFromProfile(String? value) {
    final normalized = value?.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
    if (normalized == null) return null;
    if (normalized.contains('promptpay') || normalized.contains('พร้อมเพย์')) {
      return PaymentMethod.promptPay;
    }
    if (normalized.contains('scb') || normalized.contains('ไทยพาณิชย์')) {
      return PaymentMethod.scb;
    }
    return null;
  }

  void _restore(Map<String, dynamic>? data) {
    if (data == null) return;
    final items = data['items'];
    if (items is List) {
      _items.addAll(items.map(CartItem.fromJson).whereType<CartItem>());
    }
    deliveryMethod = DeliveryMethod.values.firstWhere(
      (method) => method.name == data['delivery_method'],
      orElse: () => DeliveryMethod.homeDelivery,
    );
    for (final method in PaymentMethod.values) {
      if (method.name == data['payment_method']) paymentMethod = method;
    }
    final address = data['address'];
    if (address is String && address.isNotEmpty) _address = address;
  }

  Map<String, dynamic> _toJson() => {
    'items': _items.map((item) => item.toJson()).toList(),
    'delivery_method': deliveryMethod.name,
    'payment_method': paymentMethod?.name,
    'address': _address,
  };

  void _save() {
    final userId = _userId;
    if (userId == null) return;
    final generation = _generation;
    _pending = _pending.then((_) async {
      // Wait for this account's data to load; skip if the account changed.
      if (generation != _generation) return;
      final value = jsonEncode(_toJson());
      try {
        await _storage.write(key: _storageKey(userId), value: value);
      } catch (e, st) {
        debugPrint('CartStore: could not save account data: $e\n$st');
      }
    });
  }

  static Future<Map<String, dynamic>?> _read(int userId) async {
    try {
      final raw = await _storage.read(key: _storageKey(userId));
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e, st) {
      debugPrint('CartStore: could not load account data: $e\n$st');
      return null;
    }
  }

  CartItem? _find(Product product) {
    for (final item in _items) {
      if (item.product.id == product.id &&
          item.product.productId == product.productId) {
        return item;
      }
    }
    return null;
  }

  int _clampQuantity(Product product, int quantity) {
    final stock = product.stock;
    final max = stock != null && stock > 0 ? stock : 999;
    return quantity.clamp(1, max);
  }
}
