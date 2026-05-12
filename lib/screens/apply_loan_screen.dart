import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import '../widgets/common_widgets.dart';

// ЗЭЭЛИЙН БҮТЭЭГДЭХҮҮН ДЭЛГЭЦ
class LoanProductsScreen extends StatefulWidget {
  const LoanProductsScreen({super.key});
  @override
  State<LoanProductsScreen> createState() => _LoanProductsScreenState();
}

class _LoanProductsScreenState extends State<LoanProductsScreen> {
  List<LoanProductModel> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final products = await SupabaseService.getLoanProducts();
      if (mounted) {
        setState(() {
          _products = products;
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
        title: const Text('Зээлийн бүтээгдэхүүн'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryLight),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _products.length,
              itemBuilder: (context, i) {
                final p = _products[i];
                final color = p.colorHex != null
                    ? Color(int.parse(p.colorHex!.replaceFirst('#', '0xFF')))
                    : AppColors.primaryLight;
                return LoanProductCard(
                  emoji: AppUtils.getLoanTypeIcon(p.loanType),
                  name: p.nameMn,
                  interestRate: p.monthlyRate,
                  maxAmount: AppUtils.formatCurrencyShort(p.maxAmount),
                  color: color,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ApplyLoanScreen(
  product: p,
  initialAmount: 0,
),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ЗЭЭЛ АВАХ ДЭЛГЭЦ
class ApplyLoanScreen extends StatefulWidget {
  final LoanProductModel product;
  const ApplyLoanScreen({super.key, required this.product, required double initialAmount});
  @override
  State<ApplyLoanScreen> createState() => _ApplyLoanScreenState();
}

class _ApplyLoanScreenState extends State<ApplyLoanScreen> {
  double _amount = 0;
  int _termMonths = 12;
  double _monthlyPayment = 0;
  bool _loading = false;
  final _purposeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amount = widget.product.minAmount;
    _termMonths = widget.product.minTermMonths;
    _calculate();
  }

  @override
  void dispose() {
    _purposeCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _monthlyPayment = SupabaseService.calculateMonthlyPayment(
        _amount,
        widget.product.interestRateMonthly,
        _termMonths,
      );
    });
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await SupabaseService.submitLoanApplication(
        productId: widget.product.id,
        requestedAmount: _amount,
        requestedTermMonths: _termMonths,
        loanPurpose: _purposeCtrl.text.trim(),
      );
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => _SuccessDialog(amount: _amount),
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(
          context,
          'Хүсэлт илгээхэд алдаа гарлаа',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.product.colorHex != null
        ? Color(int.parse(widget.product.colorHex!.replaceFirst('#', '0xFF')))
        : AppColors.primaryLight;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.product.nameMn),
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
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        AppUtils.getLoanTypeIcon(widget.product.loanType),
                        style: const TextStyle(fontSize: 28),
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
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Сарын хүү: ${widget.product.monthlyRate} | Жилийн хүү: ${widget.product.annualRate}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Amount slider
            Text('Зээлийн дүн', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            _SliderCard(
              label: 'Дүн',
              valueLabel: AppUtils.formatCurrency(_amount),
              valueColor: color,
              value: _amount,
              min: widget.product.minAmount,
              max: widget.product.maxAmount,
              divisions: 100,
              minLabel: AppUtils.formatCurrencyShort(widget.product.minAmount),
              maxLabel: AppUtils.formatCurrencyShort(widget.product.maxAmount),
              activeColor: color,
              onChanged: (v) {
                setState(() => _amount = (v / 100000).round() * 100000.0);
                _calculate();
              },
            ),
            const SizedBox(height: 16),

            // Term slider
            Text('Хугацаа', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            _SliderCard(
              label: 'Хугацаа',
              valueLabel: '$_termMonths сар',
              valueColor: color,
              value: _termMonths.toDouble(),
              min: widget.product.minTermMonths.toDouble(),
              max: widget.product.maxTermMonths.toDouble(),
              divisions:
                  widget.product.maxTermMonths - widget.product.minTermMonths,
              minLabel: '${widget.product.minTermMonths} сар',
              maxLabel: '${widget.product.maxTermMonths} сар',
              activeColor: color,
              onChanged: (v) {
                setState(() => _termMonths = v.round());
                _calculate();
              },
            ),
            const SizedBox(height: 24),

            // Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  InfoRow(
                    label: 'Зээлийн дүн',
                    value: AppUtils.formatCurrency(_amount),
                  ),
                  InfoRow(label: 'Хугацаа', value: '$_termMonths сар'),
                  InfoRow(
                    label: 'Сарын хүү',
                    value: widget.product.monthlyRate,
                  ),
                  InfoRow(
                    label: 'Шимтгэл',
                    value: '${widget.product.processingFeePercent}%',
                  ),
                  InfoRow(
                    label: 'Сарын төлбөр',
                    value: AppUtils.formatCurrency(_monthlyPayment),
                    valueColor: color,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _purposeCtrl,
              label: 'Зээлийн зориулалт',
              hint: 'Жишээ: Орон сууц засварлах...',
              prefixIcon: Icons.note_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Хүсэлт илгээх',
              onPressed: _submit,
              isLoading: _loading,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SliderCard extends StatelessWidget {
  final String label, valueLabel, minLabel, maxLabel;
  final Color valueColor, activeColor;
  final double value, min, max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderCard({
    required this.label,
    required this.valueLabel,
    required this.valueColor,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.minLabel,
    required this.maxLabel,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                valueLabel,
                style: AppTextStyles.heading3.copyWith(color: valueColor),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: activeColor,
              thumbColor: activeColor,
              inactiveTrackColor: activeColor.withOpacity(0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(minLabel, style: AppTextStyles.caption),
              Text(maxLabel, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  final double amount;
  const _SuccessDialog({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text('Хүсэлт амжилттай!', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            Text(
              'Таны ${AppUtils.formatCurrency(amount)} зээлийн хүсэлт хүлээн авлаа. Ажлын 1-3 өдрийн дотор шийдвэрлэгдэнэ.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Нүүр хуудас руу',
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }
}

// ЗЭЭЛИЙН ТООЦООЛУУР
class LoanCalculatorScreen extends StatefulWidget {
  const LoanCalculatorScreen({super.key});
  @override
  State<LoanCalculatorScreen> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  double _amount = 10000000;
  double _rate = 1.8;
  int _term = 24;
  double _monthly = 0;
  double _totalInterest = 0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final monthly = SupabaseService.calculateMonthlyPayment(
      _amount,
      _rate,
      _term,
    );
    setState(() {
      _monthly = monthly;
      _totalInterest = (monthly * _term) - _amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Зээлийн тооцоолуур'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Result card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    'Сарын төлбөр',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppUtils.formatCurrency(_monthly),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ResultItem(
                        label: 'Нийт хүү',
                        value: AppUtils.formatCurrencyShort(_totalInterest),
                      ),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _ResultItem(
                        label: 'Нийт төлбөр',
                        value: AppUtils.formatCurrencyShort(
                          _amount + _totalInterest,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _SliderCard(
              label: 'Зээлийн дүн',
              valueLabel: AppUtils.formatCurrency(_amount),
              valueColor: AppColors.primaryLight,
              value: _amount,
              min: 500000,
              max: 200000000,
              divisions: 1999,
              minLabel: '500мян₮',
              maxLabel: '200сая₮',
              activeColor: AppColors.primaryLight,
              onChanged: (v) {
                setState(() => _amount = (v / 100000).round() * 100000.0);
                _calculate();
              },
            ),
            const SizedBox(height: 12),
            _SliderCard(
              label: 'Сарын хүү',
              valueLabel: '${_rate.toStringAsFixed(1)}%',
              valueColor: AppColors.primaryLight,
              value: _rate,
              min: 0.5,
              max: 5.0,
              divisions: 45,
              minLabel: '0.5%',
              maxLabel: '5.0%',
              activeColor: AppColors.primaryLight,
              onChanged: (v) {
                setState(() => _rate = (v * 10).round() / 10);
                _calculate();
              },
            ),
            const SizedBox(height: 12),
            _SliderCard(
              label: 'Хугацаа',
              valueLabel: '$_term сар',
              valueColor: AppColors.primaryLight,
              value: _term.toDouble(),
              min: 1,
              max: 240,
              divisions: 239,
              minLabel: '1 сар',
              maxLabel: '240 сар',
              activeColor: AppColors.primaryLight,
              onChanged: (v) {
                setState(() => _term = v.round());
                _calculate();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  final String label, value;
  const _ResultItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 12,
              fontFamily: 'Gilroy',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'Gilroy',
            ),
          ),
        ],
      );
}
