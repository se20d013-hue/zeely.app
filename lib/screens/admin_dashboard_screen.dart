import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'auth_screens.dart';

// =============================================
// ADMIN ӨНГӨНИЙ ТОГТОЛЦОО
// =============================================
class _AC {
  static const Color bg = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF111827);
  static const Color elevated = Color(0xFF1C2537);
  static const Color highlight = Color(0xFF243044);
  static const Color border = Color(0xFF2A3854);

  static const Color accent = Color(0xFF3B82F6);
  static const Color accentLight = Color(0xFF60A5FA);
  static Color accentGlow = const Color(0xFF3B82F6).withOpacity(0.15);

  static const Color success = Color(0xFF10B981);
  static Color successGlow = const Color(0xFF10B981).withOpacity(0.12);
  static const Color error = Color(0xFFEF4444);
  static Color errorGlow = const Color(0xFFEF4444).withOpacity(0.12);
  static const Color warning = Color(0xFFF59E0B);
  static Color warningGlow = const Color(0xFFF59E0B).withOpacity(0.12);
  static const Color info = Color(0xFF8B5CF6);
  static Color infoGlow = const Color(0xFF8B5CF6).withOpacity(0.12);

  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textHint = Color(0xFF475569);
}

// =============================================
// ADMIN DASHBOARD ҮНДСЭН ДЭЛГЭЦ
// =============================================
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      if (mounted) setState(() => _selectedTab = _tabCtrl.index);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await SupabaseService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AC.bg,
      body: Column(
        children: [
          // ── Custom AppBar ────────────────────────
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 20,
              right: 16,
              bottom: 12,
            ),
            decoration: BoxDecoration(
              color: _AC.surface,
              border: Border(bottom: BorderSide(color: _AC.border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _AC.accentGlow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _AC.accent.withOpacity(0.4)),
                  ),
                  child: const Icon(Icons.shield_rounded,
                      color: _AC.accentLight, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Админ Панел',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _AC.textPrimary,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                    Text(
                      'Зээлийн систем',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _AC.accent,
                        fontFamily: 'Gilroy',
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _logout,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _AC.errorGlow,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _AC.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded,
                            size: 15, color: _AC.error.withOpacity(0.9)),
                        const SizedBox(width: 6),
                        Text(
                          'Гарах',
                          style: TextStyle(
                            fontSize: 13,
                            color: _AC.error.withOpacity(0.9),
                            fontFamily: 'Gilroy',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Custom TabBar ────────────────────────
          Container(
            color: _AC.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                _buildTab(0, Icons.receipt_long_rounded, 'Хүсэлт'),
                const SizedBox(width: 8),
                _buildTab(1, Icons.people_alt_rounded, 'Хэрэглэгч'),
                const SizedBox(width: 8),
                _buildTab(2, Icons.campaign_rounded, 'Мэдэгдэл'),
              ],
            ),
          ),

          // ── Content ──────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: const [
                _ApplicationsTab(),
                _UsersTab(),
                _NotificationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _tabCtrl.animateTo(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _AC.accentGlow : _AC.elevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _AC.accent.withOpacity(0.5) : _AC.border,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? _AC.accentLight : _AC.textHint,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? _AC.accentLight : _AC.textHint,
                  fontFamily: 'Gilroy',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================
// ТАБ 1: ЗЭЭЛИЙН ХҮСЭЛТҮҮД
// =============================================
class _ApplicationsTab extends StatefulWidget {
  const _ApplicationsTab();

  @override
  State<_ApplicationsTab> createState() => _ApplicationsTabState();
}

class _ApplicationsTabState extends State<_ApplicationsTab> {
  List<Map<String, dynamic>> _applications = [];
  bool _loading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // FIX: getAllApplicationsRaw — profiles!loan_applications_user_id_fkey
      final data = await SupabaseService.getAllApplicationsRaw();
      if (mounted) setState(() => _applications = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Алдаа: $e', style: const TextStyle(fontFamily: 'Gilroy')),
          backgroundColor: _AC.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'all') return _applications;
    return _applications.where((a) => a['status'] == _filter).toList();
  }

  Color _statusColor(String? s) {
    switch (s) {
      case 'approved':
        return _AC.success;
      case 'rejected':
        return _AC.error;
      case 'pending':
        return _AC.warning;
      case 'under_review':
        return _AC.info;
      default:
        return _AC.textHint;
    }
  }

  Color _statusGlow(String? s) {
    switch (s) {
      case 'approved':
        return _AC.successGlow;
      case 'rejected':
        return _AC.errorGlow;
      case 'pending':
        return _AC.warningGlow;
      case 'under_review':
        return _AC.infoGlow;
      default:
        return Colors.transparent;
    }
  }

  String _statusLabel(String? s) {
    switch (s) {
      case 'approved':
        return 'Зөвшөөрсөн';
      case 'rejected':
        return 'Татгалзсан';
      case 'pending':
        return 'Хүлээгдэж буй';
      case 'under_review':
        return 'Шалгаж байна';
      default:
        return s ?? '—';
    }
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return '—';
    final num = double.tryParse(amount.toString()) ?? 0;
    if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)}сая₮';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(0)}мян₮';
    return '${num.toStringAsFixed(0)}₮';
  }

  void _showMsg(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Gilroy')),
      backgroundColor: isError ? _AC.error : _AC.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Future<void> _updateStatus(String id, String status) async {
    String? reason;
    if (status == 'rejected') {
      reason = await _showRejectDialog();
      if (reason == null) return;
    }
    try {
      await SupabaseService.updateApplicationStatus(id, status,
          rejectionReason: reason);
      _showMsg(status == 'approved' ? '✓ Зөвшөөрөгдлөө!' : '✗ Татгалзлаа');
      _load();
    } catch (e) {
      _showMsg('Алдаа: $e', isError: true);
    }
  }

  Future<String?> _showRejectDialog() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _AC.elevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _AC.errorGlow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.block_rounded,
                        color: _AC.error, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Татгалзах шалтгаан',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _AC.textPrimary,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: ctrl,
                style: const TextStyle(
                    color: _AC.textPrimary, fontFamily: 'Gilroy'),
                decoration: InputDecoration(
                  hintText: 'Шалтгаан оруулна уу...',
                  hintStyle: const TextStyle(
                      color: _AC.textHint, fontFamily: 'Gilroy'),
                  filled: true,
                  fillColor: _AC.highlight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _AC.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _AC.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _AC.accent),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _AC.highlight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _AC.border),
                        ),
                        child: const Center(
                          child: Text('Болих',
                              style: TextStyle(
                                fontSize: 13,
                                color: _AC.textSecondary,
                                fontFamily: 'Gilroy',
                              )),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, ctrl.text),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _AC.errorGlow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _AC.error.withOpacity(0.4)),
                        ),
                        child: const Center(
                          child: Text('Татгалзах',
                              style: TextStyle(
                                fontSize: 13,
                                color: _AC.error,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Gilroy',
                              )),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(Map<String, dynamic> app) {
    final profile = app['profiles'] as Map<String, dynamic>?;
    final product = app['loan_products'] as Map<String, dynamic>?;
    final status = app['status'] as String?;

    showModalBottomSheet(
      context: context,
      backgroundColor: _AC.elevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.62,
        maxChildSize: 0.92,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _AC.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _statusGlow(status),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: _statusColor(status).withOpacity(0.3)),
                    ),
                    child: Icon(Icons.receipt_long_rounded,
                        color: _statusColor(status), size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app['application_number'] ?? '—',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _AC.textPrimary,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                        const SizedBox(height: 4),
                        _StatusBadge(
                            label: _statusLabel(status),
                            color: _statusColor(status),
                            glow: _statusGlow(status)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _AC.highlight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _AC.border),
                ),
                child: Column(
                  children: [
                    _DetailRow2(
                      'Хэрэглэгч',
                      '${profile?['last_name'] ?? ''} ${profile?['first_name'] ?? '—'}',
                    ),
                    _DetailRow2('Утас', profile?['phone']?.toString() ?? '—'),
                    _DetailRow2('Регистр',
                        profile?['register_number']?.toString() ?? '—'),
                    _DetailRow2(
                        'Бүтээгдэхүүн', product?['name_mn']?.toString() ?? '—'),
                    _DetailRow2(
                      'Дүн',
                      _formatAmount(app['requested_amount']),
                      valueColor: _AC.accentLight,
                    ),
                    _DetailRow2('Хугацаа',
                        '${app['requested_term_months'] ?? '—'} сар'),
                    _DetailRow2(
                      'Зорилго',
                      app['loan_purpose']?.toString() ?? '—',
                      isLast: app['rejection_reason'] == null,
                    ),
                    if (app['rejection_reason'] != null)
                      _DetailRow2(
                        'Шалтгаан',
                        app['rejection_reason'].toString(),
                        valueColor: _AC.error,
                        isLast: true,
                      ),
                  ],
                ),
              ),
              if (status == 'pending' || status == 'under_review') ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        label: 'Зөвшөөрөх',
                        icon: Icons.check_circle_rounded,
                        color: _AC.success,
                        glow: _AC.successGlow,
                        onTap: () {
                          Navigator.pop(ctx);
                          _updateStatus(app['id'], 'approved');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionBtn(
                        label: 'Татгалзах',
                        icon: Icons.cancel_rounded,
                        color: _AC.error,
                        glow: _AC.errorGlow,
                        onTap: () {
                          Navigator.pop(ctx);
                          _updateStatus(app['id'], 'rejected');
                        },
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final counts = {
      'all': _applications.length,
      'pending': _applications.where((a) => a['status'] == 'pending').length,
      'under_review':
          _applications.where((a) => a['status'] == 'under_review').length,
      'approved': _applications.where((a) => a['status'] == 'approved').length,
      'rejected': _applications.where((a) => a['status'] == 'rejected').length,
    };

    return Column(
      children: [
        // ── Шүүлтүүр ────────────────────────────
        Container(
          color: _AC.surface,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterPill(
                    label: 'Бүгд',
                    count: counts['all']!,
                    active: _filter == 'all',
                    onTap: () => setState(() => _filter = 'all')),
                _FilterPill(
                    label: 'Хүлээгдэж буй',
                    count: counts['pending']!,
                    active: _filter == 'pending',
                    color: _AC.warning,
                    onTap: () => setState(() => _filter = 'pending')),
                _FilterPill(
                    label: 'Шалгаж байна',
                    count: counts['under_review']!,
                    active: _filter == 'under_review',
                    color: _AC.info,
                    onTap: () => setState(() => _filter = 'under_review')),
                _FilterPill(
                    label: 'Зөвшөөрсөн',
                    count: counts['approved']!,
                    active: _filter == 'approved',
                    color: _AC.success,
                    onTap: () => setState(() => _filter = 'approved')),
                _FilterPill(
                    label: 'Татгалзсан',
                    count: counts['rejected']!,
                    active: _filter == 'rejected',
                    color: _AC.error,
                    onTap: () => setState(() => _filter = 'rejected')),
              ],
            ),
          ),
        ),

        // ── Жагсаалт ────────────────────────────
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: _AC.accent))
              : _filtered.isEmpty
                  ? _EmptyState(
                      icon: Icons.inbox_rounded, label: 'Хүсэлт байхгүй байна')
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: _AC.accent,
                      backgroundColor: _AC.elevated,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final app = _filtered[i];
                          final profile =
                              app['profiles'] as Map<String, dynamic>?;
                          final product =
                              app['loan_products'] as Map<String, dynamic>?;
                          final status = app['status'] as String?;
                          final isPending =
                              status == 'pending' || status == 'under_review';
                          final initial =
                              (profile?['first_name'] as String? ?? '?')
                                      .isNotEmpty
                                  ? (profile?['first_name'] as String)[0]
                                      .toUpperCase()
                                  : '?';

                          return GestureDetector(
                            onTap: () => _showDetail(app),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: _AC.elevated,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: _AC.border),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Avatar
                                        Container(
                                          width: 46,
                                          height: 46,
                                          decoration: BoxDecoration(
                                            color: _AC.accentGlow,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            border: Border.all(
                                                color: _AC.accent
                                                    .withOpacity(0.3)),
                                          ),
                                          child: Center(
                                            child: Text(
                                              initial,
                                              style: const TextStyle(
                                                color: _AC.accentLight,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w800,
                                                fontFamily: 'Gilroy',
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${profile?['last_name'] ?? ''} ${profile?['first_name'] ?? '—'}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: _AC.textPrimary,
                                                  fontFamily: 'Gilroy',
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                profile?['phone']?.toString() ??
                                                    '',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: _AC.textSecondary,
                                                  fontFamily: 'Gilroy',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _StatusBadge(
                                          label: _statusLabel(status),
                                          color: _statusColor(status),
                                          glow: _statusGlow(status),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Дүн + бүтээгдэхүүн
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(
                                        14, 0, 14, 12),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _AC.highlight,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: _AC.border),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.credit_card_rounded,
                                            size: 14, color: _AC.textHint),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            product?['name_mn']?.toString() ??
                                                '—',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: _AC.textSecondary,
                                              fontFamily: 'Gilroy',
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _formatAmount(
                                              app['requested_amount']),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: _AC.accentLight,
                                            fontFamily: 'Gilroy',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Товчнууд
                                  if (isPending)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          14, 0, 14, 14),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _ActionBtn(
                                              label: 'Зөвшөөрөх',
                                              icon: Icons.check_rounded,
                                              color: _AC.success,
                                              glow: _AC.successGlow,
                                              compact: true,
                                              onTap: () => _updateStatus(
                                                  app['id'], 'approved'),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: _ActionBtn(
                                              label: 'Татгалзах',
                                              icon: Icons.close_rounded,
                                              color: _AC.error,
                                              glow: _AC.errorGlow,
                                              compact: true,
                                              onTap: () => _updateStatus(
                                                  app['id'], 'rejected'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}

// =============================================
// ТАБ 2: ХЭРЭГЛЭГЧИД
// =============================================
class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await SupabaseService.getAllUsers();
      if (mounted) setState(() => _users = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Алдаа: $e'),
          backgroundColor: _AC.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_search.isEmpty) return _users;
    final q = _search.toLowerCase();
    return _users.where((u) {
      final name =
          '${u['first_name'] ?? ''} ${u['last_name'] ?? ''}'.toLowerCase();
      final phone = (u['phone'] ?? '').toString();
      return name.contains(q) || phone.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Хайлт ─────────────────────────────────
        Container(
          color: _AC.surface,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: TextField(
            style: const TextStyle(
                color: _AC.textPrimary, fontFamily: 'Gilroy', fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Нэр эсвэл утасны дугаараар хайх...',
              hintStyle: const TextStyle(
                  color: _AC.textHint, fontFamily: 'Gilroy', fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: _AC.textHint, size: 20),
              filled: true,
              fillColor: _AC.elevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _AC.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _AC.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _AC.accent),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Text(
                'Нийт ${_filtered.length} хэрэглэгч',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _AC.textHint,
                  fontFamily: 'Gilroy',
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: _AC.accent))
              : _filtered.isEmpty
                  ? _EmptyState(
                      icon: Icons.person_search_rounded,
                      label: 'Хэрэглэгч олдсонгүй')
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: _AC.accent,
                      backgroundColor: _AC.elevated,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final u = _filtered[i];
                          final isAdmin = u['role'] == 'admin';
                          final name =
                              '${u['last_name'] ?? ''} ${u['first_name'] ?? '—'}';
                          final initial =
                              (u['first_name'] as String? ?? '?').isNotEmpty
                                  ? (u['first_name'] as String)[0].toUpperCase()
                                  : '?';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _AC.elevated,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _AC.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isAdmin
                                        ? _AC.warningGlow
                                        : _AC.accentGlow,
                                    borderRadius: BorderRadius.circular(13),
                                    border: Border.all(
                                      color: isAdmin
                                          ? _AC.warning.withOpacity(0.35)
                                          : _AC.accent.withOpacity(0.35),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      initial,
                                      style: TextStyle(
                                        color: isAdmin
                                            ? _AC.warning
                                            : _AC.accentLight,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Gilroy',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: _AC.textPrimary,
                                            fontFamily: 'Gilroy',
                                          )),
                                      const SizedBox(height: 2),
                                      Text(
                                        u['phone']?.toString() ?? '—',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: _AC.textSecondary,
                                          fontFamily: 'Gilroy',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isAdmin
                                        ? _AC.warningGlow
                                        : _AC.accentGlow,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isAdmin
                                          ? _AC.warning.withOpacity(0.35)
                                          : _AC.accent.withOpacity(0.35),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isAdmin
                                            ? Icons.shield_rounded
                                            : Icons.person_rounded,
                                        size: 12,
                                        color: isAdmin
                                            ? _AC.warning
                                            : _AC.accentLight,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isAdmin ? 'Admin' : 'Хэрэглэгч',
                                        style: TextStyle(
                                          color: isAdmin
                                              ? _AC.warning
                                              : _AC.accentLight,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Gilroy',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}

// =============================================
// ТАБ 3: МЭДЭГДЭЛ ИЛГЭЭХ
// =============================================
class _NotificationsTab extends StatefulWidget {
  const _NotificationsTab();

  @override
  State<_NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<_NotificationsTab> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _type = 'general';
  String _target = 'all';
  String? _selectedUserId;
  List<Map<String, dynamic>> _users = [];
  bool _sending = false;
  bool _loadingUsers = true;

  final List<Map<String, String>> _types = [
    {'value': 'general', 'label': 'Ерөнхий мэдэгдэл'},
    {'value': 'payment_due', 'label': 'Төлбөрийн сануулга'},
    {'value': 'loan_approved', 'label': 'Зээл зөвшөөрсөн'},
    {'value': 'loan_rejected', 'label': 'Зээл татгалзсан'},
    {'value': 'overdue', 'label': 'Хугацаа хэтэрсэн'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      final data = await SupabaseService.getAllUsers();
      if (mounted) setState(() => _users = data);
    } finally {
      if (mounted) setState(() => _loadingUsers = false);
    }
  }

  void _showMsg(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Gilroy')),
      backgroundColor: isError ? _AC.error : _AC.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Future<void> _send() async {
    if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) {
      _showMsg('Гарчиг болон агуулгыг бөглөнө үү', isError: true);
      return;
    }
    if (_target == 'single' && _selectedUserId == null) {
      _showMsg('Хэрэглэгч сонгоно уу', isError: true);
      return;
    }
    setState(() => _sending = true);
    try {
      if (_target == 'all') {
        await SupabaseService.sendNotificationToAll(
          title: _titleCtrl.text.trim(),
          body: _bodyCtrl.text.trim(),
          type: _type,
        );
        _showMsg('✓ ${_users.length} хэрэглэгчид мэдэгдэл илгээгдлээ');
      } else {
        await SupabaseService.sendNotificationToUser(
          userId: _selectedUserId!,
          title: _titleCtrl.text.trim(),
          body: _bodyCtrl.text.trim(),
          type: _type,
        );
        _showMsg('✓ Мэдэгдэл амжилттай илгээгдлээ');
      }
      _titleCtrl.clear();
      _bodyCtrl.clear();
      setState(() => _type = 'general');
    } catch (e) {
      _showMsg('Алдаа: $e', isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Widget _adminField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _AC.textHint,
            fontFamily: 'Gilroy',
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
              color: _AC.textPrimary, fontFamily: 'Gilroy', fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: _AC.textHint, fontFamily: 'Gilroy', fontSize: 13),
            prefixIcon: Icon(icon, color: _AC.textHint, size: 18),
            filled: true,
            fillColor: _AC.elevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _AC.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _AC.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _AC.accent),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Хүлээн авагч ──────────────────────────
          const Text(
            'ХҮЛЭЭН АВАГЧ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _AC.textHint,
              fontFamily: 'Gilroy',
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _target = 'all'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _target == 'all' ? _AC.accentGlow : _AC.elevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _target == 'all'
                            ? _AC.accent.withOpacity(0.5)
                            : _AC.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.groups_rounded,
                            size: 26,
                            color: _target == 'all'
                                ? _AC.accentLight
                                : _AC.textHint),
                        const SizedBox(height: 8),
                        Text(
                          'Бүгд',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _target == 'all'
                                ? _AC.accentLight
                                : _AC.textSecondary,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_users.length} хэрэглэгч',
                          style: TextStyle(
                            fontSize: 11,
                            color: _target == 'all'
                                ? _AC.accent.withOpacity(0.7)
                                : _AC.textHint,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _target = 'single'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:
                          _target == 'single' ? _AC.accentGlow : _AC.elevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _target == 'single'
                            ? _AC.accent.withOpacity(0.5)
                            : _AC.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.person_search_rounded,
                            size: 26,
                            color: _target == 'single'
                                ? _AC.accentLight
                                : _AC.textHint),
                        const SizedBox(height: 8),
                        Text(
                          'Тодорхой хүн',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _target == 'single'
                                ? _AC.accentLight
                                : _AC.textSecondary,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Нэг хэрэглэгч',
                          style: TextStyle(
                            fontSize: 11,
                            color: _target == 'single'
                                ? _AC.accent.withOpacity(0.7)
                                : _AC.textHint,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (_target == 'single') ...[
            const SizedBox(height: 16),
            _loadingUsers
                ? const Center(
                    child: CircularProgressIndicator(color: _AC.accent))
                : DropdownButtonFormField<String>(
                    value: _selectedUserId,
                    dropdownColor: _AC.elevated,
                    style: const TextStyle(
                        color: _AC.textPrimary,
                        fontFamily: 'Gilroy',
                        fontSize: 13),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_rounded,
                          color: _AC.textHint, size: 18),
                      filled: true,
                      fillColor: _AC.elevated,
                      hintStyle: const TextStyle(
                          color: _AC.textHint, fontFamily: 'Gilroy'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _AC.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _AC.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _AC.accent),
                      ),
                    ),
                    hint: const Text('Хэрэглэгч сонгох...',
                        style: TextStyle(
                            color: _AC.textHint, fontFamily: 'Gilroy')),
                    items: _users.map((u) {
                      final name =
                          '${u['last_name'] ?? ''} ${u['first_name'] ?? ''}';
                      final phone = u['phone']?.toString() ?? '';
                      return DropdownMenuItem(
                        value: u['id'] as String,
                        child: Text('$name — $phone',
                            style: const TextStyle(
                                color: _AC.textPrimary,
                                fontFamily: 'Gilroy',
                                fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedUserId = v),
                  ),
          ],

          const SizedBox(height: 20),

          // ── Мэдэгдлийн төрөл ──────────────────────
          const Text(
            'МЭДЭГДЛИЙН ТӨРӨЛ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _AC.textHint,
              fontFamily: 'Gilroy',
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _type,
            dropdownColor: _AC.elevated,
            style: const TextStyle(
                color: _AC.textPrimary, fontFamily: 'Gilroy', fontSize: 13),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.category_rounded,
                  color: _AC.textHint, size: 18),
              filled: true,
              fillColor: _AC.elevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _AC.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _AC.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _AC.accent),
              ),
            ),
            items: _types
                .map((t) => DropdownMenuItem(
                    value: t['value'],
                    child: Text(t['label']!,
                        style: const TextStyle(
                            color: _AC.textPrimary,
                            fontFamily: 'Gilroy',
                            fontSize: 13))))
                .toList(),
            onChanged: (v) => setState(() => _type = v ?? 'general'),
          ),
          const SizedBox(height: 20),

          _adminField(
            controller: _titleCtrl,
            label: 'Гарчиг',
            hint: 'Мэдэгдлийн гарчиг...',
            icon: Icons.title_rounded,
          ),
          const SizedBox(height: 16),

          _adminField(
            controller: _bodyCtrl,
            label: 'Агуулга',
            hint: 'Мэдэгдлийн дэлгэрэнгүй агуулга...',
            icon: Icons.message_rounded,
            maxLines: 4,
          ),
          const SizedBox(height: 28),

          // ── Илгээх товч ───────────────────────────
          GestureDetector(
            onTap: _sending ? null : _send,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _sending ? _AC.accentGlow : _AC.accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_sending)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.send_rounded,
                        color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    _sending
                        ? 'Илгээж байна...'
                        : _target == 'all'
                            ? 'Бүгдэд илгээх (${_users.length})'
                            : 'Илгээх',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// =============================================
// ДЭМЖИХ WIDGET-УУД
// =============================================

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color glow;
  const _StatusBadge(
      {required this.label, required this.color, required this.glow});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: glow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            fontFamily: 'Gilroy',
          ),
        ),
      );
}

class _FilterPill extends StatelessWidget {
  final String label;
  final int count;
  final bool active;
  final Color? color;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? _AC.accent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? c.withOpacity(0.15) : _AC.elevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? c.withOpacity(0.5) : _AC.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: active ? c : _AC.textSecondary,
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                fontFamily: 'Gilroy',
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: active ? c.withOpacity(0.25) : _AC.border,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: active ? c : _AC.textHint,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Gilroy',
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

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color glow;
  final VoidCallback onTap;
  final bool compact;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.glow,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: compact ? 10 : 14),
          decoration: BoxDecoration(
            color: glow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: compact ? 15 : 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: compact ? 12 : 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Gilroy',
                ),
              ),
            ],
          ),
        ),
      );
}

class _DetailRow2 extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;

  const _DetailRow2(this.label, this.value,
      {this.valueColor, this.isLast = false});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: Text(label,
                      style: const TextStyle(
                          fontSize: 13,
                          color: _AC.textSecondary,
                          fontFamily: 'Gilroy')),
                ),
                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: valueColor ?? _AC.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isLast) Divider(color: _AC.border, height: 1, thickness: 0.5),
        ],
      );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EmptyState({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _AC.elevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _AC.border),
              ),
              child: Icon(icon, size: 34, color: _AC.textHint),
            ),
            const SizedBox(height: 16),
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    color: _AC.textSecondary,
                    fontFamily: 'Gilroy')),
          ],
        ),
      );
}
