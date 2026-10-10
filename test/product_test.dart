import 'package:flutter_test/flutter_test.dart';
import 'package:project/data/product.dart';

void main() {
  test('parses product details, API image URLs, and multiple images', () {
    final product = Product.fromJson({
      'id': '7',
      'product_id': 'P007',
      'product_brand': 'LINK',
      'product_name': 'หัวต่อสาย LAN',
      'product_detili': 'หัวต่อ RJ45',
      'price': '45.50',
      'pro_price': null,
      'image': 'prod_20261007_061313_23094ea9.webp',
      'image_url': 'http://127.0.0.1/chokweb_database/upload/image_product/prod_20261007_061313_23094ea9.webp',
      'image_count': 2,
      'images': [
        {
          'image_id': 15,
          'image': 'prod_20261007_061313_23094ea9.webp',
          'image_url': 'http://127.0.0.1/chokweb_database/upload/image_product/prod_20261007_061313_23094ea9.webp',
          'sort_order': 0,
          'is_primary': true,
        },
        {
          'image_id': 16,
          'image': 'prod_20261007_061327_83f8627f.jpg',
          'image_url': 'http://127.0.0.1/chokweb_database/upload/image_product/prod_20261007_061327_83f8627f.jpg',
          'sort_order': 1,
          'is_primary': false,
        },
      ],
    });

    expect(product.id, 7);
    expect(product.productDetail, 'หัวต่อ RJ45');
    expect(product.price, 45.5);
    expect(product.proPrice, isNull);
    expect(
      product.imageUrl,
      'http://127.0.0.1/chokweb_database/upload/image_product/prod_20261007_061313_23094ea9.webp',
    );
    expect(product.images, hasLength(2));
    expect(product.images.first.isPrimary, isTrue);
    expect(product.imageCount, 2);
  });

  test('supports the API detail alias and products without images', () {
    final product = Product.fromJson({
      'product_detail': 'Alternative detail field',
      'image': 'default.jpg',
    });

    expect(product.productDetail, 'Alternative detail field');
    expect(product.imageUrl, isEmpty);
    expect(product.images, isEmpty);
    expect(product.imageCount, 0);
  });
}
