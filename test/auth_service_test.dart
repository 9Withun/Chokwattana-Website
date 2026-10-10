import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:project/data/callapi.dart';

const _userJson = {
  'id': 8,
  'member_id': '00000001',
  'username': 'tester',
  'email': null,
  'phonenumber': '0123456789',
  'address': null,
  'payment_method': null,
};

http.Response _json(int status, Map<String, dynamic> body) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    AuthService.currentUser.value = null;
    AuthService.resetMemoryToken();
  });

  test('login stores token and exposes the user', () async {
    late http.Request sent;
    AuthService.client = MockClient((request) async {
      sent = request;
      return _json(200, {
        'status': 'success',
        'token': 'a' * 64,
        'data': _userJson,
      });
    });

    final user = await AuthService.login(' 00000001 ', 'secret123');

    expect(sent.url.queryParameters, {'resource': 'auth', 'action': 'login'});
    expect(jsonDecode(sent.body), {
      'member_id': '00000001',
      'password': 'secret123',
    });
    expect(user.username, 'tester');
    expect(AuthService.currentUser.value?.memberId, '00000001');
    expect(await AuthService.getToken(), 'a' * 64);
  });

  test('login falls back to username when member_id is rejected', () async {
    final bodies = <Map<String, dynamic>>[];
    AuthService.client = MockClient((request) async {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      bodies.add(body);
      if (body.containsKey('member_id')) {
        return _json(401, {'status': 'error', 'message': 'Invalid login'});
      }
      return _json(200, {
        'status': 'success',
        'token': 'b' * 64,
        'data': _userJson,
      });
    });

    await AuthService.login('tester', 'secret123');

    expect(bodies.map((b) => b.keys.first), ['member_id', 'username']);
    expect(await AuthService.getToken(), 'b' * 64);
  });

  test('login surfaces the server message and stores nothing', () async {
    AuthService.client = MockClient(
      (_) async => _json(401, {
        'status': 'error',
        'message': 'Invalid login or password.',
      }),
    );

    await expectLater(
      AuthService.login('nobody', 'wrongpass1'),
      throwsA(
        predicate((e) => e.toString().contains('Invalid login or password.')),
      ),
    );
    expect(await AuthService.getToken(), isNull);
    expect(AuthService.currentUser.value, isNull);
  });

  test('me clears the session on 401', () async {
    FlutterSecureStorage.setMockInitialValues({'auth_token': 'c' * 64});
    AuthService.client = MockClient(
      (_) async => _json(401, {'status': 'error', 'message': 'expired'}),
    );

    await expectLater(AuthService.me(), throwsException);
    expect(await AuthService.getToken(), isNull);
  });

  test('restoreSession loads the user when the token is valid', () async {
    FlutterSecureStorage.setMockInitialValues({'auth_token': 'd' * 64});
    late http.Request sent;
    AuthService.client = MockClient((request) async {
      sent = request;
      return _json(200, {'status': 'success', 'data': _userJson});
    });

    await AuthService.restoreSession();

    expect(sent.headers['Authorization'], 'Bearer ${'d' * 64}');
    expect(AuthService.currentUser.value?.username, 'tester');
  });

  test('logout revokes the token and clears local state', () async {
    FlutterSecureStorage.setMockInitialValues({'auth_token': 'e' * 64});
    http.Request? sent;
    AuthService.client = MockClient((request) async {
      sent = request;
      return _json(200, {'status': 'success'});
    });

    await AuthService.logout();

    expect(sent?.url.queryParameters['action'], 'logout');
    expect(await AuthService.getToken(), isNull);
    expect(AuthService.currentUser.value, isNull);
  });

  test('login still succeeds when secure storage throws', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(
            code: 'broken',
            message: 'storage unavailable',
          );
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    // Force the real method-channel implementation instead of the mock.
    FlutterSecureStoragePlatform.instance = MethodChannelFlutterSecureStorage();
    AuthService.client = MockClient(
      (_) async => _json(200, {
        'status': 'success',
        'token': '1' * 64,
        'data': _userJson,
      }),
    );

    final user = await AuthService.login('00000001', 'secret123');

    expect(user.username, 'tester');
    expect(AuthService.currentUser.value, isNotNull);
    expect(await AuthService.getToken(), '1' * 64);
  });
}
