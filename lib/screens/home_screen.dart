import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import '../widgets/common_widgets.dart';
import 'loan_products_screen.dart';
import 'my_loans_screen.dart';
import 'profile_screen.dart' hide NotificationsScreen;
import 'notifications_screen.dart';
import 'loan_calculator_screen.dart';

class DarkColors {
  static const bg = Color(0xFF0D0B1E);
  static const surface = Color(0xFF1A1730);
  static const card = Color(0xFF221E3A);
  static const purple1 = Color(0xFF7C3AED);
  static const purple2 = Color(0xFF9F67F8);
  static const purple3 = Color(0xFFBB8FFE);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9B8EC4);
  static const green = Color(0xFF4ADE80);
  static const red = Color(0xFFFF5B5B);
  static const border = Color(0xFF2E2850);
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    return const _HomeTab();
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  ProfileModel? _profile;
  List<LoanModel> _activeLoans = [];
  bool _loading = true;
  bool _balanceVisible = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profile = await SupabaseService.getProfile();
      final loans = await SupabaseService.getMyLoans();
      if (mounted) {
        setState(() {
          _profile = profile;
          _activeLoans = loans.where((l) => l.isActive || l.isOverdue).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _totalBalance =>
      _activeLoans.fold(0.0, (s, l) => s + l.totalOutstanding);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkColors.bg,
      body: RefreshIndicator(
        color: DarkColors.purple2,
        backgroundColor: DarkColors.surface,
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: _buildBalanceCard(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: _buildQuickActions(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Миний зээлүүд',
                      style: TextStyle(
                        color: DarkColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MyLoansScreen()),
                      ),
                      child: const Text(
                        'Бүгдийг харах',
                        style: TextStyle(
                            color: DarkColors.purple2, fontFamily: 'Gilroy'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_loading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _shimmer(height: 160),
                      const SizedBox(height: 12),
                      _shimmer(height: 160),
                    ],
                  ),
                ),
              )
            else if (_activeLoans.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: DarkColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: DarkColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.credit_card_off_outlined,
                          size: 52, color: DarkColors.textSecondary),
                      const SizedBox(height: 14),
                      const Text(
                        'Идэвхтэй зээл байхгүй',
                        style: TextStyle(
                          color: DarkColors.textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Gilroy',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Шинэ зээл авахын тулд доорх товчийг дарна уу',
                        style: TextStyle(
                          color: DarkColors.textSecondary,
                          fontSize: 13,
                          fontFamily: 'Gilroy',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      _PurpleButton(
                        label: '+ Зээл авах',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => LoanProductsScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final loan = _activeLoans[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: _DarkLoanCard(
                        loan: loan,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoanProductsScreen(),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: _activeLoans.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        20,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Сайн уу! 👋',
                  style: TextStyle(
                    color: DarkColors.textSecondary,
                    fontSize: 14,
                    fontFamily: 'Gilroy',
                  ),
                ),
                const SizedBox(height: 4),
                _loading
                    ? _shimmer(height: 24, width: 140)
                    : Text(
                        _profile != null
                            ? '${_profile!.lastName} ${_profile!.firstName}'
                            : 'Хэрэглэгч',
                        style: const TextStyle(
                          color: DarkColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Gilroy',
                        ),
                      ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: DarkColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: DarkColors.border),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: DarkColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B21B6), Color(0xFF7C3AED), Color(0xFF9F67F8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: DarkColors.purple1.withOpacity(0.45),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Нийт зээлийн үлдэгдэл',
                style: TextStyle(
                    color: Colors.white70, fontSize: 13, fontFamily: 'Gilroy'),
              ),
              GestureDetector(
                onTap: () => setState(() => _balanceVisible = !_balanceVisible),
                child: Icon(
                  _balanceVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white70,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _loading
              ? _shimmer(height: 36, width: 180, light: true)
              : Text(
                  _balanceVisible
                      ? AppUtils.formatCurrency(_totalBalance)
                      : '••••••••',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Gilroy',
                  ),
                ),
          const SizedBox(height: 20),
          Row(
            children: [
              _CardStat(
                icon: Icons.credit_card_rounded,
                label: 'Нийт зээл',
                value: '${_activeLoans.length}',
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              _CardStat(
                icon: Icons.shield_outlined,
                label: 'Зээлийн оноо',
                value: '${_profile?.creditScore ?? 0}/850',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      (
        Icons.add_card_rounded,
        'Зээл авах',
        const Color(0xFF7C3AED),
        () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => LoanProductsScreen()))
      ),
      (
        Icons.payment_rounded,
        'Төлбөр',
        const Color(0xFF0EA5E9),
        () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const MyLoansScreen()))
      ),
      (
        Icons.calculate_outlined,
        'Тооцоолуур',
        const Color(0xFF10B981),
        () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const LoanCalculatorScreen()))
      ),
      (Icons.history_rounded, 'Түүх', const Color(0xFFF59E0B), () {}),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) {
        return GestureDetector(
          onTap: a.$4,
          child: Column(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: a.$3.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: a.$3.withOpacity(0.3)),
                ),
                child: Icon(a.$1, color: a.$3, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                a.$2,
                style: const TextStyle(
                  color: DarkColors.textSecondary,
                  fontSize: 11,
                  fontFamily: 'Gilroy',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _shimmer({double height = 20, double? width, bool light = false}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: light ? Colors.white.withOpacity(0.2) : DarkColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _DarkLoanCard extends StatelessWidget {
  final LoanModel loan;
  final VoidCallback onTap;
  const _DarkLoanCard({required this.loan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final progress = loan.totalOutstanding > 0
        ? (loan.monthlyPayment / loan.totalOutstanding).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: DarkColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: DarkColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [DarkColors.purple1, DarkColors.purple2],
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.credit_card_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan.productName ?? 'Зээл',
                        style: const TextStyle(
                          color: DarkColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Gilroy',
                        ),
                      ),
                      Text(
                        loan.loanNumber,
                        style: const TextStyle(
                          color: DarkColors.textSecondary,
                          fontSize: 12,
                          fontFamily: 'Gilroy',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: loan.isOverdue
                        ? DarkColors.red.withOpacity(0.15)
                        : DarkColors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    loan.isOverdue ? 'Хугацаа хэтэрсэн' : 'Идэвхтэй',
                    style: TextStyle(
                      color: loan.isOverdue ? DarkColors.red : DarkColors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Stat(
                    label: 'Зээлийн дүн',
                    value: AppUtils.formatCurrencyShort(loan.totalOutstanding)),
                _Stat(
                  label: 'Үлдэгдэл',
                  value: AppUtils.formatCurrencyShort(loan.totalOutstanding),
                  valueColor: DarkColors.purple3,
                ),
                _Stat(
                    label: 'Сарын төлбөр',
                    value: AppUtils.formatCurrencyShort(loan.monthlyPayment)),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (1.0 - progress).clamp(0.0, 1.0),
                backgroundColor: DarkColors.border,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(DarkColors.purple2),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${((1.0 - progress) * 100).toStringAsFixed(0)}% төлөгдсөн',
              style: const TextStyle(
                color: DarkColors.textSecondary,
                fontSize: 11,
                fontFamily: 'Gilroy',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _Stat({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: DarkColors.textSecondary,
                  fontSize: 11,
                  fontFamily: 'Gilroy')),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                color: valueColor ?? DarkColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'Gilroy',
              )),
        ],
      );
}

class _CardStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _CardStat(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: Colors.white60, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      fontFamily: 'Gilroy')),
              Text(value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Gilroy',
                  )),
            ],
          ),
        ],
      );
}

class _PurpleButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _PurpleButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [DarkColors.purple1, DarkColors.purple2]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontFamily: 'Gilroy'),
          ),
        ),
      );
}
