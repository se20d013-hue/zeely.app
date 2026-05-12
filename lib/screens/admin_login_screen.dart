import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/supabase_service.dart';
import 'admin_dashboard_screen.dart';

// ═══════════════════════════════════════════════════════════════
// 3D PREMIUM DARK — ТОКЕНУУД
// ═══════════════════════════════════════════════════════════════
class _T {
  static const Color bg = Color(0xFF030712);
  static const Color surface = Color(0xFF080F1E);
  static const Color glass = Color(0xFF0D1424);
  static const Color border = Color(0xFF1E3A5F);

  static const Color neon = Color(0xFF3B82F6);
  static const Color neonSoft = Color(0xFF60A5FA);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);

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
    final vpY = size.height * 0.28;
    for (int i = -5; i <= 5; i++) {
      canvas.drawLine(
        Offset(vpX, vpY),
        Offset(size.width / 2 + i * 90.0, size.height),
        persp,
      );
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
      [0.12, 0.08, _T.neon, 0.50],
      [0.85, 0.06, _T.purple, 0.42],
      [0.04, 0.50, _T.cyan, 0.36],
      [0.94, 0.40, _T.neon, 0.42],
      [0.50, 0.95, _T.purple, 0.36],
      [0.72, 0.62, _T.cyan, 0.28],
    ];
    for (final d in dots) {
      final ox = math.sin(t + (d[0] as double) * 6.0) * 18;
      final oy = math.cos(t * 0.75 + (d[1] as double) * 5.0) * 14;
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
                  Colors.white.withOpacity(0.10),
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
class _Field extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final VoidCallback? onSubmitted;
  final TextInputAction? textInputAction;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.focusNode,
    this.nextFocusNode,
    this.onSubmitted,
    this.textInputAction,
  });

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  late FocusNode _node;

  @override
  void initState() {
    super.initState();
    _node = widget.focusNode ?? FocusNode();
    _node.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
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
// ADMIN НЭВТРЭХ ДЭЛГЭЦ
// ═══════════════════════════════════════════════════════════════
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with TickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  bool _loading = false;
  bool _showPass = false;

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
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _showMsg(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      backgroundColor: isError ? _T.error : _T.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
    ));
  }

  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      _showMsg('И-мэйл болон нууц үгээ оруулна уу', isError: true);
      return;
    }
    setState(() => _loading = true);
    try {
      await SupabaseService.signInWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      final admin = await SupabaseService.isAdmin();
      if (!admin) {
        await SupabaseService.signOut();
        if (mounted) _showMsg('Танд admin эрх байхгүй байна', isError: true);
        return;
      }
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      }
    } catch (e) {
      if (mounted) _showMsg('Нэвтрэхэд алдаа гарлаа', isError: true);
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

            // Буцах товч
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _T.glass,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _T.border),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: _T.txt2,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),

            // Үндсэн агуулга
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
                          _buildWarningBadge(),
                          const SizedBox(height: 20),
                          _GlassCard(
                            child: Padding(
                              padding: const EdgeInsets.all(28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Нэвтрэх',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: _T.txt1,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Зөвхөн эрх бүхий хэрэглэгч нэвтэрнэ',
                                    style:
                                        TextStyle(fontSize: 13, color: _T.txt2),
                                  ),
                                  const SizedBox(height: 28),

                                  // И-мэйл
                                  _Field(
                                    controller: _emailCtrl,
                                    focusNode: _emailFocus,
                                    nextFocusNode: _passFocus,
                                    label: 'И-мэйл хаяг',
                                    hint: 'admin@example.com',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 16),

                                  // Нууц үг
                                  _Field(
                                    controller: _passCtrl,
                                    focusNode: _passFocus,
                                    onSubmitted: _login,
                                    label: 'Нууц үг',
                                    hint: '••••••••',
                                    icon: Icons.lock_outline_rounded,
                                    obscure: !_showPass,
                                    textInputAction: TextInputAction.done,
                                    suffix: GestureDetector(
                                      onTap: () => setState(
                                          () => _showPass = !_showPass),
                                      child: Icon(
                                        _showPass
                                            ? Icons.visibility_rounded
                                            : Icons.visibility_off_rounded,
                                        size: 18,
                                        color: _T.txt3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  _buildLoginBtn(),
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
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _T.neon.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1B3A6B), Color(0xFF7C3AED)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _T.neon.withOpacity(0.4),
                    blurRadius: 28,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: _T.purple.withOpacity(0.25),
                    blurRadius: 50,
                    spreadRadius: 8,
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
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Админ Панел',
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

  Widget _buildWarningBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: _T.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _T.warning.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _T.warning.withOpacity(0.15),
            ),
            child: const Icon(
              Icons.security_rounded,
              color: _T.warning,
              size: 15,
            ),
          ),
          const SizedBox(width: 10),
          const Flexible(
            child: Text(
              'Энэ хуудас зөвхөн системийн администраторт зориулагдсан',
              style: TextStyle(
                fontSize: 12,
                color: _T.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginBtn() {
    return GestureDetector(
      onTap: _loading ? null : _login,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: _loading
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF1B3A6B), Color(0xFF3B82F6)],
                ),
          color: _loading ? const Color(0xFF0D1E3D) : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _loading
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
            if (_loading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            else ...[
              const Icon(Icons.login_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Нэвтрэх',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
