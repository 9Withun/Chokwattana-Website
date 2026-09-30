class Product {
  static String get imageBaseUrl {
    const configured = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );

    if (configured.isNotEmpty) {
      final cleaned = configured.replaceFirst(RegExp(r'/+$'), '');
      return '$cleaned/../uploads/products/';
    }

    const backendHost = 'http://192.168.20.3';
    final origin = Uri.base.origin;
    final normalizedOrigin = origin.replaceFirst(RegExp(r'/+$'), '');

    if (normalizedOrigin.isNotEmpty && normalizedOrigin != 'null') {
      if (normalizedOrigin.contains('localhost') ||
          normalizedOrigin.contains('127.0.0.1') ||
          normalizedOrigin.contains('192.168.') ||
          normalizedOrigin.contains('10.')) {
        if (normalizedOrigin.contains(':')) {
          return '$backendHost/my_website/uploads/products/';
        }
        return '$normalizedOrigin/my_website/uploads/products/';
      }
      return '$normalizedOrigin/uploads/products/';
    }

    return '$backendHost/my_website/uploads/products/';
  }

  final int id;
  final String productId;
  final String productBrand;
  final String productName;
  final String productType;
  final double price;
  final double proPrice;
  final String proName;
  final int stock;
  final String image;

  const Product({
    required this.id,
    this.productId = '',
    this.productBrand = '',
    required this.productName,
    this.productType = '',
    required this.price,
    this.proPrice = 0,
    this.proName = '',
    this.stock = 0,
    required this.image,
  });

  String get imageUrl {
    if (image.isEmpty) {
      return '';
    }

    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }

    return '$imageBaseUrl$image';
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.tryParse(json['id'].toString()) ?? 0,
      productId: json['product_id']?.toString() ?? '',
      productBrand: json['product_brand']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      productType: json['product_type']?.toString() ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      proPrice: double.tryParse(json['pro_price'].toString()) ?? 0,
      proName: json['pro_name']?.toString() ?? '',
      stock: int.tryParse(json['stock'].toString()) ?? 0,
      image: json['image']?.toString() ?? '',
    );
  }
}