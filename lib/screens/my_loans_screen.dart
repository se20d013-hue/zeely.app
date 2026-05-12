import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import '../widgets/common_widgets.dart';

// =============================================
// МИНИЙ ЗЭЭЛҮҮД
// =============================================
class MyLoansScreen extends StatefulWidget {
  const MyLoansScreen({super.key});

  @override
  State<MyLoansScreen> createState() => _MyLoansScreenState();
}

class _MyLoansScreenState extends State<MyLoansScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<LoanModel> _loans = [];
  List<LoanApplicationModel> _applications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final loans = await SupabaseService.getMyLoans();
      final apps = await SupabaseService.getMyApplications();
      if (mounted) {
        setState(() {
          _loans = loans;
          _applications = apps;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Миний зээлүүд'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.primaryLight,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(
            fontFamily: 'Gilroy',
            fontWeight: FontWeight.w700,
          ),
          tabs: const [
            Tab(text: 'Идэвхтэй зээл'),
            Tab(text: 'Хүсэлтүүд'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryLight),
            )
          : TabBarView(
              controller: _tabCtrl,
              children: [
                // Active loans
                RefreshIndicator(
                  onRefresh: _load,
                  child: _loans.isEmpty
                      ? const Center(
                          child: Text(
                            'Идэвхтэй зээл байхгүй',
                            style: AppTextStyles.body,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: _loans.length,
                          itemBuilder: (context, i) {
                            final loan = _loans[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: LoanCard(
                                loanNumber: loan.loanNumber,
                                productName: loan.productName ?? 'Зээл',
                                outstanding: loan.totalOutstanding,
                                monthlyPayment: loan.monthlyPayment,
                                nextPaymentDate: loan.nextPaymentDate,
                                status: loan.status,
                                cardColor: loan.isOverdue
                                    ? AppColors.error
                                    : AppColors.primaryLight,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        LoanDetailScreen(loanId: loan.id),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                // Applications
                RefreshIndicator(
                  onRefresh: _load,
                  child: _applications.isEmpty
                      ? const Center(
                          child: Text(
                            'Хүсэлт байхгүй',
                            style: AppTextStyles.body,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: _applications.length,
                          itemBuilder: (context, i) {
                            final app = _applications[i];
                            return _ApplicationCard(application: app);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final LoanApplicationModel application;

  const _ApplicationCard({required this.application});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                application.productName ?? 'Зээлийн хүсэлт',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              StatusBadge(
                status: application.status,
                label: application.statusLabel,
              ),
            ],
          ),
          const SizedBox(height: 12),
          InfoRow(
            label: 'Хүсэлтийн дугаар',
            value: application.applicationNumber,
          ),
          InfoRow(
            label: 'Дүн',
            value: AppUtils.formatCurrency(application.requestedAmount),
          ),
          InfoRow(
            label: 'Хугацаа',
            value: '${application.requestedTermMonths} сар',
          ),
          InfoRow(
            label: 'Огноо',
            value: AppUtils.formatDate(application.createdAt),
            isLast: true,
          ),
          if (application.rejectionReason != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      application.rejectionReason!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================
// ЗЭЭЛИЙН ДЭЛГЭРЭНГҮЙ
// =============================================
class LoanDetailScreen extends StatefulWidget {
  final String loanId;

  const LoanDetailScreen({super.key, required this.loanId});

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  LoanModel? _loan;
  List<ScheduleModel> _schedule = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final loan = await SupabaseService.getLoan(widget.loanId);
      final schedule = await SupabaseService.getLoanSchedule(widget.loanId);
      if (mounted) {
        setState(() {
          _loan = loan;
          _schedule = schedule;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_loan?.productName ?? 'Зээлийн дэлгэрэнгүй'),
        centerTitle: true,
        leading: const BackButton(),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.primaryLight,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(
            fontFamily: 'Gilroy',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Мэдээлэл'),
            Tab(text: 'Хуваарь'),
            Tab(text: 'Түүх'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryLight),
            )
          : _loan == null
              ? const Center(child: Text('Зээл олдсонгүй'))
              : TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _LoanInfoTab(
                      loan: _loan!,
                      schedule: _schedule,
                      onPayTap: () => _showPaymentSheet(),
                    ),
                    _ScheduleTab(schedule: _schedule),
                    _HistoryTab(loanId: widget.loanId),
                  ],
                ),
    );
  }

  void _showPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PaymentSheet(loan: _loan!, onPaid: _load),
    );
  }
}

class _LoanInfoTab extends StatelessWidget {
  final LoanModel loan;
  final List<ScheduleModel> schedule;
  final VoidCallback onPayTap;

  const _LoanInfoTab({
    required this.loan,
    required this.schedule,
    required this.onPayTap,
  });

  @override
  Widget build(BuildContext context) {
    final nextInstallment = schedule.where((s) => !s.isPaid).isNotEmpty
        ? schedule.firstWhere((s) => !s.isPaid)
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Progress
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Үлдэгдэл',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppUtils.formatCurrency(loan.totalOutstanding),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                      ],
                    ),
                    StatusBadge(status: loan.status, label: loan.statusLabel),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: loan.progressPercent,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(loan.progressPercent * 100).toStringAsFixed(0)}% төлсөн',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                    Text(
                      'Дуусах: ${AppUtils.formatDate(loan.maturityDate)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Next payment warning
          if (nextInstallment != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: loan.isOverdue
                    ? AppColors.error.withOpacity(0.08)
                    : AppColors.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (loan.isOverdue ? AppColors.error : AppColors.warning)
                      .withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    loan.isOverdue
                        ? Icons.warning_rounded
                        : Icons.calendar_today_rounded,
                    color: loan.isOverdue ? AppColors.error : AppColors.warning,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loan.isOverdue
                              ? 'Хугацаа хэтэрсэн!'
                              : 'Дараагийн төлбөр',
                          style: TextStyle(
                            color: loan.isOverdue
                                ? AppColors.error
                                : AppColors.warning,
                            fontFamily: 'Gilroy',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${AppUtils.formatCurrency(nextInstallment.totalAmount)} | ${AppUtils.formatDate(nextInstallment.dueDate)}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onPayTap,
                    style: TextButton.styleFrom(
                      backgroundColor:
                          (loan.isOverdue ? AppColors.error : AppColors.warning)
                              .withOpacity(0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Төлөх',
                      style: TextStyle(
                        color: loan.isOverdue
                            ? AppColors.error
                            : AppColors.warning,
                        fontFamily: 'Gilroy',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Loan details
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                InfoRow(label: 'Зээлийн дугаар', value: loan.loanNumber),
                InfoRow(
                  label: 'Зээлийн дүн',
                  value: AppUtils.formatCurrency(loan.principalAmount),
                ),
                InfoRow(
                  label: 'Сарын хүү',
                  value: '${loan.interestRateMonthly}%',
                ),
                InfoRow(label: 'Хугацаа', value: '${loan.termMonths} сар'),
                InfoRow(
                  label: 'Сарын төлбөр',
                  value: AppUtils.formatCurrency(loan.monthlyPayment),
                ),
                InfoRow(
                  label: 'Нийт төлсөн',
                  value: AppUtils.formatCurrency(loan.totalPaid),
                  valueColor: AppColors.success,
                ),
                if (loan.penaltyAmount > 0)
                  InfoRow(
                    label: 'Алданги',
                    value: AppUtils.formatCurrency(loan.penaltyAmount),
                    valueColor: AppColors.error,
                  ),
                InfoRow(
                  label: 'Олгосон огноо',
                  value: loan.disbursedAt != null
                      ? AppUtils.formatDate(loan.disbursedAt!)
                      : '—',
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          AppButton(
            label: 'Төлбөр хийх',
            onPressed: onPayTap,
            icon: Icons.payment_rounded,
          ),
        ],
      ),
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  final List<ScheduleModel> schedule;

  const _ScheduleTab({required this.schedule});

  @override
  Widget build(BuildContext context) {
    if (schedule.isEmpty) {
      return const Center(
        child: Text('Хуваарь байхгүй', style: AppTextStyles.body),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: schedule.length,
      itemBuilder: (context, i) {
        final item = schedule[i];
        final isOverdue = item.isOverdue;
        final isPaid = item.isPaid;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isPaid
                ? AppColors.success.withOpacity(0.06)
                : isOverdue
                    ? AppColors.error.withOpacity(0.06)
                    : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPaid
                  ? AppColors.success.withOpacity(0.3)
                  : isOverdue
                      ? AppColors.error.withOpacity(0.3)
                      : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (isPaid
                          ? AppColors.success
                          : isOverdue
                              ? AppColors.error
                              : AppColors.primaryLight)
                      .withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isPaid
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.success,
                          size: 20,
                        )
                      : isOverdue
                          ? const Icon(
                              Icons.close_rounded,
                              color: AppColors.error,
                              size: 20,
                            )
                          : Text(
                              '${item.installmentNumber}',
                              style: const TextStyle(
                                fontFamily: 'Gilroy',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.primaryLight,
                              ),
                            ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.installmentNumber}-р төлбөр',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      AppUtils.formatDate(item.dueDate),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppUtils.formatCurrency(item.totalAmount),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Үндсэн: ${AppUtils.formatCurrencyShort(item.principalAmount)}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HistoryTab extends StatefulWidget {
  final String loanId;

  const _HistoryTab({required this.loanId});

  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final h = await SupabaseService.getPaymentHistory(widget.loanId);
      if (mounted) {
        setState(() {
          _history = h;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryLight),
      );
    }
    if (_history.isEmpty) {
      return const Center(
        child: Text('Төлбөрийн түүх байхгүй', style: AppTextStyles.body),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _history.length,
      itemBuilder: (context, i) {
        final tx = _history[i];
        final amount = (tx['payment_amount'] ?? 0).toDouble();
        final date = DateTime.parse(tx['paid_at']);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payment_rounded,
                  color: AppColors.success,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx['transaction_number'] ?? '—',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      AppUtils.formatDateTime(date),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Text(
                AppUtils.formatCurrency(amount),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================
// ТӨЛБӨР ХИЙХ BOTTOM SHEET
// =============================================
class _PaymentSheet extends StatefulWidget {
  final LoanModel loan;
  final VoidCallback onPaid;

  const _PaymentSheet({required this.loan, required this.onPaid});

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  String _method = 'mobile_banking';
  bool _loading = false;
  late double _amount;
  final _amountCtrl = TextEditingController();

  final _methods = [
    {
      'id': 'mobile_banking',
      'label': 'Мобайл банк',
      'icon': Icons.phone_android_rounded,
    },
    {
      'id': 'bank_transfer',
      'label': 'Шилжүүлэг',
      'icon': Icons.account_balance_rounded,
    },
    {'id': 'card', 'label': 'Карт', 'icon': Icons.credit_card_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _amount = widget.loan.monthlyPayment;
    _amountCtrl.text = _amount.toStringAsFixed(0);
  }

  Future<void> _pay() async {
    setState(() => _loading = true);
    try {
      await SupabaseService.makePayment(
        loanId: widget.loan.id,
        amount: _amount,
        paymentMethod: _method,
      );
      widget.onPaid();
      if (mounted) {
        Navigator.pop(context);
        AppSnackbar.show(context, 'Төлбөр амжилттай хийгдлээ!');
      }
    } catch (_) {
      if (mounted) {
        AppSnackbar.show(context, 'Төлбөр хийхэд алдаа гарлаа', isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Зээл төлөх', style: AppTextStyles.heading3),
          const SizedBox(height: 20),

          // Amount
          TextFormField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            style: AppTextStyles.heading3,
            decoration: InputDecoration(
              labelText: 'Дүн (₮)',
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
            onChanged: (v) =>
                _amount = double.tryParse(v) ?? widget.loan.monthlyPayment,
          ),
          const SizedBox(height: 8),
          Text(
            'Сарын төлбөр: ${AppUtils.formatCurrency(widget.loan.monthlyPayment)}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 20),

          // Payment method
          Text(
            'Төлбөрийн арга',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _methods
                .map(
                  (m) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _method = m['id'] as String),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _method == m['id']
                                ? AppColors.primaryLight.withOpacity(0.1)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _method == m['id']
                                  ? AppColors.primaryLight
                                  : AppColors.border,
                              width: _method == m['id'] ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                m['icon'] as IconData,
                                color: _method == m['id']
                                    ? AppColors.primaryLight
                                    : AppColors.textSecondary,
                                size: 22,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                m['label'] as String,
                                style: TextStyle(
                                  fontFamily: 'Gilroy',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _method == m['id']
                                      ? AppColors.primaryLight
                                      : AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _pay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Төлбөр баталгаажуулах',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Gilroy',
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
