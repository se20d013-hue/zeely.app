class AppUtils {
  static String formatCurrency(double amount) {
    final formatted = _formatNumber(amount.toStringAsFixed(0));
    return '$formatted₮';
  }

  static String formatCurrencyShort(double amount) {
    if (amount >= 1000000000)
      return '${(amount / 1000000000).toStringAsFixed(1)}тэрбум₮';
    if (amount >= 1000000)
      return '${(amount / 1000000).toStringAsFixed(1)}сая₮';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}мян₮';
    return formatCurrency(amount);
  }

  static String _formatNumber(String number) {
    final buffer = StringBuffer();
    int count = 0;
    for (int i = number.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write(',');
      buffer.write(number[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join('');
  }

  static String formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String formatMonthYear(DateTime date) {
    return '${date.year} оны ${date.month.toString().padLeft(2, '0')} сар';
  }

  static String formatPhoneNumber(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length == 8)
      return '${digits.substring(0, 4)} ${digits.substring(4)}';
    return phone;
  }

  static bool isValidRegisterNumber(String register) {
    return RegExp(r'^[А-ЯӨҮа-яөү]{2}\d{8}$').hasMatch(register);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^[679]\d{7}$').hasMatch(phone);
  }

  static String getLoanTypeIcon(String loanType) {
    switch (loanType) {
      case 'personal':
        return '💳';
      case 'mortgage':
        return '🏠';
      case 'auto':
        return '🚗';
      case 'business':
        return '💼';
      case 'education':
        return '📚';
      case 'emergency':
        return '⚡';
      default:
        return '💰';
    }
  }

  static String getEmploymentTypeLabel(String? type) {
    switch (type) {
      case 'employee':
        return 'Ажилтан';
      case 'self_employed':
        return 'Өөрөө ажиллагч';
      case 'business_owner':
        return 'Бизнес эзэмшигч';
      default:
        return 'Тодорхойгүй';
    }
  }

  static int daysUntilDue(DateTime dueDate) {
    return dueDate.difference(DateTime.now()).inDays;
  }
}
