import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'product.dart';

class ProductService {
  static const String fallbackBaseUrl = 'http://192.168.20.3/my_website/api';

  static String get baseUrl {
    const configured = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );

    if (configured.isNotEmpty) {
      return configured.replaceFirst(RegExp(r'/+$'), '');
    }

    if (kIsWeb) {
      final origin = Uri.base.origin;
      if (origin.isNotEmpty && origin != 'null') {
        final normalizedOrigin = origin.replaceFirst(RegExp(r'/+$'), '');
        final hasLegacyPath = normalizedOrigin.endsWith('/my_website');
        if (hasLegacyPath) {
          return '$normalizedOrigin/api';
        }

        if (normalizedOrigin.contains('localhost') ||
            normalizedOrigin.contains('127.0.0.1') ||
            normalizedOrigin.contains('192.168.') ||
            normalizedOrigin.contains('10.')) {
          return '$normalizedOrigin/my_website/api';
        }

        return '$normalizedOrigin/api';
      }
    }

    return fallbackBaseUrl;
  }

  static Uri _apiUri(String endpoint) {
    final cleanBase = baseUrl.replaceFirst(RegExp(r'/+$'), '');
    return Uri.parse('$cleanBase/$endpoint');
  }

  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(_apiUri('get_products.php'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      final products = jsonData['data'];

      if (products is! List) {
        throw const FormatException('รูปแบบข้อมูลสินค้าไม่ถูกต้อง');
      }

      return products
          .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } else {
      throw Exception(
        'โหลดข้อมูลสินค้าไม่สำเร็จ (${response.statusCode})',
      );
    }
  }

  static Future<bool> addProduct({
    required String productId,
    required String brand,
    required String name,
    required String type,
    required String image,
    required double price,
    required double proPrice,
    required String proName,
    required int stock,
  }) async {
    final response = await http.post(
      _apiUri('add_product.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'product_id': productId,
        'product_brand': brand,
        'product_name': name,
        'product_type': type,
        'image': image,
        'price': price,
        'pro_price': proPrice,
        'pro_name': proName,
        'stock': stock,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('เพิ่มสินค้าไม่สำเร็จ (${response.statusCode})');
    }

    final result = jsonDecode(response.body) as Map<String, dynamic>;
    return result['status'] == 'success';
  }

  static Future<bool> createProduct({
    required String productId,
    required String brand,
    required String name,
    required String type,
    required double price,
    required double proPrice,
    required String proName,
    required int stock,
    XFile? imageFile,
    String image = '',
  }) async {
    if (imageFile == null) {
      return addProduct(
        productId: productId,
        brand: brand,
        name: name,
        type: type,
        image: image,
        price: price,
        proPrice: proPrice,
        proName: proName,
        stock: stock,
      );
    }

    final uploadResult = await uploadProduct(
      productId: productId,
      brand: brand,
      name: name,
      type: type,
      price: price,
      proPrice: proPrice,
      proName: proName,
      stock: stock,
      imageFile: imageFile,
    );
    if (uploadResult['status'] != 'success') {
      throw Exception(uploadResult['message'] ?? 'อัปโหลดรูปไม่สำเร็จ');
    }

    return true;
  }

  static Future<bool> updateProduct({
    required int id,
    required String productId,
    required String brand,
    required String name,
    required String type,
    required String image,
    required double price,
    required double proPrice,
    required String proName,
    required int stock,
    XFile? imageFile,
  }) async {
    if (imageFile != null) {
      final result = await uploadProduct(
        id: id,
        productId: productId,
        brand: brand,
        name: name,
        type: type,
        price: price,
        proPrice: proPrice,
        proName: proName,
        stock: stock,
        imageFile: imageFile,
      );
      if (result['status'] != 'success') {
        throw Exception(result['message'] ?? 'แก้ไขสินค้าไม่สำเร็จ');
      }
      return true;
    }

    final response = await http.post(
      _apiUri('update_product.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        'product_id': productId,
        'product_brand': brand,
        'product_name': name,
        'product_type': type,
        'image': image,
        'price': price,
        'pro_price': proPrice,
        'pro_name': proName,
        'stock': stock,
      }),
    );

    return _isSuccessful(response, 'แก้ไขสินค้าไม่สำเร็จ');
  }

  static Future<bool> deleteProduct(int id) async {
    final response = await http.post(
      _apiUri('delete_product.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );

    return _isSuccessful(response, 'ลบสินค้าไม่สำเร็จ');
  }

  static bool _isSuccessful(http.Response response, String errorMessage) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('$errorMessage (${response.statusCode})');
    }

    final result = jsonDecode(response.body) as Map<String, dynamic>;
    return result['status'] == 'success';
  }
  static Future<Map<String, dynamic>> uploadProduct({
    int? id,
    required String productId,
    required String brand,
    required String name,
    required String type,
    required double price,
    required double proPrice,
    required String proName,
    required int stock,
    XFile? imageFile,
  }) async {
    final uri = _apiUri('upload_product.php');
    final request = http.MultipartRequest('POST', uri);

    if (id != null) {
      request.fields['id'] = id.toString();
    }
    request.fields['product_id'] = productId;
    request.fields['product_brand'] = brand;
    request.fields['product_name'] = name;
    request.fields['product_type'] = type;
    request.fields['price'] = price.toString();
    request.fields['pro_price'] = proPrice.toString();
    request.fields['pro_name'] = proName;
    request.fields['stock'] = stock.toString();

    if (imageFile != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          await imageFile.readAsBytes(),
          filename: imageFile.name,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      var message = 'อัปโหลดไม่สำเร็จ (${response.statusCode})';
      try {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        final fields = error['fields'];
        final detail = fields is List ? fields.join(', ') : error['message'];
        if (detail is String && detail.isNotEmpty) {
          message = '$message: $detail';
        }
      } catch (_) {
        // Keep the HTTP error when the server does not return JSON.
      }
      throw Exception(message);
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}