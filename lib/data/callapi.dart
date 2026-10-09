import 'dart:convert';

import 'package:http/http.dart' as http;

import 'banner.dart';
import 'product.dart';

class ProductService {
  static const _defaultBaseUrl = 'http://100.119.18.68/chokweb_database';

  static String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (configured.isNotEmpty) {
      return configured.replaceFirst(RegExp(r'/+$'), '');
    }

    return _defaultBaseUrl;
  }

  static Uri get apiUri {
    final base = baseUrl;
    return Uri.parse(base.endsWith('/api.php') ? base : '$base/api.php');
  }

  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(apiUri);
    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const FormatException('API ส่งข้อมูลที่ไม่ใช่ JSON');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('รูปแบบข้อมูลจาก API ไม่ถูกต้อง');
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded['status'] != 'success') {
      final message = decoded['message'];
      throw Exception(
        message is String && message.isNotEmpty
            ? message
            : 'โหลดข้อมูลสินค้าไม่สำเร็จ (${response.statusCode})',
      );
    }

    final data = decoded['data'];
    if (data is! List) {
      throw const FormatException(
        'API ไม่ได้ส่งรายการสินค้าในรูปแบบที่ถูกต้อง',
      );
    }

    return data.map((item) {
      if (item is! Map) {
        throw const FormatException('พบข้อมูลสินค้าในรูปแบบที่ไม่ถูกต้อง');
      }
      return Product.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }
}

class BannerService {
  static Future<List<BannerItem>> fetchBanners() async {
    final uri = ProductService.apiUri.replace(
      queryParameters: {'resource': 'banners', 'active': '1'},
    );
    final response = await http.get(uri);
    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const FormatException('Banner API ส่งข้อมูลที่ไม่ใช่ JSON');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('รูปแบบข้อมูลจาก Banner API ไม่ถูกต้อง');
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded['status'] != 'success') {
      final message = decoded['message'];
      throw Exception(
        message is String && message.isNotEmpty
            ? message
            : 'โหลดแบนเนอร์ไม่สำเร็จ (${response.statusCode})',
      );
    }

    final data = decoded['data'];
    if (data is! List) {
      throw const FormatException('Banner API ไม่ได้ส่งรายการแบนเนอร์');
    }

    return data.map((item) {
      if (item is! Map) {
        throw const FormatException('พบข้อมูลแบนเนอร์ในรูปแบบที่ไม่ถูกต้อง');
      }
      return BannerItem.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }
}
