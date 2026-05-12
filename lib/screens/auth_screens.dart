import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../services/supabase_service.dart';
import 'main_navigation.dart';
import 'admin_login_screen.dart';

// ═══════════════════════════════════════════════════════════════
// 3D PREMIUM DARK — ДИЗАЙНЫ ТОКЕНУУД
// ═══════════════════════════════════════════════════════════════
class _T {
  static const Color bg = Color(0xFF030712);
  static const Color surface = Color(0xFF080F1E);
  static const Color glass = Color(0xFF0D1424);
  static const Color glassHi = Color(0xFF0F1E3A);
  static const Color border = Color(0xFF1E3A5F);
  static const Color borderAct = Color(0xFF2563EB);

  static const Color neon = Color(0xFF3B82F6);
  static const Color neonSoft = Color(0xFF60A5FA);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  static const Color txt1 = Color(0xFFF1F5F9);
  static const Color txt2 = Color(0xFF94A3B8);
  static const Color txt3 = Color(0xFF475569);
}

// ═══════════════════════════════════════════════════════════════
// АРЫН 3D ПЕРСПЕКТИВ ФОН
// ═══════════════════════════════════════════════════════════════
class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0x0A3B82F6)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 56) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 56) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final persp = Paint()
      ..color = const Color(0x0C1D4ED8)
      ..strokeWidth = 0.8;
    final vpX = size.width * 0.5;
    final vpY = size.height * 0.32;
    for (int i = -5; i <= 5; i++) {
      final x = size.width / 2 + i * 90.0;
      canvas.drawLine(Offset(vpX, vpY), Offset(x, size.height), persp);
    }
    for (int j = 1; j <= 6; j++) {
      final y = vpY + (size.height - vpY) * j / 6;
      final spread = (j / 6) * size.width * 0.52;
      canvas.drawLine(
        Offset(size.width / 2 - spread, y),
        Offset(size.width / 2 + spread, y),
        persp,
      );
    }

    final glow = Paint()..style = PaintingStyle.fill;
    final dots = <List<dynamic>>[
      [0.15, 0.10, _T.neon, 0.55],
      [0.82, 0.07, _T.purple, 0.45],
      [0.04, 0.52, _T.cyan, 0.40],
      [0.93, 0.42, _T.neon, 0.45],
      [0.48, 0.94, _T.purple, 0.38],
      [0.70, 0.65, _T.cyan, 0.30],
    ];
    for (final d in dots) {
      final ox = math.sin(t + (d[0] as double) * 6) * 18;
      final oy = math.cos(t * 0.75 + (d[1] as double) * 5) * 14;
      final x = (d[0] as double) * size.width + ox;
      final y = (d[1] as double) * size.height + oy;
      final c = d[2] as Color;
      final op = d[3] as double;
      glow.shader = RadialGradient(
        colors: [c.withOpacity(op * 0.28), c.withOpacity(0)],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: 130));
      canvas.drawCircle(Offset(x, y), 130, glow);
    }
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}

// ═══════════════════════════════════════════════════════════════
// ШИЛЭН КАРТ
// ═══════════════════════════════════════════════════════════════
class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F1E3A), Color(0xFF070E1D)],
        ),
        border: Border.all(color: _T.border),
        boxShadow: [
          BoxShadow(color: _T.neon.withOpacity(0.07), blurRadius: 60),
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 1,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ОРОЛТЫН ТАЛБАР — Tab + Enter дэмжинэ
// ═══════════════════════════════════════════════════════════════
class _AuthField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final VoidCallback? onSubmitted;
  final TextInputAction? textInputAction;

  const _AuthField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
    this.focusNode,
    this.nextFocusNode,
    this.onSubmitted,
    this.textInputAction,
  });

  @override
  State<_AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<_AuthField> {
  late FocusNode _node;

  @override
  void initState() {
    super.initState();
    // Use provided focusNode or create internal one
    _node = widget.focusNode ?? FocusNode();
    _node.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    // Only dispose if we created it internally
    if (widget.focusNode == null) _node.dispose();
    super.dispose();
  }

  bool get _focused => _node.hasFocus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: _T.txt3,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: _focused ? const Color(0xFF0D1E3D) : _T.surface,
            border: Border.all(
              color: _focused ? _T.neon.withOpacity(0.6) : _T.border,
              width: _focused ? 1.5 : 1,
            ),
            boxShadow: _focused
                ? [BoxShadow(color: _T.neon.withOpacity(0.12), blurRadius: 16)]
                : [],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _node,
            obscureText: widget.obscure,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            textInputAction: widget.textInputAction ?? TextInputAction.next,
            onSubmitted: (_) {
              if (widget.nextFocusNode != null) {
                widget.nextFocusNode!.requestFocus();
              } else {
                widget.onSubmitted?.call();
              }
            },
            style: const TextStyle(
              color: _T.txt1,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: _T.txt3, fontSize: 14),
              prefixIcon: Icon(
                widget.icon,
                color: _focused ? _T.neonSoft : _T.txt3,
                size: 20,
              ),
              suffixIcon: widget.suffix,
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ҮНДСЭН ТОВЧ
// ═══════════════════════════════════════════════════════════════
class _AuthBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final List<Color>? gradient;
  final Color? borderColor;
  final Color? textColor;

  const _AuthBtn({
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.gradient,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final grad = gradient ?? [const Color(0xFF1D4ED8), const Color(0xFF3B82F6)];
    final hasBorder = borderColor != null;
    return GestureDetector(
      onTap: loading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: hasBorder ? null : LinearGradient(colors: grad),
          color: hasBorder ? Colors.transparent : null,
          borderRadius: BorderRadius.circular(16),
          border: hasBorder ? Border.all(color: borderColor!) : null,
          boxShadow: hasBorder
              ? []
              : [
                  BoxShadow(
                    color: _T.neon.withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              Text(
                label,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Snackbar туслах
void _showMsg(BuildContext context, String msg, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    backgroundColor: isError ? _T.error : _T.success,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    margin: const EdgeInsets.all(16),
  ));
}

// ═══════════════════════════════════════════════════════════════
// НЭВТРЭХ ДЭЛГЭЦ — LoginScreen
// ═══════════════════════════════════════════════════════════════
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _loginCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _loginFocus = FocusNode();
  final _passFocus = FocusNode();
  bool _loading = false;
  bool _obscure = true;

  late AnimationController _bgCtrl;
  late AnimationController _entryCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _entryCtrl.dispose();
    _loginCtrl.dispose();
    _passCtrl.dispose();
    _loginFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  bool get _isEmail => _loginCtrl.text.contains('@');

  Future<void> _login() async {
    if (_loginCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      _showMsg(context, 'Бүх талбарыг бөглөнө үү', isError: true);
      return;
    }
    setState(() => _loading = true);
    try {
      if (_isEmail) {
        await SupabaseService.signInWithEmail(
          email: _loginCtrl.text.trim(),
          password: _passCtrl.text,
        );
      } else {
        await SupabaseService.signIn(
          phone: _loginCtrl.text.trim(),
          password: _passCtrl.text,
        );
      }
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showMsg(context, 'Нэвтрэх мэдээлэл буруу байна', isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      body: AnimatedBuilder(
        animation: _bgCtrl,
        builder: (_, __) => Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _BgPainter(_bgCtrl.value * 2 * math.pi),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLogo(),
                          const SizedBox(height: 36),
                          _GlassCard(
                            child: Padding(
                              padding: const EdgeInsets.all(28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Нэвтрэх',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: _T.txt1,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Зээлийн апликейшнд тавтай морилно уу',
                                    style:
                                        TextStyle(fontSize: 13, color: _T.txt2),
                                  ),
                                  const SizedBox(height: 28),
                                  _AuthField(
                                    controller: _loginCtrl,
                                    focusNode: _loginFocus,
                                    nextFocusNode: _passFocus,
                                    label: 'Утас эсвэл и-мэйл',
                                    hint: '80000000 эсвэл example@gmail.com',
                                    icon: Icons.person_outline_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 16),
                                  _AuthField(
                                    controller: _passCtrl,
                                    focusNode: _passFocus,
                                    onSubmitted: _login,
                                    label: 'Нууц үг',
                                    hint: '••••••••',
                                    icon: Icons.lock_outline_rounded,
                                    obscure: _obscure,
                                    textInputAction: TextInputAction.done,
                                    suffix: GestureDetector(
                                      onTap: () =>
                                          setState(() => _obscure = !_obscure),
                                      child: Icon(
                                        _obscure
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        size: 18,
                                        color: _T.txt3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Нууц үг мартсан?',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _T.neonSoft,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 26),
                                  _AuthBtn(
                                    label: 'Нэвтрэх',
                                    onPressed: _login,
                                    loading: _loading,
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Бүртгэл байхгүй юу? ',
                                        style: TextStyle(
                                            fontSize: 13, color: _T.txt2),
                                      ),
                                      GestureDetector(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const RegisterScreen()),
                                        ),
                                        child: Text(
                                          'Бүртгүүлэх',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: _T.neonSoft,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                  child:
                                      Container(height: 1, color: _T.border)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  'Эсвэл',
                                  style:
                                      TextStyle(fontSize: 12, color: _T.txt3),
                                ),
                              ),
                              Expanded(
                                  child:
                                      Container(height: 1, color: _T.border)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AdminLoginScreen()),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _T.border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings_outlined,
                                    size: 18,
                                    color: _T.txt2,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Администратор нэвтрэх',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _T.txt2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1D4ED8), Color(0xFF7C3AED)],
            ),
            boxShadow: [
              BoxShadow(
                color: _T.neon.withOpacity(0.4),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: _T.purple.withOpacity(0.2),
                blurRadius: 54,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 8,
                left: 10,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              ),
              const Icon(Icons.account_balance_rounded,
                  color: Colors.white, size: 34),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Сайн байна уу',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: _T.txt1,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [_T.neon, _T.purple],
          ).createShader(b),
          child: const Text(
            'Зээлийн удирдлагын систем',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// БҮРТГҮҮЛЭХ ДЭЛГЭЦ — RegisterScreen
// ═══════════════════════════════════════════════════════════════
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  int _step = 0;
  bool _loading = false;
  bool _obscure = true;

  final _lastNameCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _registerCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  // Focus nodes — алхам 1
  final _lastNameFocus = FocusNode();
  final _firstNameFocus = FocusNode();
  final _registerFocus = FocusNode();
  // Focus nodes — алхам 2
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passFocus2 = FocusNode();
  final _confirmFocus = FocusNode();

  late AnimationController _bgCtrl;
  late AnimationController _stepCtrl;
  late Animation<Offset> _slideStep;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _stepCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    _slideStep = Tween<Offset>(
      begin: const Offset(0.04, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _stepCtrl.dispose();
    _lastNameCtrl.dispose();
    _firstNameCtrl.dispose();
    _registerCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _lastNameFocus.dispose();
    _firstNameFocus.dispose();
    _registerFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _passFocus2.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_lastNameCtrl.text.isEmpty ||
        _firstNameCtrl.text.isEmpty ||
        _registerCtrl.text.isEmpty) {
      _showMsg(context, 'Бүх талбарыг бөглөнө үү', isError: true);
      return;
    }
    setState(() => _step = 1);
    _stepCtrl.forward(from: 0);
  }

  void _prevStep() {
    if (_step == 0) {
      Navigator.pop(context);
    } else {
      setState(() => _step = 0);
      _stepCtrl.forward(from: 0);
    }
  }

  Future<void> _register() async {
    if (_phoneCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _passCtrl.text.isEmpty ||
        _confirmPassCtrl.text.isEmpty) {
      _showMsg(context, 'Бүх талбарыг бөглөнө үү', isError: true);
      return;
    }
    if (!_emailCtrl.text.contains('@')) {
      _showMsg(context, 'И-мэйл хаяг буруу байна', isError: true);
      return;
    }
    if (_passCtrl.text.length < 8) {
      _showMsg(context, 'Нууц үг хамгийн багадаа 8 тэмдэгт байна',
          isError: true);
      return;
    }
    if (_passCtrl.text != _confirmPassCtrl.text) {
      _showMsg(context, 'Нууц үг таарахгүй байна', isError: true);
      return;
    }
    setState(() => _loading = true);
    try {
      await SupabaseService.signUp(
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        registerNumber: _registerCtrl.text.trim().toUpperCase(),
      );
      if (mounted) {
        _showMsg(
            context, 'Бүртгэл амжилттай! Утас эсвэл и-мэйлээрээ нэвтэрнэ үү.');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showMsg(context, 'Бүртгэл үүсгэхэд алдаа гарлаа: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      body: AnimatedBuilder(
        animation: _bgCtrl,
        builder: (_, __) => Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _BgPainter(_bgCtrl.value * 2 * math.pi),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
                      child: SlideTransition(
                        position: _slideStep,
                        child: _step == 0 ? _buildStep1() : _buildStep2(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: _prevStep,
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: _T.glass,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _T.border),
              ),
              child: const Icon(Icons.arrow_back_ios_rounded,
                  color: _T.txt2, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _step == 0 ? 'Хувийн мэдээлэл' : 'Нэвтрэх мэдээлэл',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _T.txt1,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(2, (i) {
                    final active = i <= _step;
                    return Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 3,
                        margin: EdgeInsets.only(right: i == 0 ? 6 : 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: active
                              ? const LinearGradient(
                                  colors: [_T.neon, _T.purple])
                              : null,
                          color: active ? null : _T.border,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${_step + 1}/2',
            style: const TextStyle(
              fontSize: 12,
              color: _T.txt3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepIcon(Icons.person_rounded, _T.neon),
            const SizedBox(height: 20),
            const Text(
              'Таны нэр болон регистр',
              style: TextStyle(fontSize: 13, color: _T.txt2),
            ),
            const SizedBox(height: 24),
            _AuthField(
              controller: _lastNameCtrl,
              focusNode: _lastNameFocus,
              nextFocusNode: _firstNameFocus,
              label: 'Овог',
              hint: 'Овгоо оруулна уу',
              icon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            _AuthField(
              controller: _firstNameCtrl,
              focusNode: _firstNameFocus,
              nextFocusNode: _registerFocus,
              label: 'Нэр',
              hint: 'Нэрээ оруулна уу',
              icon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            _AuthField(
              controller: _registerCtrl,
              focusNode: _registerFocus,
              onSubmitted: _nextStep,
              label: 'Регистрийн дугаар',
              hint: 'АА00000000',
              icon: Icons.badge_outlined,
              inputFormatters: [LengthLimitingTextInputFormatter(10)],
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 28),
            _AuthBtn(label: 'Үргэлжлэх', onPressed: _nextStep),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Аль хэдийн бүртгэлтэй юу? ',
                  style: TextStyle(fontSize: 13, color: _T.txt2),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'Нэвтрэх',
                    style: TextStyle(
                      fontSize: 13,
                      color: _T.neonSoft,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepIcon(Icons.lock_rounded, _T.purple),
            const SizedBox(height: 20),
            const Text(
              'Утас, и-мэйл болон нууц үг тохируулна уу',
              style: TextStyle(fontSize: 13, color: _T.txt2),
            ),
            const SizedBox(height: 24),
            _AuthField(
              controller: _phoneCtrl,
              focusNode: _phoneFocus,
              nextFocusNode: _emailFocus,
              label: 'Утасны дугаар',
              hint: '8 оронтой дугаар',
              icon: Icons.phone_iphone_rounded,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
            ),
            const SizedBox(height: 16),
            _AuthField(
              controller: _emailCtrl,
              focusNode: _emailFocus,
              nextFocusNode: _passFocus2,
              label: 'И-мэйл хаяг',
              hint: 'example@gmail.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            _AuthField(
              controller: _passCtrl,
              focusNode: _passFocus2,
              nextFocusNode: _confirmFocus,
              label: 'Нууц үг',
              hint: 'Хамгийн багадаа 8 тэмдэгт',
              icon: Icons.lock_outline_rounded,
              obscure: _obscure,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            _AuthField(
              controller: _confirmPassCtrl,
              focusNode: _confirmFocus,
              onSubmitted: _register,
              label: 'Нууц үг давтах',
              hint: 'Нууц үгийг дахин оруулна уу',
              icon: Icons.lock_outline_rounded,
              obscure: _obscure,
              textInputAction: TextInputAction.done,
              suffix: GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  _obscure
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 18,
                  color: _T.txt3,
                ),
              ),
            ),
            const SizedBox(height: 28),
            _AuthBtn(
              label: 'Бүртгүүлэх',
              onPressed: _register,
              loading: _loading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepIcon(IconData icon, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
