import 'package:flutter/material.dart';
import 'dart:math';

class LoanCalculatorScreen extends StatefulWidget {
  const LoanCalculatorScreen({super.key});

  @override
  State<LoanCalculatorScreen> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  final List<Map<String, dynamic>> _loanTypes = [
    {'name': 'Хэрэглээний зээл', 'rate': 1.8, 'max': 0.0, 'icon': '🛍️'},
    {'name': 'Орон сууцны зээл', 'rate': 1.0, 'max': 500.0, 'icon': '🏠'},
    {'name': 'Яаралтай зээл', 'rate': 2.5, 'max': 5.0, 'icon': '⚡'},
    {'name': 'Боловсролын зээл', 'rate': 0.8, 'max': 20.0, 'icon': '📚'},
    {'name': 'Бизнесийн зээл', 'rate': 1.6, 'max': 500.0, 'icon': '💼'},
    {'name': 'Автомашины зээл', 'rate': 1.5, 'max': 200.0, 'icon': '🚗'},
  ];

  int _selectedIndex = 0;
  double _salary = 1500000;
  double _termMonths = 24;

  double get _monthlyRate => _loanTypes[_selectedIndex]['rate'] / 100;
  double get _maxCap => (_loanTypes[_selectedIndex]['max'] as double) * 1000000;

  double get _loanByIncome {
    final r = _monthlyRate;
    final n = _termMonths;
    if (r == 0) return _salary * 0.4 * n;
    return _salary * 0.4 * (pow(1 + r, n) - 1) / (r * pow(1 + r, n));
  }

  double get _loanAmount => min(_loanByIncome, _maxCap);

  double get _monthlyPayment {
    final r = _monthlyRate;
    final n = _termMonths;
    if (r == 0 || n == 0) return 0;
    return _loanAmount * r * pow(1 + r, n) / (pow(1 + r, n) - 1);
  }

  double get _totalInterest => (_monthlyPayment * _termMonths) - _loanAmount;
  double get _dtiRatio => _salary > 0 ? _monthlyPayment / _salary : 0;

  String _fmt(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}саяR₮'
          .replaceAll('R', '');
    }
    final s = amount.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '${buf.toString()} ₮';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12121D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Зээлийн тооцоолуур',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Зээлийн төрөл'),
            const SizedBox(height: 12),
            _buildLoanTypeGrid(),
            const SizedBox(height: 24),
            _sectionLabel('Тооцоолох мэдээлэл'),
            const SizedBox(height: 16),
            _buildSliderCard(
              label: 'Сарын цалин орлого',
              displayValue: _fmt(_salary),
              value: _salary,
              min: 500000,
              max: 10000000,
              onChanged: (v) =>
                  setState(() => _salary = (v / 100000).round() * 100000.0),
            ),
            const SizedBox(height: 12),
            _buildSliderCard(
              label: 'Зээлийн хугацаа',
              displayValue: '${_termMonths.toInt()} сар',
              value: _termMonths,
              min: 3,
              max: 360,
              onChanged: (v) =>
                  setState(() => _termMonths = (v / 3).round() * 3.0),
            ),
            const SizedBox(height: 24),
            _sectionLabel('Тооцооллын дүн'),
            const SizedBox(height: 12),
            _buildResultGrid(),
            const SizedBox(height: 16),
            _buildDtiBar(),
            const SizedBox(height: 16),
            _buildInfoNote(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      );

  Widget _buildLoanTypeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: _loanTypes.length,
      itemBuilder: (_, i) {
        final selected = i == _selectedIndex;
        return GestureDetector(
          onTap: () => setState(() => _selectedIndex = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                      colors: [Color(0xFF8A2BE2), Color(0xFF4A00E0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: selected ? null : const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(14),
              border:
                  selected ? null : Border.all(color: const Color(0xFF2A2A3D)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _loanTypes[i]['icon'] as String,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  (_loanTypes[i]['name'] as String).split(' ').first,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliderCard({
    required String label,
    required String displayValue,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Text(
                displayValue,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              activeTrackColor: const Color(0xFF8A2BE2),
              inactiveTrackColor: const Color(0xFF2A2A3D),
              thumbColor: const Color(0xFF8A2BE2),
              overlayColor: const Color(0xFF8A2BE2).withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultGrid() {
    final items = [
      {
        'label': 'Зээлийн дээд хэмжээ',
        'value': _fmt(_loanAmount),
        'highlight': true,
      },
      {
        'label': 'Сарын төлбөр',
        'value': _fmt(_monthlyPayment),
        'highlight': false,
      },
      {
        'label': 'Нийт хүүгийн зардал',
        'value': _fmt(_totalInterest),
        'highlight': false,
      },
      {
        'label': 'Сарын хүү',
        'value': '${_loanTypes[_selectedIndex]['rate']}%',
        'highlight': false,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.8,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final highlight = item['highlight'] as bool;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item['label'] as String,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
              const SizedBox(height: 6),
              Text(
                item['value'] as String,
                style: TextStyle(
                  color: highlight ? Colors.purpleAccent : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDtiBar() {
    final pct = (_dtiRatio * 100).clamp(0.0, 100.0);
    final over = _dtiRatio > 0.4;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Орлогын ачаалал (40% хязгаар)',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                '${pct.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: over ? Colors.redAccent : Colors.purpleAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 8,
              backgroundColor: const Color(0xFF2A2A3D),
              valueColor: AlwaysStoppedAnimation<Color>(
                over ? Colors.redAccent : const Color(0xFF8A2BE2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoNote() {
    final cappedByProduct = _loanByIncome > _maxCap;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A3D)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.grey, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              cappedByProduct
                  ? 'Зээлийн дээд хэмжээ бүтээгдэхүүний хязгаараар (${_loanTypes[_selectedIndex]['max']}саяR₮) хязгаарлагдаж байна.'
                      .replaceAll('R', '')
                  : 'Орлогын 40% хүртэл зарцуулалтыг банкууд зөвшөөрдөг стандарт юм. Бодит зээлийн шийдвэр нь зээлийн түүх болон бусад нөхцлөөс хамаарна.',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
