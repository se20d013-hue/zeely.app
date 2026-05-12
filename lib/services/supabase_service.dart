import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;
  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;
  static String? get currentUserId => _client.auth.currentUser?.id;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://msxuvfrttvcjrzwabnyk.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1zeHV2ZnJ0dHZjanJ6d2FibnlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMxMTk1NDIsImV4cCI6MjA4ODY5NTU0Mn0.B7T1uNvpfCfG-dpQusBYwqBdNmusKzY7_YOBWZZOjlo',
    );
  }

  // =============================================
  // AUTH
  // =============================================

  // ── И-мэйлээр нэвтрэх ──
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ── Утасны дугаараар нэвтрэх ──
  static Future<AuthResponse> signIn({
    required String phone,
    required String password,
  }) async {
    // FIX: single() → maybeSingle() алдааг засав
    final result = await _client
        .from('profiles')
        .select('email')
        .eq('phone', phone)
        .maybeSingle();

    if (result == null || result['email'] == null) {
      throw Exception('Бүртгэлтэй утасны дугаар олдсонгүй');
    }

    final email = result['email'] as String;
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ── Бүртгүүлэх ──
  static Future<AuthResponse> signUp({
    required String phone,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String registerNumber,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'phone': phone,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'register_number': registerNumber,
      },
    );
    if (response.user != null) {
      // FIX: upsert — давхар insert-ийн алдааг засав
      await _client.from('profiles').upsert({
        'id': response.user!.id,
        'phone': phone,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'register_number': registerNumber,
        'role': 'user',
      });
    }
    return response;
  }

  static Future<void> signOut() async => await _client.auth.signOut();

  // =============================================
  // AVATAR
  // =============================================

  static Future<String> uploadAvatar({
    required Uint8List bytes,
    required String extension,
  }) async {
    if (currentUserId == null) throw Exception('Нэвтрээгүй байна');

    final path = 'avatars/$currentUserId.$extension';

    await _client.storage.from('avatars').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    // FIX: cache busting — зураг шинэчлэгдсэнийг UI мэдэхийн тулд
    final url = '${_client.storage.from('avatars').getPublicUrl(path)}'
        '?t=${DateTime.now().millisecondsSinceEpoch}';

    await _client
        .from('profiles')
        .update({'avatar_url': url}).eq('id', currentUserId!);

    return url;
  }

  // =============================================
  // НУУЦ ҮГ
  // =============================================

  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('Нэвтрээгүй байна');
    if (user.email == null) throw Exception('И-мэйл олдсонгүй');

    await _client.auth.signInWithPassword(
      email: user.email!,
      password: currentPassword,
    );

    final response = await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );

    if (response.user == null) {
      throw Exception('Нууц үг солиход алдаа гарлаа');
    }
  }

  // =============================================
  // ПРОФАЙЛ
  // =============================================

  // FIX: single() → maybeSingle() — профайл алга болох үндсэн шалтгааныг засав
  static Future<ProfileModel?> getProfile() async {
    if (currentUserId == null) return null;
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', currentUserId!)
          .maybeSingle(); // ← ГОЛ ЗАСВАР

      if (data == null) return null;
      return ProfileModel.fromJson(data);
    } catch (e) {
      // ignore: avoid_print
      print('[SupabaseService] getProfile error: $e');
      return null;
    }
  }

  static Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (currentUserId == null) return;
    await _client.from('profiles').update({
      ...updates,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', currentUserId!);
  }

  // =============================================
  // ADMIN — ЭРХИЙН ШАЛГАЛТ
  // =============================================

  // profiles table-д "role" TEXT DEFAULT 'user' column байх ёстой
  // Admin болгохдоо SQL: UPDATE profiles SET role='admin' WHERE phone='...';
  static Future<bool> isAdmin() async {
    if (currentUserId == null) return false;
    try {
      final data = await _client
          .from('profiles')
          .select('role')
          .eq('id', currentUserId!)
          .maybeSingle();
      return data?['role'] == 'admin';
    } catch (_) {
      return false;
    }
  }

  // =============================================
  // ADMIN — ХЭРЭГЛЭГЧИД
  // =============================================

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final data = await _client
        .from('profiles')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> setUserRole(String userId, String role) async {
    await _client.from('profiles').update({'role': role}).eq('id', userId);
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
    return data
        .map<LoanProductModel>((json) => LoanProductModel.fromJson(json))
        .toList();
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
    final data = await _client
        .from('loan_applications')
        .insert({
          'application_number': appNumber,
          'user_id': currentUserId!,
          'product_id': productId,
          'requested_amount': requestedAmount,
          'requested_term_months': requestedTermMonths,
          'loan_purpose': loanPurpose,
          'documents': documents ?? [],
        })
        .select('*, loan_products(name_mn)')
        .single();
    return LoanApplicationModel.fromJson(data);
  }

  // ── Хэрэглэгчийн өөрийн хүсэлтүүд ──
  static Future<List<LoanApplicationModel>> getMyApplications() async {
    final data = await _client
        .from('loan_applications')
        .select('*, loan_products(name_mn)')
        .eq('user_id', currentUserId!)
        .order('created_at', ascending: false);
    return data
        .map<LoanApplicationModel>(
          (json) => LoanApplicationModel.fromJson(json),
        )
        .toList();
  }

  // ── Admin: Бүх хүсэлтүүд (LoanApplicationModel хэлбэрээр) ──
  // FIX: profiles холбоосыг тодорхойлсон — reviewed_by давхцлыг арилгав
  static Future<List<LoanApplicationModel>> getAllApplications() async {
    final data = await _client
        .from('loan_applications')
        .select(
          '*, loan_products(name_mn), profiles!loan_applications_user_id_fkey(first_name, last_name, phone)',
        )
        .order('created_at', ascending: false);
    return data
        .map<LoanApplicationModel>(
          (json) => LoanApplicationModel.fromJson(json),
        )
        .toList();
  }

  // ── Admin: Бүх хүсэлтүүд (raw Map — dashboard-д ашиглана) ──
  // FIX: profiles!loan_applications_user_id_fkey — reviewed_by давхцлыг арилгав
  static Future<List<Map<String, dynamic>>> getAllApplicationsRaw() async {
    final data = await _client
        .from('loan_applications')
        .select(
          '*, loan_products(name_mn), profiles!loan_applications_user_id_fkey(first_name, last_name, phone, register_number)',
        )
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  // ── Admin: Хүсэлтийн төлөв өөрчлөх ──
  // FIX: reviewed_by хасав — column байхгүй тохиолдолд алдаа гаргахгүй байхаар
  static Future<void> updateApplicationStatus(
    String applicationId,
    String status, {
    String? rejectionReason,
  }) async {
    final updates = <String, dynamic>{
      'status': status,
      'reviewed_at': DateTime.now().toIso8601String(),
    };
    if (rejectionReason != null && rejectionReason.isNotEmpty) {
      updates['rejection_reason'] = rejectionReason;
    }
    await _client
        .from('loan_applications')
        .update(updates)
        .eq('id', applicationId);
  }

  // =============================================
  // ЗЭЭЛ
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
    // FIX: single() → maybeSingle()
    final data = await _client
        .from('loans')
        .select('*, loan_products(name_mn)')
        .eq('id', loanId)
        .maybeSingle();
    if (data == null) return null;
    return LoanModel.fromJson(data);
  }

  static Future<List<ScheduleModel>> getLoanSchedule(String loanId) async {
    final data = await _client
        .from('loan_schedules')
        .select()
        .eq('loan_id', loanId)
        .order('installment_number');
    return data
        .map<ScheduleModel>((json) => ScheduleModel.fromJson(json))
        .toList();
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

  static Future<List<Map<String, dynamic>>> getPaymentHistory(
    String loanId,
  ) async {
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
    if (currentUserId == null) return [];
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
        .update({'is_read': true}).eq('id', notificationId);
  }

  // ── Admin: нэг хэрэглэгч рүү мэдэгдэл илгээх ──
  static Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    String type = 'general',
  }) async {
    await _client.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
      'is_read': false,
    });
  }

  // ── Admin: тодорхой хэрэглэгч рүү мэдэгдэл илгээх (dashboard-д ашиглана) ──
  static Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    String type = 'general',
  }) async {
    await _client.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
      'is_read': false,
    });
  }

  // ── Admin: бүх хэрэглэгч рүү нэгэн зэрэг мэдэгдэл илгээх ──
  static Future<void> sendNotificationToAll({
    required String title,
    required String body,
    String type = 'general',
  }) async {
    final users = await getAllUsers();
    if (users.isEmpty) return;
    final notifications = users
        .map((u) => {
              'user_id': u['id'],
              'title': title,
              'body': body,
              'type': type,
              'is_read': false,
            })
        .toList();
    await _client.from('notifications').insert(notifications);
  }

  // =============================================
  // ТООЦООЛОЛ
  // =============================================

  static double _pow(double base, int exponent) {
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }

  static double calculateMonthlyPayment(
    double principal,
    double monthlyRate,
    int months,
  ) {
    if (months == 0) return 0;
    if (monthlyRate == 0) return principal / months;
    final rate = monthlyRate / 100;
    final pow = _pow(1 + rate, months);
    return principal * (rate * pow) / (pow - 1);
  }

  static List<Map<String, double>> calculateSchedule(
    double principal,
    double monthlyRate,
    int months,
  ) {
    final rate = monthlyRate / 100;
    final monthlyPayment = calculateMonthlyPayment(
      principal,
      monthlyRate,
      months,
    );
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
