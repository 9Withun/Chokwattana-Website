import 'package:flutter_test/flutter_test.dart';
import 'package:project/data/banner.dart';

void main() {
  test('parses banner alignment, type, URL, and nullable end date', () {
    final banner = BannerItem.fromJson({
      'id': '13',
      'banner_name': 'เครื่องใช้ไฟฟ้า',
      'align': 'Landscape',
      'type': 'Product',
      'image': 'banner.png',
      'image_url': 'https://example.test/banner.png',
      'date_start': '2026-10-07',
      'date_end': null,
    });

    expect(banner.id, 13);
    expect(banner.name, 'เครื่องใช้ไฟฟ้า');
    expect(banner.align, 'Landscape');
    expect(banner.type, 'Product');
    expect(banner.imageUrl, 'https://example.test/banner.png');
    expect(banner.dateStart, '2026-10-07');
    expect(banner.dateEnd, isNull);
  });
}
