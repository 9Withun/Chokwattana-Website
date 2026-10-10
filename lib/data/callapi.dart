import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'banner.dart';
import 'product.dart';
import 'user.dart';

class ProductService {
  static const _defaultBaseUrl = 'http://192.168.20.3/chokweb_database';

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

/// Login/session handling against `resource=auth` / `resource=me`.
/// The per-user token is kept in secure storage; [currentUser] mirrors the
/// logged-in member for the UI.
class AuthService {
  static const _tokenKey = 'auth_token';
  static const _storage = FlutterSecureStorage();

  /// Replaceable in tests.
  @visibleForTesting
  static http.Client client = http.Client();

  static final ValueNotifier<UserItem?> currentUser = ValueNotifier(null);

  static Uri _uri(Map<String, String> query) =>
      ProductService.apiUri.replace(queryParameters: query);

  static Map<String, dynamic> _decode(http.Response response, String label) {
    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw FormatException('$label ส่งข้อมูลที่ไม่ใช่ JSON');
    }
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('รูปแบบข้อมูลจาก $label ไม่ถูกต้อง');
    }
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded['status'] != 'success') {
      final message = decoded['message'];
      throw Exception(
        message is String && message.isNotEmpty
            ? message
            : '$label ไม่สำเร็จ (${response.statusCode})',
      );
    }
    return decoded;
  }

  static UserItem _userFrom(Object? data, String label) {
    if (data is! Map) {
      throw FormatException('$label ไม่ได้ส่งข้อมูลผู้ใช้');
    }
    return UserItem.fromJson(Map<String, dynamic>.from(data));
  }

  /// POST ?resource=auth&action=login. [login] is tried as a member ID first
  /// and then as a username, because the server accepts exactly one of them.
  static Future<UserItem> login(String login, String password) async {
    final id = login.trim();
    if (id.isEmpty || password.isEmpty) {
      throw Exception('กรุณากรอกรหัสสมาชิก/ชื่อผู้ใช้ และรหัสผ่าน');
    }

    final uri = _uri({'resource': 'auth', 'action': 'login'});
    http.Response? response;
    for (final field in const ['member_id', 'username']) {
      response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({field: id, 'password': password}),
      );
      if (response.statusCode != 401) break;
    }

    return _startSession(_decode(response!, 'Login API'), 'Login API');
  }

  /// POST ?resource=auth&action=register. The server creates the member and
  /// answers like a login (token + user), so the new member is signed in.
  static Future<UserItem> register({
    required String username,
    required String password,
    required String phoneNumber,
    String? email,
    String? address,
  }) async {
    final response = await client.post(
      _uri({'resource': 'auth', 'action': 'register'}),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username.trim(),
        'password': password,
        'phonenumber': phoneNumber.trim(),
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (address != null && address.trim().isNotEmpty)
          'address': address.trim(),
      }),
    );
    return _startSession(_decode(response, 'Register API'), 'Register API');
  }

  static Future<UserItem> _startSession(
    Map<String, dynamic> decoded,
    String label,
  ) async {
    final token = decoded['token'];
    if (token is! String || token.isEmpty) {
      throw FormatException('$label ไม่ได้ส่ง token');
    }
    final user = _userFrom(decoded['data'], label);
    await _saveToken(token);
    currentUser.value = user;
    return user;
  }

  // Secure storage can fail (e.g. web without a secure context). The token is
  // then kept in memory so the login still works for this app session.
  static String? _memoryToken;

  @visibleForTesting
  static void resetMemoryToken() => _memoryToken = null;

  static Future<void> _saveToken(String token) async {
    _memoryToken = token;
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e, st) {
      debugPrint('AuthService: could not persist token: $e\n$st');
    }
  }

  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey) ?? _memoryToken;
    } catch (e, st) {
      debugPrint('AuthService: could not read token: $e\n$st');
      return _memoryToken;
    }
  }

  /// GET ?resource=me with the stored token. Clears the session on 401.
  static Future<UserItem> me() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('ยังไม่ได้เข้าสู่ระบบ');
    }

    final response = await client.get(
      _uri({'resource': 'me'}),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 401) {
      await _clearSession();
      throw Exception('เซสชันหมดอายุ กรุณาเข้าสู่ระบบใหม่');
    }

    final user = _userFrom(_decode(response, 'Me API')['data'], 'Me API');
    currentUser.value = user;
    return user;
  }

  /// Restores the session at app start. Never throws.
  static Future<void> restoreSession() async {
    try {
      if ((await getToken())?.isNotEmpty ?? false) await me();
    } catch (_) {
      // Offline or expired: stay logged out in the UI.
    }
  }

  /// Revokes the token on the server (best effort) and forgets it locally.
  static Future<void> logout() async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await client.post(
          _uri({'resource': 'auth', 'action': 'logout'}),
          headers: {'Authorization': 'Bearer $token'},
        );
      } catch (_) {
        // The local session is cleared regardless.
      }
    }
    await _clearSession();
  }

  static Future<void> _clearSession() async {
    _memoryToken = null;
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e, st) {
      debugPrint('AuthService: could not delete token: $e\n$st');
    }
    currentUser.value = null;
  }
}

class UserService {
  // Pass with: --dart-define=API_READ_TOKEN=<token>
  static const _readToken = String.fromEnvironment('API_READ_TOKEN');

  static Future<List<UserItem>> fetchUsers({String? token}) async {
    final bearer = token ?? _readToken;
    if (bearer.isEmpty) {
      throw const FormatException(
        'ไม่พบ API read token (ใช้ --dart-define=API_READ_TOKEN=...)',
      );
    }

    final uri = ProductService.apiUri.replace(
      queryParameters: {'resource': 'users'},
    );
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $bearer'},
    );
    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const FormatException('User API ส่งข้อมูลที่ไม่ใช่ JSON');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('รูปแบบข้อมูลจาก User API ไม่ถูกต้อง');
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded['status'] != 'success') {
      final message = decoded['message'];
      throw Exception(
        message is String && message.isNotEmpty
            ? message
            : 'โหลดข้อมูลผู้ใช้ไม่สำเร็จ (${response.statusCode})',
      );
    }

    final data = decoded['data'];
    if (data is! List) {
      throw const FormatException('User API ไม่ได้ส่งรายการผู้ใช้');
    }

    return data.map((item) {
      if (item is! Map) {
        throw const FormatException('พบข้อมูลผู้ใช้ในรูปแบบที่ไม่ถูกต้อง');
      }
      return UserItem.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }
}
