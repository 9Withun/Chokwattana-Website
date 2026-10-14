import 'package:flutter/material.dart';
import 'package:project/appUI/auth_layout.dart';
import 'package:project/appUI/register_page.dart';
import 'package:project/data/callapi.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          TextFormField(
            key: const ValueKey('login-field'),
            controller: _loginController,
            enabled: !_submitting,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            decoration: AuthLayout.fieldDecoration('เบอร์โทรศัพท์/เลขสมาชิก'),
            validator: (value) => (value ?? '').trim().isEmpty
                ? 'กรุณากรอกเบอร์โทรศัพท์หรือเลขสมาชิก'
                : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: const ValueKey('password-field'),
            controller: _passwordController,
            enabled: !_submitting,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) => _submit(),
            decoration: AuthLayout.fieldDecoration(
              'รหัสผ่าน',
              suffixIcon: IconButton(
                tooltip: _obscure ? 'แสดงรหัสผ่าน' : 'ซ่อนรหัสผ่าน',
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
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
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 14),
          Center(
            child: FilledButton(
              key: const ValueKey('login-submit'),
              style: AuthLayout.submitStyle(),
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? AuthLayout.submitProgress
                  : const Text('ลงชื่อเข้าใช้', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(height: 28),
          const Center(
            child: Text.rich(AuthLayout.termsText, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 20),
          AuthLayout.switchRow(
            linkKey: const ValueKey('login-to-register'),
            prompt: 'ยังไม่มีบัญชี?',
            link: 'สมัครสมาชิก',
            onPressed: _submitting ? null : _openRegister,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(title: 'ลงชื่อเข้าใช้', child: _buildForm(context));
  }
}
