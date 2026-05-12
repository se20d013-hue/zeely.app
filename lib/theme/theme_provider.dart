import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════════════════
// ACCENT ӨНГӨНҮҮД
// ═══════════════════════════════════════════════════════════════
class AccentColor {
  final String id;
  final String label;
  final Color color;
  final Color light;
  final List<Color> gradient;

  const AccentColor({
    required this.id,
    required this.label,
    required this.color,
    required this.light,
    required this.gradient,
  });
}

const kAccentColors = <AccentColor>[
  AccentColor(
    id: 'blue',
    label: 'Цэнхэр',
    color: Color(0xFF3B82F6),
    light: Color(0xFF60A5FA),
    gradient: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
  ),
  AccentColor(
    id: 'purple',
    label: 'Ягаан',
    color: Color(0xFF8B5CF6),
    light: Color(0xFFA78BFA),
    gradient: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
  ),
  AccentColor(
    id: 'cyan',
    label: 'Цайвар',
    color: Color(0xFF06B6D4),
    light: Color(0xFF22D3EE),
    gradient: [Color(0xFF0E7490), Color(0xFF06B6D4)],
  ),
  AccentColor(
    id: 'green',
    label: 'Ногоон',
    color: Color(0xFF10B981),
    light: Color(0xFF34D399),
    gradient: [Color(0xFF047857), Color(0xFF10B981)],
  ),
  AccentColor(
    id: 'rose',
    label: 'Ягаан улаан',
    color: Color(0xFFF43F5E),
    light: Color(0xFFFB7185),
    gradient: [Color(0xFFBE123C), Color(0xFFF43F5E)],
  ),
  AccentColor(
    id: 'amber',
    label: 'Шар',
    color: Color(0xFFF59E0B),
    light: Color(0xFFFBBF24),
    gradient: [Color(0xFFB45309), Color(0xFFF59E0B)],
  ),
];

// ═══════════════════════════════════════════════════════════════
// THEME PROVIDER
// ═══════════════════════════════════════════════════════════════
class ThemeProvider extends ChangeNotifier {
  static const _modeKey = 'theme_mode';
  static const _accentKey = 'accent_color';

  ThemeMode _mode = ThemeMode.dark;
  AccentColor _accent = kAccentColors[0];

  ThemeMode get mode => _mode;
  AccentColor get accent => _accent;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString(_modeKey) ?? 'dark';
    final accentId = prefs.getString(_accentKey) ?? 'blue';
    _mode = _modeFromStr(modeStr);
    _accent = kAccentColors.firstWhere(
      (a) => a.id == accentId,
      orElse: () => kAccentColors[0],
    );
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, _modeToStr(mode));
  }

  Future<void> setAccent(AccentColor accent) async {
    _accent = accent;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accentKey, accent.id);
  }

  ThemeMode _modeFromStr(String s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  String _modeToStr(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
      default:
        return 'dark';
    }
  }

  // ── Dark Theme ───────────────────────────────────────────────
  ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF030712),
        colorScheme: ColorScheme.dark(
          primary: _accent.color,
          secondary: _accent.light,
          surface: const Color(0xFF080F1E),
          error: const Color(0xFFEF4444),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF080F1E),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF94A3B8)),
          titleTextStyle: TextStyle(
            color: Color(0xFFF1F5F9),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? _accent.color
                  : const Color(0xFF475569)),
          trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? _accent.color.withOpacity(0.35)
                  : const Color(0xFF1E3A5F)),
        ),
        useMaterial3: true,
      );

  // ── Light Theme ──────────────────────────────────────────────
  ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.light(
          primary: _accent.color,
          secondary: _accent.light,
          surface: Colors.white,
          error: const Color(0xFFEF4444),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.black.withOpacity(0.05),
          iconTheme: IconThemeData(color: _accent.color),
          titleTextStyle: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? _accent.color
                  : const Color(0xFF94A3B8)),
          trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? _accent.color.withOpacity(0.3)
                  : const Color(0xFFE2E8F0)),
        ),
        useMaterial3: true,
      );
}
