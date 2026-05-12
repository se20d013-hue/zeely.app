// lib/models/profile_model.dart
class ProfileModel {
  final String id;
  final String registerNumber;
  final String lastName;
  final String firstName;
  final String phone;
  final String? email;
  final DateTime? birthDate;
  final String? gender;
  final String? address;
  final int creditScore;
  final double monthlyIncome;
  final String? employmentType;
  final String? employerName;
  final bool isVerified;
  final String? profileImageUrl;
  final String? avatarUrl; // ✅ Нэмсэн
  final String? emergencyContactName; // ✅ Нэмсэн
  final String? emergencyContactPhone; // ✅ Нэмсэн

  ProfileModel({
    required this.id,
    required this.registerNumber,
    required this.lastName,
    required this.firstName,
    required this.phone,
    this.email,
    this.birthDate,
    this.gender,
    this.address,
    this.creditScore = 0,
    this.monthlyIncome = 0,
    this.employmentType,
    this.employerName,
    this.isVerified = false,
    this.profileImageUrl,
    this.avatarUrl,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });

  String get fullName => '$lastName $firstName';

  String get creditScoreLabel {
    if (creditScore >= 750) return 'Маш сайн';
    if (creditScore >= 650) return 'Сайн';
    if (creditScore >= 550) return 'Дундаж';
    if (creditScore >= 450) return 'Хангалттай';
    return 'Хангалтгүй';
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'],
        registerNumber: json['register_number'] ?? '',
        lastName: json['last_name'] ?? '',
        firstName: json['first_name'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'],
        birthDate: json['birth_date'] != null
            ? DateTime.parse(json['birth_date'])
            : null,
        gender: json['gender'],
        address: json['address'],
        creditScore: json['credit_score'] ?? 0,
        monthlyIncome: (json['monthly_income'] ?? 0).toDouble(),
        employmentType: json['employment_type'],
        employerName: json['employer_name'],
        isVerified: json['is_verified'] ?? false,
        profileImageUrl: json['profile_image_url'],
        avatarUrl: json['avatar_url'], // ✅
        emergencyContactName: json['emergency_contact_name'], // ✅
        emergencyContactPhone: json['emergency_contact_phone'], // ✅
      );

  Map<String, dynamic> toJson() => {
        'register_number': registerNumber,
        'last_name': lastName,
        'first_name': firstName,
        'phone': phone,
        'email': email,
        'birth_date': birthDate?.toIso8601String(),
        'gender': gender,
        'address': address,
        'monthly_income': monthlyIncome,
        'employment_type': employmentType,
        'employer_name': employerName,
        'avatar_url': avatarUrl,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_phone': emergencyContactPhone,
      };
}

// lib/models/loan_product_model.dart
class LoanProductModel {
  final String id;
  final String name;
  final String nameMn;
  final String loanType;
  final double minAmount;
  final double maxAmount;
  final int minTermMonths;
  final int maxTermMonths;
  final double interestRateMonthly;
  final double processingFeePercent;
  final int minCreditScore;
  final String? iconName;
  final String? colorHex;
  final List<String> features;

  LoanProductModel({
    required this.id,
    required this.name,
    required this.nameMn,
    required this.loanType,
    required this.minAmount,
    required this.maxAmount,
    required this.minTermMonths,
    required this.maxTermMonths,
    required this.interestRateMonthly,
    required this.processingFeePercent,
    required this.minCreditScore,
    this.iconName,
    this.colorHex,
    this.features = const [],
  });

  String get annualRate => '${(interestRateMonthly * 12).toStringAsFixed(1)}%';
  String get monthlyRate => '${interestRateMonthly.toStringAsFixed(1)}%';

  factory LoanProductModel.fromJson(Map<String, dynamic> json) =>
      LoanProductModel(
        id: json['id'],
        name: json['name'],
        nameMn: json['name_mn'],
        loanType: json['loan_type'],
        minAmount: (json['min_amount'] ?? 0).toDouble(),
        maxAmount: (json['max_amount'] ?? 0).toDouble(),
        minTermMonths: json['min_term_months'] ?? 1,
        maxTermMonths: json['max_term_months'] ?? 60,
        interestRateMonthly: (json['interest_rate_monthly'] ?? 0).toDouble(),
        processingFeePercent: (json['processing_fee_percent'] ?? 0).toDouble(),
        minCreditScore: json['min_credit_score'] ?? 500,
        iconName: json['icon_name'],
        colorHex: json['color_hex'],
        features: List<String>.from(json['features'] ?? []),
      );
}

// lib/models/loan_model.dart
class LoanModel {
  final String id;
  final String loanNumber;
  final String productId;
  final String? productName;
  final double principalAmount;
  final double interestRateMonthly;
  final int termMonths;
  final double outstandingPrincipal;
  final double outstandingInterest;
  final double totalPaid;
  final double monthlyPayment;
  final DateTime? nextPaymentDate;
  final DateTime maturityDate;
  final String status;
  final int overdueDays;
  final double penaltyAmount;
  final DateTime? disbursedAt;

  LoanModel({
    required this.id,
    required this.loanNumber,
    required this.productId,
    this.productName,
    required this.principalAmount,
    required this.interestRateMonthly,
    required this.termMonths,
    required this.outstandingPrincipal,
    required this.outstandingInterest,
    required this.totalPaid,
    required this.monthlyPayment,
    this.nextPaymentDate,
    required this.maturityDate,
    required this.status,
    this.overdueDays = 0,
    this.penaltyAmount = 0,
    this.disbursedAt,
  });

  double get totalOutstanding =>
      outstandingPrincipal + outstandingInterest + penaltyAmount;
  double get progressPercent => (totalPaid /
          (principalAmount +
              (principalAmount * interestRateMonthly / 100 * termMonths)))
      .clamp(0.0, 1.0);

  bool get isOverdue => status == 'overdue';
  bool get isActive => status == 'active';

  double? get remainingBalance => outstandingPrincipal;
  double? get loanAmount => principalAmount;

  String get statusLabel {
    switch (status) {
      case 'active':
        return 'Идэвхтэй';
      case 'overdue':
        return 'Хугацаа хэтэрсэн';
      case 'closed':
        return 'Хаагдсан';
      case 'written_off':
        return 'Хасагдсан';
      default:
        return status;
    }
  }

  factory LoanModel.fromJson(Map<String, dynamic> json) => LoanModel(
        id: json['id'],
        loanNumber: json['loan_number'],
        productId: json['product_id'],
        productName: json['loan_products']?['name_mn'],
        principalAmount: (json['principal_amount'] ?? 0).toDouble(),
        interestRateMonthly: (json['interest_rate_monthly'] ?? 0).toDouble(),
        termMonths: json['term_months'] ?? 0,
        outstandingPrincipal: (json['outstanding_principal'] ?? 0).toDouble(),
        outstandingInterest: (json['outstanding_interest'] ?? 0).toDouble(),
        totalPaid: (json['total_paid'] ?? 0).toDouble(),
        monthlyPayment: (json['monthly_payment'] ?? 0).toDouble(),
        nextPaymentDate: json['next_payment_date'] != null
            ? DateTime.parse(json['next_payment_date'])
            : null,
        maturityDate: DateTime.parse(json['maturity_date']),
        status: json['status'] ?? 'active',
        overdueDays: json['overdue_days'] ?? 0,
        penaltyAmount: (json['penalty_amount'] ?? 0).toDouble(),
        disbursedAt: json['disbursed_at'] != null
            ? DateTime.parse(json['disbursed_at'])
            : null,
      );
}

// lib/models/loan_application_model.dart
class LoanApplicationModel {
  final String id;
  final String applicationNumber;
  final String productId;
  final String? productName;
  final double requestedAmount;
  final int requestedTermMonths;
  final String? loanPurpose;
  final double? approvedAmount;
  final String status;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  LoanApplicationModel({
    required this.id,
    required this.applicationNumber,
    required this.productId,
    this.productName,
    required this.requestedAmount,
    required this.requestedTermMonths,
    this.loanPurpose,
    this.approvedAmount,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    this.reviewedAt,
  });

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Хүлээгдэж буй';
      case 'under_review':
        return 'Хянагдаж буй';
      case 'approved':
        return 'Батлагдсан';
      case 'rejected':
        return 'Татгалзсан';
      case 'disbursed':
        return 'Олгогдсон';
      case 'cancelled':
        return 'Цуцлагдсан';
      default:
        return status;
    }
  }

  factory LoanApplicationModel.fromJson(Map<String, dynamic> json) =>
      LoanApplicationModel(
        id: json['id'],
        applicationNumber: json['application_number'],
        productId: json['product_id'],
        productName: json['loan_products']?['name_mn'],
        requestedAmount: (json['requested_amount'] ?? 0).toDouble(),
        requestedTermMonths: json['requested_term_months'] ?? 0,
        loanPurpose: json['loan_purpose'],
        approvedAmount: json['approved_amount']?.toDouble(),
        status: json['status'] ?? 'pending',
        rejectionReason: json['rejection_reason'],
        createdAt: DateTime.parse(json['created_at']),
        reviewedAt: json['reviewed_at'] != null
            ? DateTime.parse(json['reviewed_at'])
            : null,
      );
}

// lib/models/schedule_model.dart
class ScheduleModel {
  final String id;
  final int installmentNumber;
  final DateTime dueDate;
  final double principalAmount;
  final double interestAmount;
  final double totalAmount;
  final double paidAmount;
  final DateTime? paidDate;
  final String status;
  final double penaltyAmount;

  ScheduleModel({
    required this.id,
    required this.installmentNumber,
    required this.dueDate,
    required this.principalAmount,
    required this.interestAmount,
    required this.totalAmount,
    required this.paidAmount,
    this.paidDate,
    required this.status,
    this.penaltyAmount = 0,
  });

  bool get isPaid => status == 'paid';
  bool get isOverdue => status == 'overdue';
  double get remainingAmount => totalAmount - paidAmount + penaltyAmount;

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => ScheduleModel(
        id: json['id'],
        installmentNumber: json['installment_number'],
        dueDate: DateTime.parse(json['due_date']),
        principalAmount: (json['principal_amount'] ?? 0).toDouble(),
        interestAmount: (json['interest_amount'] ?? 0).toDouble(),
        totalAmount: (json['total_amount'] ?? 0).toDouble(),
        paidAmount: (json['paid_amount'] ?? 0).toDouble(),
        paidDate: json['paid_date'] != null
            ? DateTime.parse(json['paid_date'])
            : null,
        status: json['status'] ?? 'pending',
        penaltyAmount: (json['penalty_amount'] ?? 0).toDouble(),
      );
}
