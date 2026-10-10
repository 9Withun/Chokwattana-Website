import 'package:flutter/material.dart';
import 'package:project/data/callapi.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const _green = Color(0xFF159B12);

  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [
      _username,
      _password,
      _confirm,
      _phone,
      _email,
      _address,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
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
        address: _address.text,
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
    String label, {
    bool obscure = false,
    TextInputType? keyboardType,
    int? maxLength,
    int maxLines = 1,
    String? Function(String value)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        key: ValueKey(key),
        controller: controller,
        enabled: !_submitting,
        obscureText: obscure,
        keyboardType: keyboardType,
        maxLength: maxLength,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          counterText: '',
        ),
        validator: validator == null ? null : (v) => validator(v ?? ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        title: const Text('สมัครสมาชิก'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _field(
                    'register-username',
                    _username,
                    'ชื่อผู้ใช้ *',
                    maxLength: 20,
                    validator: (v) =>
                        v.trim().isEmpty ? 'กรุณากรอกชื่อผู้ใช้' : null,
                  ),
                  _field(
                    'register-password',
                    _password,
                    'รหัสผ่าน (อย่างน้อย 8 ตัว) *',
                    obscure: true,
                    maxLength: 72,
                    validator: (v) => v.length < 8
                        ? 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร'
                        : null,
                  ),
                  _field(
                    'register-confirm',
                    _confirm,
                    'ยืนยันรหัสผ่าน *',
                    obscure: true,
                    validator: (v) =>
                        v != _password.text ? 'รหัสผ่านไม่ตรงกัน' : null,
                  ),
                  _field(
                    'register-phone',
                    _phone,
                    'เบอร์โทรศัพท์ *',
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    validator: (v) => RegExp(r'^\d{1,10}$').hasMatch(v.trim())
                        ? null
                        : 'กรอกตัวเลข 1-10 หลัก',
                  ),
                  _field(
                    'register-email',
                    _email,
                    'อีเมล',
                    keyboardType: TextInputType.emailAddress,
                    maxLength: 50,
                    validator: (v) =>
                        v.trim().isEmpty ||
                            RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(v.trim())
                        ? null
                        : 'รูปแบบอีเมลไม่ถูกต้อง',
                  ),
                  _field('register-address', _address, 'ที่อยู่', maxLines: 3),
                  if (_error != null) ...[
                    Text(
                      _error!,
                      key: const ValueKey('register-error'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  FilledButton(
                    key: const ValueKey('register-submit'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('สมัครสมาชิก'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
