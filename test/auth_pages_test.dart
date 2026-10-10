import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:project/appUI/login_page.dart';
import 'package:project/data/callapi.dart';

const _user = {
  'id': 9,
  'member_id': '00000009',
  'username': 'newbie',
  'email': null,
  'phonenumber': '0812345678',
  'address': null,
  'payment_method': null,
};

http.Response _json(int status, Map<String, dynamic> body) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

/// Opens [LoginPage] from a launcher button so pop results are observable.
Future<void> _pumpLauncher(WidgetTester tester, ValueNotifier<bool?> result) {
  return tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () async {
                result.value = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    AuthService.currentUser.value = null;
  });

  testWidgets('login page validates, signs in and closes', (tester) async {
    final calls = <Uri>[];
    AuthService.client = MockClient((request) async {
      calls.add(request.url);
      return _json(200, {
        'status': 'success',
        'token': 'f' * 64,
        'data': _user,
      });
    });
    final result = ValueNotifier<bool?>(null);
    await _pumpLauncher(tester, result);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pump();
    expect(find.text('กรุณากรอกรหัสสมาชิกหรือชื่อผู้ใช้'), findsOneWidget);
    expect(calls, isEmpty);

    await tester.enterText(
      find.byKey(const ValueKey('login-field')),
      '00000009',
    );
    await tester.enterText(
      find.byKey(const ValueKey('password-field')),
      'secret123',
    );
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();

    expect(result.value, isTrue);
    expect(AuthService.currentUser.value?.username, 'newbie');
  });

  testWidgets('login page shows the server error and stays open', (
    tester,
  ) async {
    AuthService.client = MockClient(
      (_) async => _json(401, {
        'status': 'error',
        'message': 'Invalid login or password.',
      }),
    );
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.enterText(find.byKey(const ValueKey('login-field')), 'x');
    await tester.enterText(
      find.byKey(const ValueKey('password-field')),
      'badpass12',
    );
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Invalid login or password.'), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(AuthService.currentUser.value, isNull);
  });

  testWidgets('register page validates then registers and signs in', (
    tester,
  ) async {
    late http.Request sent;
    AuthService.client = MockClient((request) async {
      sent = request;
      return _json(201, {
        'status': 'success',
        'token': 'a' * 64,
        'data': _user,
      });
    });
    final result = ValueNotifier<bool?>(null);
    await _pumpLauncher(tester, result);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('login-to-register')));
    await tester.pumpAndSettle();

    // Mismatched confirmation and a short password are rejected locally.
    await tester.enterText(
      find.byKey(const ValueKey('register-username')),
      'newbie',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-password')),
      'short',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-confirm')),
      'other',
    );
    await tester.enterText(find.byKey(const ValueKey('register-phone')), '08x');
    await tester.ensureVisible(find.byKey(const ValueKey('register-submit')));
    await tester.tap(find.byKey(const ValueKey('register-submit')));
    await tester.pump();
    expect(find.text('รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร'), findsOneWidget);
    expect(find.text('รหัสผ่านไม่ตรงกัน'), findsOneWidget);
    expect(find.text('กรอกตัวเลข 1-10 หลัก'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('register-password')),
      'secret123',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-confirm')),
      'secret123',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-phone')),
      '0812345678',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('register-submit')));
    await tester.tap(find.byKey(const ValueKey('register-submit')));
    await tester.pumpAndSettle();

    expect(sent.url.queryParameters, {
      'resource': 'auth',
      'action': 'register',
    });
    expect(jsonDecode(sent.body), {
      'username': 'newbie',
      'password': 'secret123',
      'phonenumber': '0812345678',
    });
    // Registration closes both pages and reports success to the opener.
    expect(result.value, isTrue);
    expect(find.byType(LoginPage), findsNothing);
    expect(AuthService.currentUser.value?.memberId, '00000009');
  });
}
