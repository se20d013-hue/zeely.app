import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'screens/auth_screens.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await Supabase.initialize(
    url: 'https://msxuvfrttvcjrzwabnyk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1zeHV2ZnJ0dHZjanJ6d2FibnlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMxMTk1NDIsImV4cCI6MjA4ODY5NTU0Mn0.B7T1uNvpfCfG-dpQusBYwqBdNmusKzY7_YOBWZZOjlo',
  );

  runApp(
    // ══ ГООЛ ЗАСВАР: ThemeProvider бүх апп-д хүртээмжтэй болно ══
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const LoanApp(),
    ),
  );
}

class LoanApp extends StatelessWidget {
  const LoanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Зээлийн Аппликейшн',
      debugShowCheckedModeBanner: false,
      theme: tp.lightTheme, // ThemeProvider-с авна
      darkTheme: tp.darkTheme, // ThemeProvider-с авна
      themeMode: tp.mode, // Dark/Light/System
      home: const _SplashWrapper(),
    );
  }
}

class _SplashWrapper extends StatefulWidget {
  const _SplashWrapper();

  @override
  State<_SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<_SplashWrapper> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    final session = Supabase.instance.client.auth.currentSession;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            session != null ? const MainNavigation() : LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.account_balance,
                color: Colors.white,
                size: 46,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Зээлийн Банк',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                fontFamily: 'Gilroy',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Шуурхай. Найдвартай. Ил тод.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 14,
                fontFamily: 'Gilroy',
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
