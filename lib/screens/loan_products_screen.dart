import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'loan_detail_screen.dart';

class LoanProductsScreen extends StatefulWidget {
  const LoanProductsScreen({super.key});

  @override
  State<LoanProductsScreen> createState() => _LoanProductsScreenState();
}

class _LoanProductsScreenState extends State<LoanProductsScreen> {
  List<LoanProductModel> _products = [];
  bool _loading = true;

  // Supabase хоосон үед харуулах test өгөгдөл
  final List<LoanProductModel> _mockProducts = [
    LoanProductModel(
      id: '1',
      name: 'Personal Loan',
      nameMn: 'Иргэний зээл',
      loanType: 'personal',
      minAmount: 500000,
      maxAmount: 50000000,
      minTermMonths: 6,
      maxTermMonths: 60,
      interestRateMonthly: 1.5,
      processingFeePercent: 1.0,
      minCreditScore: 500,
      features: ['Барьцаагүй', 'Хурдан шийдвэр'],
    ),
    LoanProductModel(
      id: '2',
      name: 'Business Loan',
      nameMn: 'Бизнесийн зээл',
      loanType: 'business',
      minAmount: 1000000,
      maxAmount: 200000000,
      minTermMonths: 12,
      maxTermMonths: 84,
      interestRateMonthly: 1.8,
      processingFeePercent: 1.5,
      minCreditScore: 600,
      features: ['Том дүн', 'Урт хугацаа'],
    ),
    LoanProductModel(
      id: '3',
      name: 'Mortgage Loan',
      nameMn: 'Орон сууцны зээл',
      loanType: 'mortgage',
      minAmount: 5000000,
      maxAmount: 500000000,
      minTermMonths: 12,
      maxTermMonths: 240,
      interestRateMonthly: 0.8,
      processingFeePercent: 0.5,
      minCreditScore: 650,
      features: ['Бага хүү', 'Урт хугацаа'],
    ),
    LoanProductModel(
      id: '4',
      name: 'Car Loan',
      nameMn: 'Автомашины зээл',
      loanType: 'auto',
      minAmount: 2000000,
      maxAmount: 100000000,
      minTermMonths: 12,
      maxTermMonths: 60,
      interestRateMonthly: 1.2,
      processingFeePercent: 1.0,
      minCreditScore: 550,
      features: ['Машины барьцаа', 'Хурдан олголт'],
    ),
  ];

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
          _products = products.isNotEmpty ? products : _mockProducts;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _products = _mockProducts;
          _loading = false;
        });
      }
    }
  }

  void _goToDetail(LoanProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoanDetailScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final featured = _products.take(2).toList();
    final others = _products.skip(2).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF12121D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Зээлийн бүтээгдэхүүн',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF8A2BE2)))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      'Онцлох зээлүүд',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                  SizedBox(
                    height: 230,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: featured.length,
                      itemBuilder: (_, i) {
                        final p = featured[i];
                        final gradients = [
                          const LinearGradient(
                            colors: [Color(0xFF8A2BE2), Color(0xFF4A00E0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          const LinearGradient(
                            colors: [Color(0xFFB026FF), Color(0xFF512DA8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ];
                        return _buildPromoCard(
                          context,
                          product: p,
                          gradient: gradients[i % gradients.length],
                          onTap: () => _goToDetail(p),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Бусад бүтээгдэхүүн',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ...others.map((p) => _buildListItem(
                        context,
                        product: p,
                        onTap: () => _goToDetail(p),
                      )),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildPromoCard(
    BuildContext context, {
    required LoanProductModel product,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 320,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    product.nameMn,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Icon(Icons.account_balance_wallet, color: Colors.white70),
              ],
            ),
            const Spacer(),
            Text(
              product.monthlyRate,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 5),
            Text(
              AppUtils.formatCurrencyShort(product.maxAmount),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Дэлгэрэнгүй харах',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context, {
    required LoanProductModel product,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A3D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppUtils.getLoanTypeIcon(product.loanType),
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.nameMn,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Дээд хэмжээ: ${AppUtils.formatCurrencyShort(product.maxAmount)}',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Хүү',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      product.monthlyRate,
                      style: const TextStyle(
                          color: Colors.purpleAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Дэлгэрэнгүй →',
                      style: TextStyle(color: Color(0xFF8A2BE2), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
