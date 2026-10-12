import 'package:flutter/material.dart';
import 'package:project/appUI/register_page.dart';
import 'package:project/appUI/ui.dart';
import 'package:project/data/callapi.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _green = Color(0xFF159B12);
  static const _darkGreen = Color(0xFF0B6B0B);

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

  InputDecoration _fieldDecoration(String hint, {Widget? suffixIcon}) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
      borderSide: BorderSide(color: _green),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: _green, width: 2),
      ),
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text(
              'ลงชื่อเข้าใช้',
              style: TextStyle(
                color: _green,
                fontSize: 38,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: _green,
              ),
            ),
          ),
          const SizedBox(height: 40),
          TextFormField(
            key: const ValueKey('login-field'),
            controller: _loginController,
            enabled: !_submitting,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            decoration: _fieldDecoration('เบอร์โทรศัพท์/เลขสมาชิก'),
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
            decoration: _fieldDecoration(
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
              style: FilledButton.styleFrom(
                backgroundColor: _darkGreen,
                minimumSize: const Size(140, 53),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
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
                  : const Text('ลงชื่อเข้าใช้', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(height: 28),
          const Center(
            child: Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                style: TextStyle(fontSize: 14, height: 1.4),
                children: [
                  TextSpan(text: 'ฉันได้อ่านและยอมรับ '),
                  TextSpan(
                    text: 'เงื่อนไขการให้บริการ',
                    style: TextStyle(color: _green),
                  ),
                  TextSpan(text: ' และ\n'),
                  TextSpan(
                    text: 'นโยบายความเป็นส่วนตัว',
                    style: TextStyle(color: _green),
                  ),
                  TextSpan(text: ' ของ ChokwattanaHomeCenter'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('ยังไม่มีบัญชี?', style: TextStyle(fontSize: 14)),
              TextButton(
                key: const ValueKey('login-to-register'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0B57D0),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: _submitting ? null : _openRegister,
                child: const Text('สมัครสมาชิก'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPanel(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 108,
            child: ClipPath(
              clipper: _LogoCornerClipper(),
              child: Container(
                color: _green,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 12),
                child: SizedBox(
                  width: 230,
                  child: Image.asset(
                    'lib/Images/Logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: _buildForm(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: HomeTopBar.appBar(context),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1255),
            child: wide
                ? IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 700,
                          child: Image.asset(
                            'lib/Images/asset/banner/bannerตั้ง.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(flex: 555, child: _buildPanel(context)),
                      ],
                    ),
                  )
                : _buildPanel(context),
          ),
        ),
      ),
    );
  }
}

/// Green banner behind the logo whose right edge is cut diagonally.
class _LogoCornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.68, 0)
      ..lineTo(size.width * 0.45, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
