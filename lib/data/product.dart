class ProductImage {
  const ProductImage({
    required this.id,
    required this.image,
    required this.imageUrl,
    required this.sortOrder,
    required this.isPrimary,
  });

  final int id;
  final String image;
  final String imageUrl;
  final int sortOrder;
  final bool isPrimary;

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: _intValue(json['image_id']),
      image: _stringValue(json['image']),
      imageUrl: _stringValue(json['image_url']),
      sortOrder: _intValue(json['sort_order']),
      isPrimary:
          json['is_primary'] == true ||
          json['is_primary'] == 1 ||
          json['is_primary'] == '1',
    );
  }

  Map<String, dynamic> toJson() => {
    'image_id': id,
    'image': image,
    'image_url': imageUrl,
    'sort_order': sortOrder,
    'is_primary': isPrimary,
  };
}

class Product {
  const Product({
    required this.id,
    required this.productId,
    required this.productBrand,
    required this.productName,
    this.productType = '',
    required this.productDetail,
    required this.price,
    required this.proPrice,
    required this.proName,
    required this.image,
    required this.imageUrl,
    required this.images,
    required this.imageCount,
    this.stock,
  });

  final int id;
  final String productId;
  final String productBrand;
  final String productName;
  final String productType;
  final String productDetail;
  final double price;
  final double? proPrice;
  final String proName;
  final String image;
  final String imageUrl;
  final List<ProductImage> images;
  final int imageCount;
  final int? stock;

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    final images = rawImages is List
        ? rawImages
              .whereType<Map>()
              .map(
                (image) =>
                    ProductImage.fromJson(Map<String, dynamic>.from(image)),
              )
              .toList()
        : const <ProductImage>[];
    final image = _stringValue(json['image']);
    final imageUrl = _stringValue(json['image_url']);

    return Product(
      id: _intValue(json['id']),
      productId: _stringValue(json['product_id']),
      productBrand: _stringValue(json['product_brand']),
      productName: _stringValue(json['product_name']),
      productType: _stringValue(json['product_type']).trim(),
      productDetail: _stringValue(
        json['product_detili'] ?? json['product_detail'],
      ),
      price: _doubleValue(json['price']),
      proPrice: json['pro_price'] == null || json['pro_price'] == ''
          ? null
          : _doubleValue(json['pro_price']),
      proName: _stringValue(json['pro_name']),
      image: image,
      imageUrl: imageUrl.isNotEmpty
          ? imageUrl
          : (image.startsWith('http://') || image.startsWith('https://')
                ? image
                : ''),
      images: images,
      imageCount: _intValue(json['image_count'], images.length),
      stock: _nullableIntValue(
        json['stock'] ??
            json['product_stock'] ??
            json['quantity'] ??
            json['qty'],
      ),
    );
  }

  /// Same keys as the API, so `Product.fromJson(p.toJson())` round-trips.
  Map<String, dynamic> toJson() => {
    'id': id,
    'product_id': productId,
    'product_brand': productBrand,
    'product_name': productName,
    'product_type': productType,
    'product_detail': productDetail,
    'price': price,
    'pro_price': proPrice,
    'pro_name': proName,
    'image': image,
    'image_url': imageUrl,
    'images': images.map((image) => image.toJson()).toList(),
    'image_count': imageCount,
    'stock': stock,
  };
}

String _stringValue(dynamic value) => value?.toString() ?? '';

int _intValue(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

int? _nullableIntValue(dynamic value) {
  if (value == null || value == '') return null;
  return _intValue(value);
}

double _doubleValue(dynamic value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}
