import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'apply_loan_screen.dart';

class LoanDetailScreen extends StatelessWidget {
  final LoanProductModel product;

  const LoanDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12121D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(product.nameMn,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Зээлийн дэлгэрэнгүй карт
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8A2BE2), Color(0xFF4A00E0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8A2BE2).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppUtils.getLoanTypeIcon(product.loanType),
                        style: const TextStyle(fontSize: 36),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Идэвхтэй',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(product.nameMn,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statCard('Сарын хүү', product.monthlyRate),
                      _statCard('Дээд хэмжээ',
                          AppUtils.formatCurrencyShort(product.maxAmount)),
                      _statCard('Хугацаа', '${product.maxTermMonths} сар'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Зээл олгогч байгууллагууд
            const Text('Зээл олгогч байгууллагууд',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            _companyCard(
              name: 'Хаан Банк',
              phone: '1800-1234',
              address: 'Улаанбаатар, Сүхбаатар дүүрэг',
            ),
            const SizedBox(height: 10),
            _companyCard(
              name: 'Голомт Банк',
              phone: '7000-1111',
              address: 'Улаанбаатар, Баянзүрх дүүрэг',
            ),
            const SizedBox(height: 10),
            _companyCard(
              name: 'Төрийн банк',
              phone: '1800-1800',
              address: 'Улаанбаатар, Чингэлтэй дүүрэг',
            ),

            const SizedBox(height: 28),

            // Зээлийн боломжууд
            const Text('Зээлийн боломжууд',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _featureRow(Icons.verified_user_rounded,
                      'Барьцаагүй зээл авах боломжтой', Colors.greenAccent),
                  _featureRow(Icons.phone_android_rounded,
                      'Гар утаснаас өргөдөл гаргах', Colors.blueAccent),
                  _featureRow(Icons.access_time_rounded,
                      '24 цагийн дотор шийдвэрлэнэ', Colors.orangeAccent),
                  _featureRow(Icons.payments_rounded, 'Эрт төлөх боломжтой',
                      Colors.purpleAccent),
                  _featureRow(Icons.support_agent_rounded,
                      '24/7 хэрэглэгчийн үйлчилгээ', Colors.pinkAccent),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Өргөдөл гаргах товч
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ApplyLoanScreen(
                        product: product,
                        initialAmount: 0,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8A2BE2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: const Color(0xFF8A2BE2).withOpacity(0.5),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text('Зээл хүсэлт илгээх',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _companyCard({
    required String name,
    required String phone,
    required String address,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF8A2BE2).withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF8A2BE2).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.account_balance,
                color: Color(0xFF8A2BE2), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.white38, size: 13),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(address,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone, color: Colors.green, size: 14),
                  const SizedBox(width: 5),
                  Text(phone,
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
