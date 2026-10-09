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
}

class Product {
  const Product({
    required this.id,
    required this.productId,
    required this.productBrand,
    required this.productName,
    required this.productDetail,
    required this.price,
    required this.proPrice,
    required this.proName,
    required this.image,
    required this.imageUrl,
    required this.images,
    required this.imageCount,
  });

  final int id;
  final String productId;
  final String productBrand;
  final String productName;
  final String productDetail;
  final double price;
  final double? proPrice;
  final String proName;
  final String image;
  final String imageUrl;
  final List<ProductImage> images;
  final int imageCount;

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
    );
  }
}

String _stringValue(dynamic value) => value?.toString() ?? '';

int _intValue(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _doubleValue(dynamic value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}
