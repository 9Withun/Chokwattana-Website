import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project/appUI/auth_layout.dart';
import 'package:project/data/callapi.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  bool _acceptedTerms = false;
  bool _termsError = false;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_username, _password, _confirm, _phone, _email]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final valid = _formKey.currentState!.validate();
    setState(() => _termsError = !_acceptedTerms);
    if (!valid || !_acceptedTerms) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await AuthService.register(
        username: _username.text,
        password: _password.text,
        phoneNumber: _phone.text,
        email: _email.text,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Widget _field(
    String key,
    TextEditingController controller,
    String hint, {
    bool obscure = false,
    TextInputType? keyboardType,
    int? maxLength,
    Iterable<String>? autofillHints,
    String? Function(String value)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        key: ValueKey(key),
        controller: controller,
        enabled: !_submitting,
        obscureText: obscure,
        keyboardType: keyboardType,
        maxLength: maxLength,
        autofillHints: autofillHints,
        textInputAction: TextInputAction.next,
        decoration: AuthLayout.fieldDecoration(hint),
        validator: validator == null ? null : (v) => validator(v ?? ''),
      ),
    );
  }

  Widget _buildTerms(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return Column(
      children: [
        InkWell(
          key: const ValueKey('register-accept-terms'),
          onTap: _submitting
              ? null
              : () => setState(() {
                  _acceptedTerms = !_acceptedTerms;
                  if (_acceptedTerms) _termsError = false;
                }),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1, right: 4),
                child: Icon(
                  _acceptedTerms
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 22,
                  color: _acceptedTerms
                      ? AuthLayout.green
                      : (_termsError ? error : Colors.black87),
                ),
              ),
              const Flexible(
                child: Text.rich(
                  AuthLayout.termsText,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        if (_termsError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'กรุณายอมรับเงื่อนไขการให้บริการและนโยบายความเป็นส่วนตัว',
              style: TextStyle(color: error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'สมัครสมาชิก',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(
              'register-username',
              _username,
              'ชื่อ-สกุล',
              maxLength: 20,
              autofillHints: const [AutofillHints.name],
              validator: (v) => v.trim().isEmpty ? 'กรุณากรอกชื่อ-สกุล' : null,
            ),
            _field(
              'register-email',
              _email,
              'e-mail',
              keyboardType: TextInputType.emailAddress,
              maxLength: 50,
              autofillHints: const [AutofillHints.email],
              validator: (v) =>
                  v.trim().isEmpty ||
                      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())
                  ? null
                  : 'รูปแบบอีเมลไม่ถูกต้อง',
            ),
            _field(
              'register-phone',
              _phone,
              'เบอร์โทรศัพท์/เลขสมาชิก',
              keyboardType: TextInputType.phone,
              // Room for dashes/spaces; they are stripped before sending.
              maxLength: 14,
              autofillHints: const [AutofillHints.telephoneNumber],
              validator: (v) =>
                  RegExp(r'^\d{1,10}$')
                      .hasMatch(AuthService.normalizePhone(v.trim()))
                  ? null
                  : 'กรอกตัวเลข 1-10 หลัก',
            ),
            _field(
              'register-password',
              _password,
              'รหัสผ่าน',
              obscure: true,
              maxLength: 72,
              autofillHints: const [AutofillHints.newPassword],
              validator: (v) {
                if (v.length < 8) {
                  return 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';
                }
                // The API limits passwords to 72 bytes, not characters.
                if (utf8.encode(v).length > 72) {
                  return 'รหัสผ่านยาวเกินไป (สูงสุด 72 ไบต์)';
                }
                return null;
              },
            ),
            _field(
              'register-confirm',
              _confirm,
              'ยืนยันรหัสผ่าน',
              obscure: true,
              validator: (v) =>
                  v != _password.text ? 'รหัสผ่านไม่ตรงกัน' : null,
            ),
            if (_error != null) ...[
              const SizedBox(height: 4),
              Text(
                _error!,
                key: const ValueKey('register-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 8),
            Center(
              child: FilledButton(
                key: const ValueKey('register-submit'),
                style: AuthLayout.submitStyle(),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? AuthLayout.submitProgress
                    : const Text('สมัครสมาชิก', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(height: 24),
            _buildTerms(context),
            const SizedBox(height: 20),
            AuthLayout.switchRow(
              linkKey: const ValueKey('register-to-login'),
              prompt: 'มีบัญชีแล้ว',
              link: 'ลงชื่อเข้าใช้',
              onPressed: _submitting
                  ? null
                  : () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}
