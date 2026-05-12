import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../models/models.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../utils/utils.dart';
import 'apply_loan_screen.dart';

class LoanEligibilityScreen extends StatefulWidget {
  final LoanProductModel product;
  const LoanEligibilityScreen({super.key, required this.product});

  @override
  State<LoanEligibilityScreen> createState() => _LoanEligibilityScreenState();
}

class _LoanEligibilityScreenState extends State<LoanEligibilityScreen>
    with SingleTickerProviderStateMixin {
  final _salaryCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _checked = false;
  bool _loading = false;
  double _eligibleAmount = 0;
  double _monthlyPayment = 0;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const int _defaultTerm = 12;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _salaryCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Color get _productColor {
    if (widget.product.colorHex != null) {
      return Color(
          int.parse(widget.product.colorHex!.replaceFirst('#', '0xFF')));
    }
    return AppColors.primaryLight;
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final salary = double.tryParse(_salaryCtrl.text.replaceAll(',', '')) ?? 0;
    final r = widget.product.interestRateMonthly / 100;
    const n = _defaultTerm;

    double maxByIncome;
    if (r == 0) {
      maxByIncome = salary * 0.4 * n;
    } else {
      maxByIncome = salary * 0.4 * (pow(1 + r, n) - 1) / (r * pow(1 + r, n));
    }

    final amount = min(maxByIncome, widget.product.maxAmount);
    final payment = SupabaseService.calculateMonthlyPayment(
      amount,
      widget.product.interestRateMonthly,
      _defaultTerm,
    );

    setState(() {
      _eligibleAmount = amount;
      _monthlyPayment = payment;
      _checked = true;
      _loading = false;
    });

    _animCtrl.forward(from: 0);
  }

  void _goToApply() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ApplyLoanScreen(
          product: widget.product,
          initialAmount: _eligibleAmount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _productColor;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Зээл судлах'),
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        AppUtils.getLoanTypeIcon(widget.product.loanType),
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.nameMn,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Сарын хүү: ${widget.product.monthlyRate} | '
                          'Дээд: ${AppUtils.formatCurrencyShort(widget.product.maxAmount)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Salary input
            Text(
              'Сарын цалин орлого',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 6),
            Text(
              'Таны орлогод үндэслэн зээлийн боломжит хэмжээг тооцоолно.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 14),

            Form(
              key: _formKey,
              child: TextFormField(
                controller: _salaryCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '1,500,000',
                  suffixText: '₮',
                  suffixStyle: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: color, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Цалин оруулна уу';
                  final n = double.tryParse(v);
                  if (n == null || n < 100000) {
                    return 'Хамгийн багадаа 100,000 ₮ байх ёстой';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),

            // Calculate button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _loading ? null : _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Зээлийн боломж судлах',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Gilroy',
                        ),
                      ),
              ),
            ),

            // Result section
            if (_checked) ...[
              const SizedBox(height: 32),
              FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Eligible amount highlight card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withOpacity(0.12),
                              color.withOpacity(0.04)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _eligibleAmount > 0
                                  ? Icons.check_circle_rounded
                                  : Icons.info_rounded,
                              color: _eligibleAmount > 0
                                  ? AppColors.success
                                  : Colors.orange,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Та дараах хэмжээний зээл авах боломжтой',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppUtils.formatCurrency(_eligibleAmount),
                              style: TextStyle(
                                color: color,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Gilroy',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_defaultTerm} сарын хугацаатай, '
                              'сарын ${AppUtils.formatCurrency(_monthlyPayment)} төлбөртэй',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Summary rows
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            _SummaryRow(
                              label: 'Орлогын 40% хязгаар',
                              value: AppUtils.formatCurrency(
                                  double.parse(_salaryCtrl.text) * 0.4),
                            ),
                            const Divider(height: 20),
                            _SummaryRow(
                              label: 'Сарын төлбөр',
                              value: AppUtils.formatCurrency(_monthlyPayment),
                              valueColor: color,
                            ),
                            const Divider(height: 20),
                            _SummaryRow(
                              label: 'Сарын хүү',
                              value: widget.product.monthlyRate,
                            ),
                            const Divider(height: 20),
                            _SummaryRow(
                              label: 'Хугацаа',
                              value: '$_defaultTerm сар',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Apply button
                      if (_eligibleAmount > 0)
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _goToApply,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Зээлийн хүсэлт гаргах',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Gilroy',
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded,
                                    color: Colors.white, size: 20),
                              ],
                            ),
                          ),
                        ),

                      if (_eligibleAmount <= 0)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: Colors.orange, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Одоогийн орлогоор энэ бүтээгдэхүүний '
                                  'зээл авах боломжгүй байна.',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.orange,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _SummaryRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
