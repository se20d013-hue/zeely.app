import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

// ═══════════════════════════════════════════════════════════════
// APPEARANCE ДЭЛГЭЦ
// ═══════════════════════════════════════════════════════════════
class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, tp, _) => _AppearanceBody(tp: tp),
    );
  }
}

class _AppearanceBody extends StatelessWidget {
  final ThemeProvider tp;
  const _AppearanceBody({required this.tp});

  @override
  Widget build(BuildContext context) {
    final isDark = tp.mode == ThemeMode.dark ||
        (tp.mode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    final bg = isDark ? const Color(0xFF030712) : const Color(0xFFF8FAFC);
    final surface = isDark ? const Color(0xFF080F1E) : Colors.white;
    final glass = isDark ? const Color(0xFF0D1424) : const Color(0xFFF1F5F9);
    final border = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE2E8F0);
    final txt1 = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final txt2 = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final txt3 = isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8);
    final accent = tp.accent.color;
    final accentL = tp.accent.light;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: glass,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border),
            ),
            child: Icon(Icons.arrow_back_ios_rounded, color: txt2, size: 15),
          ),
        ),
        title: Text(
          'Гадаад байдал',
          style:
              TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: txt1),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: border.withOpacity(0.5)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Theme горим ──────────────────────────────────
            _label('THEME ГОРИМ', accentL, txt3),
            const SizedBox(height: 10),
            _card(
              surface,
              border,
              isDark,
              child: Column(children: [
                _themeOption(
                    label: 'Dark',
                    sublabel: 'Харанхуй горим',
                    icon: Icons.dark_mode_rounded,
                    selected: tp.mode == ThemeMode.dark,
                    accent: accent,
                    accentL: accentL,
                    surface: surface,
                    border: border,
                    txt1: txt1,
                    txt2: txt2,
                    isDark: isDark,
                    onTap: () => tp.setMode(ThemeMode.dark),
                    preview: _darkPreview(accent)),
                Divider(color: border.withOpacity(0.5), height: 1),
                _themeOption(
                    label: 'Light',
                    sublabel: 'Гэрэл горим',
                    icon: Icons.light_mode_rounded,
                    selected: tp.mode == ThemeMode.light,
                    accent: accent,
                    accentL: accentL,
                    surface: surface,
                    border: border,
                    txt1: txt1,
                    txt2: txt2,
                    isDark: isDark,
                    onTap: () => tp.setMode(ThemeMode.light),
                    preview: _lightPreview(accent)),
                Divider(color: border.withOpacity(0.5), height: 1),
                _themeOption(
                    label: 'System',
                    sublabel: 'Системийн тохиргоо',
                    icon: Icons.contrast_rounded,
                    selected: tp.mode == ThemeMode.system,
                    accent: accent,
                    accentL: accentL,
                    surface: surface,
                    border: border,
                    txt1: txt1,
                    txt2: txt2,
                    isDark: isDark,
                    onTap: () => tp.setMode(ThemeMode.system),
                    preview: _systemPreview(accent),
                    isLast: true),
              ]),
            ),
            const SizedBox(height: 24),

            // ── Accent өнгө ──────────────────────────────────
            _label('ACCENT ӨНГӨ', accentL, txt3),
            const SizedBox(height: 10),
            _card(
              surface,
              border,
              isDark,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Апликейшний гол өнгийг сонгоно уу',
                      style: TextStyle(fontSize: 12, color: txt2)),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.6,
                    children: kAccentColors.map((ac) {
                      final sel = tp.accent.id == ac.id;
                      return GestureDetector(
                        onTap: () => tp.setAccent(ac),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: sel
                                  ? ac.gradient
                                  : [
                                      ac.color
                                          .withOpacity(isDark ? 0.12 : 0.08),
                                      ac.color.withOpacity(isDark ? 0.06 : 0.04)
                                    ],
                            ),
                            border: Border.all(
                                color:
                                    sel ? ac.color : ac.color.withOpacity(0.25),
                                width: sel ? 2 : 1),
                            boxShadow: sel
                                ? [
                                    BoxShadow(
                                        color: ac.color.withOpacity(0.35),
                                        blurRadius: 12)
                                  ]
                                : [],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: sel
                                            ? Colors.white.withOpacity(0.25)
                                            : ac.color.withOpacity(0.2)),
                                    child: Center(
                                        child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: sel
                                                    ? Colors.white
                                                    : ac.color))),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(ac.label,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: sel
                                              ? Colors.white
                                              : (isDark
                                                  ? ac.light
                                                  : ac.color))),
                                ],
                              ),
                              if (sel)
                                Positioned(
                                    top: 6,
                                    right: 6,
                                    child: Icon(Icons.check_circle_rounded,
                                        color: Colors.white.withOpacity(0.9),
                                        size: 14)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),

            // ── Урьдчилж харах ───────────────────────────────
            _label('УРЬДЧИЛЖ ХАРАХ', accentL, txt3),
            const SizedBox(height: 10),
            _previewCard(context, surface, border, glass, txt1, txt2, accent,
                accentL, isDark, tp),
            const SizedBox(height: 32),

            // ══ ХАДГАЛАХ ТОВЧ ════════════════════════════════
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Тохиргоо хадгалагдлаа!',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  backgroundColor: accent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                ));
                Future.delayed(const Duration(milliseconds: 600), () {
                  if (context.mounted) Navigator.pop(context);
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: tp.accent.gradient),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: accent.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    const Text('Хадгалах',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, Color accent, Color txt3) => Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [accent, accent.withOpacity(0.4)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: txt3,
                  letterSpacing: 1.2)),
        ],
      );

  Widget _card(Color surface, Color border, bool isDark,
          {required Widget child}) =>
      Container(
        decoration: BoxDecoration(
          color: isDark ? null : surface,
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F1E3A), Color(0xFF070E1D)])
              : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
          boxShadow: isDark
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3), blurRadius: 20)
                ]
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 16)
                ],
        ),
        child: ClipRRect(borderRadius: BorderRadius.circular(20), child: child),
      );

  Widget _themeOption({
    required String label,
    required String sublabel,
    required IconData icon,
    required bool selected,
    required Color accent,
    required Color accentL,
    required Color surface,
    required Color border,
    required Color txt1,
    required Color txt2,
    required bool isDark,
    required VoidCallback onTap,
    required Widget preview,
    bool isLast = false,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: selected
                  ? accent.withOpacity(isDark ? 0.08 : 0.06)
                  : Colors.transparent),
          child: Row(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(width: 56, height: 38, child: preview)),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(label,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color:
                                selected ? (isDark ? accentL : accent) : txt1)),
                    Text(sublabel, style: TextStyle(fontSize: 11, color: txt2)),
                  ])),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? accent : Colors.transparent,
                    border: Border.all(
                        color: selected ? accent : border, width: 2)),
                child: selected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 12)
                    : null,
              ),
            ],
          ),
        ),
      );

  Widget _darkPreview(Color accent) => Container(
        color: const Color(0xFF030712),
        child: Stack(children: [
          Positioned(
              top: 4,
              left: 4,
              right: 4,
              child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                      color: const Color(0xFF0F1E3A),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: const Color(0xFF1E3A5F), width: 0.5)))),
          Positioned(
              top: 16,
              left: 4,
              right: 4,
              child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        accent.withOpacity(0.6),
                        accent.withOpacity(0.3)
                      ]),
                      borderRadius: BorderRadius.circular(4)))),
        ]),
      );

  Widget _lightPreview(Color accent) => Container(
        color: const Color(0xFFF8FAFC),
        child: Stack(children: [
          Positioned(
              top: 4,
              left: 4,
              right: 4,
              child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: const Color(0xFFE2E8F0), width: 0.5)))),
          Positioned(
              top: 16,
              left: 4,
              right: 4,
              child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [accent, accent.withOpacity(0.7)]),
                      borderRadius: BorderRadius.circular(4)))),
        ]),
      );

  Widget _systemPreview(Color accent) => Row(children: [
        Expanded(child: _darkPreview(accent)),
        Expanded(child: _lightPreview(accent)),
      ]);

  // ── Preview карт — "Нэвтрэх"/"Буцах" товч хасагдсан ──────
  Widget _previewCard(
      BuildContext context,
      Color surface,
      Color border,
      Color glass,
      Color txt1,
      Color txt2,
      Color accent,
      Color accentL,
      bool isDark,
      ThemeProvider tp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? null : surface,
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F1E3A), Color(0xFF070E1D)])
            : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [BoxShadow(color: accent.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: tp.accent.gradient),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: accent.withOpacity(0.4), blurRadius: 10)
                  ],
                ),
                child: const Icon(Icons.palette_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Урьдчилж харах',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: txt1)),
                Text('Таны сонгосон загвар',
                    style: TextStyle(fontSize: 11, color: txt2)),
              ]),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: tp.accent.gradient),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: accent.withOpacity(0.35), blurRadius: 8)
                  ],
                ),
                child: Text(tp.accent.label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 4,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: tp.accent.gradient),
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 14),
          // ── Accent өнгөний жишээ элементүүд ──
          Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: tp.accent.gradient),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.credit_card_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: tp.accent.gradient),
                  borderRadius: BorderRadius.circular(8)),
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: tp.accent.gradient),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white, size: 16),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: tp.accent.gradient),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: accent.withOpacity(0.3), blurRadius: 8)
                ],
              ),
              child: const Text('Жишээ',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
        ],
      ),
    );
  }
}
