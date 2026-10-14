import 'package:flutter/material.dart';
import 'package:project/appUI/ui.dart';

/// Shared shell of the login and register pages: the tall banner on the left
/// and a white panel with the logo corner and a titled form on the right.
class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.title, required this.child});

  static const green = Color(0xFF159B12);
  static const darkGreen = Color(0xFF0B6B0B);
  static const linkBlue = Color(0xFF0B57D0);

  final String title;
  final Widget child;

  static InputDecoration fieldDecoration(String hint, {Widget? suffixIcon}) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
      borderSide: BorderSide(color: green),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: green, width: 2),
      ),
      counterText: '',
      suffixIcon: suffixIcon,
    );
  }

  static ButtonStyle submitStyle() => FilledButton.styleFrom(
    backgroundColor: darkGreen,
    minimumSize: const Size(140, 53),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2)),
    ),
  );

  static const submitProgress = SizedBox(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
  );

  /// "ฉันได้อ่านและยอมรับ เงื่อนไขการให้บริการ และ นโยบายความเป็นส่วนตัว ..."
  static const termsText = TextSpan(
    style: TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
    children: [
      TextSpan(text: 'ฉันได้อ่านและยอมรับ '),
      TextSpan(
        text: 'เงื่อนไขการให้บริการ',
        style: TextStyle(color: green),
      ),
      TextSpan(text: ' และ\n'),
      TextSpan(
        text: 'นโยบายความเป็นส่วนตัว',
        style: TextStyle(color: green),
      ),
      TextSpan(text: ' ของ ChokwattanaHomeCenter'),
    ],
  );

  /// `<prompt> <link>` row under the form, e.g. "ยังไม่มีบัญชี? สมัครสมาชิก".
  static Widget switchRow({
    required Key linkKey,
    required String prompt,
    required String link,
    required VoidCallback? onPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(prompt, style: const TextStyle(fontSize: 14)),
        TextButton(
          key: linkKey,
          style: TextButton.styleFrom(
            foregroundColor: linkBlue,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: onPressed,
          child: Text(link),
        ),
      ],
    );
  }

  Widget _buildPanel() {
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
                color: green,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: green,
                          fontSize: 38,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: green,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    child,
                  ],
                ),
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
                        Expanded(flex: 555, child: _buildPanel()),
                      ],
                    ),
                  )
                : _buildPanel(),
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
