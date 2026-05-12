import 'package:supabase_flutter/supabase_flutter.dart';
import '../bank_system/models/models.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  static SupabaseClient get client => _client;
  static User? get currentUser => _client.auth.currentUser;
  static String? get currentUserId => _client.auth.currentUser?.id;

  // =============================================
  // AUTH
  // =============================================

  static Future<AuthResponse> signIn({
    required String phone,
    required String password,
  }) async {
    // Phone-г email format болгон хөрвүүлэх
    final email = '${phone.replaceAll('+976', '')}@loanapp.mn';
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<AuthResponse> signUp({
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
    required String registerNumber,
  }) async {
    final email = '${phone.replaceAll('+976', '')}@loanapp.mn';
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'phone': phone,
        'first_name': firstName,
        'last_name': lastName,
        'register_number': registerNumber,
      },
    );
    if (response.user != null) {
      await _client.from('profiles').insert({
        'id': response.user!.id,
        'phone': phone,
        'first_name': firstName,
        'last_name': lastName,
        'register_number': registerNumber,
      });
    }
    return response;
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // =============================================
  // PROFILE
  // =============================================

  static Future<ProfileModel?> getProfile() async {
    if (currentUserId == null) return null;
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', currentUserId!)
        .single();
    return ProfileModel.fromJson(data);
  }

  static Future<void> updateProfile(Map<String, dynamic> updates) async {
    await _client
        .from('profiles')
        .update({...updates, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', currentUserId!);
  }

  // =============================================
  // ЗЭЭЛИЙН БҮТЭЭГДЭХҮҮН
  // =============================================

  static Future<List<LoanProductModel>> getLoanProducts() async {
    final data = await _client
        .from('loan_products')
        .select()
        .eq('is_active', true)
        .order('loan_type');
    return data.map<LoanProductModel>((json) => LoanProductModel.fromJson(json)).toList();
  }

  static Future<LoanProductModel?> getLoanProduct(String productId) async {
    final data = await _client
        .from('loan_products')
        .select()
        .eq('id', productId)
        .single();
    return LoanProductModel.fromJson(data);
  }

  // =============================================
  // ЗЭЭЛИЙН ХҮСЭЛТ
  // =============================================

  static Future<LoanApplicationModel> submitLoanApplication({
    required String productId,
    required double requestedAmount,
    required int requestedTermMonths,
    String? loanPurpose,
    List<Map<String, String>>? documents,
  }) async {
    final appNumber = await _client.rpc('generate_application_number');
    final data = await _client.from('loan_applications').insert({
      'application_number': appNumber,
      'user_id': currentUserId!,
      'product_id': productId,
      'requested_amount': requestedAmount,
      'requested_term_months': requestedTermMonths,
      'loan_purpose': loanPurpose,
      'documents': documents ?? [],
    }).select('*, loan_products(name_mn)').single();
    return LoanApplicationModel.fromJson(data);
  }

  static Future<List<LoanApplicationModel>> getMyApplications() async {
    final data = await _client
        .from('loan_applications')
        .select('*, loan_products(name_mn)')
        .eq('user_id', currentUserId!)
        .order('created_at', ascending: false);
    return data.map<LoanApplicationModel>((json) => LoanApplicationModel.fromJson(json)).toList();
  }

  // =============================================
  // ИДЭВХТЭЙ ЗЭЭЛ
  // =============================================

  static Future<List<LoanModel>> getMyLoans() async {
    final data = await _client
        .from('loans')
        .select('*, loan_products(name_mn)')
        .eq('user_id', currentUserId!)
        .order('created_at', ascending: false);
    return data.map<LoanModel>((json) => LoanModel.fromJson(json)).toList();
  }

  static Future<LoanModel?> getLoan(String loanId) async {
    final data = await _client
        .from('loans')
        .select('*, loan_products(name_mn)')
        .eq('id', loanId)
        .single();
    return LoanModel.fromJson(data);
  }

  static Future<List<ScheduleModel>> getLoanSchedule(String loanId) async {
    final data = await _client
        .from('loan_schedules')
        .select()
        .eq('loan_id', loanId)
        .order('installment_number');
    return data.map<ScheduleModel>((json) => ScheduleModel.fromJson(json)).toList();
  }

  // =============================================
  // ТӨЛБӨР
  // =============================================

  static Future<void> makePayment({
    required String loanId,
    required double amount,
    required String paymentMethod,
    String? scheduleId,
  }) async {
    final txNumber = 'TXN${DateTime.now().millisecondsSinceEpoch}';
    await _client.from('payment_transactions').insert({
      'transaction_number': txNumber,
      'loan_id': loanId,
      'user_id': currentUserId!,
      'schedule_id': scheduleId,
      'payment_amount': amount,
      'payment_method': paymentMethod,
      'status': 'completed',
    });
  }

  static Future<List<Map<String, dynamic>>> getPaymentHistory(String loanId) async {
    return await _client
        .from('payment_transactions')
        .select()
        .eq('loan_id', loanId)
        .order('paid_at', ascending: false);
  }

  // =============================================
  // МЭДЭГДЭЛ
  // =============================================

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    return await _client
        .from('notifications')
        .select()
        .eq('user_id', currentUserId!)
        .order('created_at', ascending: false)
        .limit(50);
  }

  static Future<void> markNotificationRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  // =============================================
  // ТООЦООЛОЛ
  // =============================================

  static double calculateMonthlyPayment(double principal, double monthlyRate, int months) {
    if (monthlyRate == 0) return principal / months;
    final rate = monthlyRate / 100;
    return principal * (rate * (1 + rate).pow(months)) / ((1 + rate).pow(months) - 1);
  }

  static List<Map<String, double>> calculateSchedule(
    double principal,
    double monthlyRate,
    int months,
  ) {
    final rate = monthlyRate / 100;
    final monthlyPayment = calculateMonthlyPayment(principal, monthlyRate, months);
    double remaining = principal;
    List<Map<String, double>> schedule = [];

    for (int i = 1; i <= months; i++) {
      final interest = remaining * rate;
      final principalPay = monthlyPayment - interest;
      schedule.add({
        'month': i.toDouble(),
        'principal': principalPay,
        'interest': interest,
        'total': monthlyPayment,
        'remaining': remaining - principalPay,
      });
      remaining -= principalPay;
    }
    return schedule;
  }
}

extension DoubleExt on double {
  double pow(int exponent) {
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= this;
    }
    return result;
  }
}