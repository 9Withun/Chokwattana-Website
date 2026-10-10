import 'package:flutter/material.dart';
import 'package:project/appUI/register_page.dart';
import 'package:project/data/callapi.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _green = Color(0xFF159B12);

  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await AuthService.login(_loginController.text, _passwordController.text);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _openRegister() async {
    final registered = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => const RegisterPage()));
    // Registering signs the member in, so there is nothing left to do here.
    if (registered == true && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        title: const Text('เข้าสู่ระบบ'),
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
                  TextFormField(
                    key: const ValueKey('login-field'),
                    controller: _loginController,
                    enabled: !_submitting,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.username],
                    decoration: const InputDecoration(
                      labelText: 'รหัสสมาชิก หรือ ชื่อผู้ใช้',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value ?? '').trim().isEmpty
                        ? 'กรุณากรอกรหัสสมาชิกหรือชื่อผู้ใช้'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const ValueKey('password-field'),
                    controller: _passwordController,
                    enabled: !_submitting,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'รหัสผ่าน',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: _obscure ? 'แสดงรหัสผ่าน' : 'ซ่อนรหัสผ่าน',
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (value) =>
                        (value ?? '').isEmpty ? 'กรุณากรอกรหัสผ่าน' : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      key: const ValueKey('login-error'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    key: const ValueKey('login-submit'),
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
                        : const Text('เข้าสู่ระบบ'),
                  ),
                  TextButton(
                    key: const ValueKey('login-to-register'),
                    onPressed: _submitting ? null : _openRegister,
                    child: const Text('ยังไม่มีบัญชี? สมัครสมาชิก'),
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
