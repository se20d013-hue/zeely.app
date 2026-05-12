import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math' as math;
import '../services/supabase_service.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'auth_screens.dart';
import 'appearance_screen.dart';

class _T {
  static const Color bg = Color(0xFF030712);
  static const Color surface = Color(0xFF080F1E);
  static const Color glass = Color(0xFF0D1424);
  static const Color glassHi = Color(0xFF0F1E3A);
  static const Color border = Color(0xFF1E3A5F);
  static const Color neon = Color(0xFF3B82F6);
  static const Color neonSoft = Color(0xFF60A5FA);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF8B5CF6);
  static const Color txt1 = Color(0xFFF1F5F9);
  static const Color txt2 = Color(0xFF94A3B8);
  static const Color txt3 = Color(0xFF475569);
}

class AppLocalizations {
  static bool isMongolian = true;
  static String get profile => isMongolian ? 'Профайл' : 'Profile';
  static String get verified => isMongolian ? 'Баталгаажсан' : 'Verified';
  static String get creditScore =>
      isMongolian ? 'Зээлийн оноо' : 'Credit Score';
  static String get grade => isMongolian ? 'Зэрэглэл' : 'Grade';
  static String get income => isMongolian ? 'Орлого' : 'Income';
  static String get personalInfo =>
      isMongolian ? 'Хувийн мэдээлэл' : 'Personal Info';
  static String get register => isMongolian ? 'Регистр' : 'Register No.';
  static String get employment => isMongolian ? 'Ажлын байр' : 'Employment';
  static String get employer => isMongolian ? 'Ажил олгогч' : 'Employer';
  static String get settings => isMongolian ? 'Тохиргоо' : 'Settings';
  static String get editProfile =>
      isMongolian ? 'Мэдээлэл засах' : 'Edit Profile';
  static String get changePassword =>
      isMongolian ? 'Нууц үг солих' : 'Change Password';
  static String get notificationSettings =>
      isMongolian ? 'Мэдэгдлийн тохиргоо' : 'Notification Settings';
  static String get helpContact =>
      isMongolian ? 'Тусламж & Холбоо барих' : 'Help & Contact';
  static String get logout => isMongolian ? 'Гарах' : 'Sign Out';
  static String get save => isMongolian ? 'Хадгалах' : 'Save';
  static String get email => isMongolian ? 'И-мэйл' : 'Email';
  static String get employerName =>
      isMongolian ? 'Ажил олгогчийн нэр' : 'Employer Name';
  static String get monthlyIncome =>
      isMongolian ? 'Сарын орлого (₮)' : 'Monthly Income (₮)';
  static String get homeAddress => isMongolian ? 'Гэрийн хаяг' : 'Home Address';
  static String get employmentType =>
      isMongolian ? 'Ажлын төрөл' : 'Employment Type';
  static String get currentPassword =>
      isMongolian ? 'Одоогийн нууц үг' : 'Current Password';
  static String get newPassword =>
      isMongolian ? 'Шинэ нууц үг' : 'New Password';
  static String get confirmPassword =>
      isMongolian ? 'Нууц үг давтах' : 'Confirm Password';
  static String get passwordMismatch =>
      isMongolian ? 'Нууц үг таарахгүй байна' : 'Passwords do not match';
  static String get passwordSaved => isMongolian
      ? 'Нууц үг амжилттай солигдлоо!'
      : 'Password changed successfully!';
  static String get passwordWeak => isMongolian ? 'Сул' : 'Weak';
  static String get passwordMedium => isMongolian ? 'Дунд' : 'Medium';
  static String get passwordStrong => isMongolian ? 'Хүчтэй' : 'Strong';
  static String get passwordHint => isMongolian
      ? 'Аюулгүй байдлын үүднээс нууц үгээ тогтмол солиорой.'
      : 'For your security, change your password regularly.';
  static String get langToggle => isMongolian ? 'EN' : 'МН';
}

void _showMsg(BuildContext context, String msg, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    backgroundColor: isError ? _T.error : _T.success,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    margin: const EdgeInsets.all(16),
  ));
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _GlassCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F1E3A), Color(0xFF070E1D)]),
          border: Border.all(color: _T.border),
          boxShadow: [
            BoxShadow(color: _T.neon.withOpacity(0.06), blurRadius: 40),
            BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 12)),
          ],
        ),
        child: Column(children: [
          Container(
            height: 1,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              gradient: LinearGradient(colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.08),
                Colors.transparent
              ]),
            ),
          ),
          Padding(padding: padding ?? const EdgeInsets.all(20), child: child),
        ]),
      );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final bool isLast;
  const _InfoRow(
      {required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            Text(label, style: const TextStyle(fontSize: 13, color: _T.txt2)),
            const Spacer(),
            Text(value,
                style: const TextStyle(
                    fontSize: 13, color: _T.txt1, fontWeight: FontWeight.w600)),
          ]),
        ),
        if (!isLast) Divider(color: _T.border.withOpacity(0.5), height: 1),
      ]);
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool isLast;
  const _MenuRow(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.iconColor,
      this.isLast = false});

  @override
  Widget build(BuildContext context) => Column(children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: (iconColor ?? _T.neon).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: (iconColor ?? _T.neon).withOpacity(0.2))),
                child: Icon(icon, size: 17, color: iconColor ?? _T.neonSoft),
              ),
              const SizedBox(width: 14),
              Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          fontSize: 14,
                          color: _T.txt1,
                          fontWeight: FontWeight.w500))),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 13, color: _T.txt3),
            ]),
          ),
        ),
        if (!isLast) Divider(color: _T.border.withOpacity(0.4), height: 1),
      ]);
}

class _DarkField extends StatefulWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode, nextFocusNode;
  final VoidCallback? onSubmitted;
  final TextInputAction? textInputAction;

  const _DarkField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.onChanged,
    this.focusNode,
    this.nextFocusNode,
    this.onSubmitted,
    this.textInputAction,
  });

  @override
  State<_DarkField> createState() => _DarkFieldState();
}

class _DarkFieldState extends State<_DarkField> {
  late FocusNode _node;

  @override
  void initState() {
    super.initState();
    _node = widget.focusNode ?? FocusNode();
    _node.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _node.dispose();
    super.dispose();
  }

  bool get _focused => _node.hasFocus;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _T.txt3,
                  letterSpacing: 1.2)),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: _focused ? const Color(0xFF0D1E3D) : _T.surface,
              border: Border.all(
                  color: _focused ? _T.neon.withOpacity(0.6) : _T.border,
                  width: _focused ? 1.5 : 1),
              boxShadow: _focused
                  ? [
                      BoxShadow(
                          color: _T.neon.withOpacity(0.12), blurRadius: 16)
                    ]
                  : [],
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _node,
              obscureText: widget.obscure,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              maxLines: widget.obscure ? 1 : widget.maxLines,
              onChanged: widget.onChanged,
              textInputAction: widget.textInputAction ?? TextInputAction.next,
              onSubmitted: (_) {
                if (widget.nextFocusNode != null)
                  widget.nextFocusNode!.requestFocus();
                else
                  widget.onSubmitted?.call();
              },
              style: const TextStyle(
                  color: _T.txt1, fontSize: 14, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: const TextStyle(color: _T.txt3, fontSize: 13),
                prefixIcon: Icon(widget.icon,
                    color: _focused ? _T.neonSoft : _T.txt3, size: 18),
                suffixIcon: widget.suffix,
                filled: true,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      );
}

Widget _sectionLabel(String title, IconData icon) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [_T.neon, _T.purple],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 15, color: _T.neonSoft),
        const SizedBox(width: 6),
        Text(title,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _T.neonSoft,
                letterSpacing: 0.5)),
      ]),
    );

// ═══════════════════════════════════════════════════════════════
// ПРОФАЙЛ ДЭЛГЭЦ
// ═══════════════════════════════════════════════════════════════
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  ProfileModel? _profile;
  bool _loading = true, _uploading = false;
  String? _avatarUrl;
  late AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat();
    _load();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final p = await SupabaseService.getProfile();
      if (mounted)
        setState(() {
          _profile = p;
          _avatarUrl = p?.avatarUrl;
          _loading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final picked =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked == null) return;
      setState(() => _uploading = true);
      final bytes = await picked.readAsBytes();
      final ext = picked.name.split('.').last;
      final url =
          await SupabaseService.uploadAvatar(bytes: bytes, extension: ext);
      if (mounted) {
        setState(() {
          _avatarUrl = url;
          _uploading = false;
        });
        _showMsg(
            context,
            AppLocalizations.isMongolian
                ? 'Зураг шинэчлэгдлээ!'
                : 'Photo updated!');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _uploading = false);
        _showMsg(
            context,
            AppLocalizations.isMongolian
                ? 'Зураг оруулахад алдаа гарлаа'
                : 'Failed to upload photo',
            isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      body: AnimatedBuilder(
        animation: _bgCtrl,
        builder: (_, __) => Stack(children: [
          Positioned.fill(
              child: CustomPaint(
                  painter: _SimpleBgPainter(_bgCtrl.value * 2 * math.pi))),
          SafeArea(
              child: Column(children: [
            _buildAppBar(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _T.neon))
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: _T.neon,
                      backgroundColor: _T.glass,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                        child: Column(children: [
                          _buildAvatar(),
                          const SizedBox(height: 12),
                          _buildName(),
                          const SizedBox(height: 20),
                          _buildScoreCard(),
                          const SizedBox(height: 20),
                          _buildInfoCard(),
                          const SizedBox(height: 16),
                          _buildMenuCard(),
                          const SizedBox(height: 16),
                          _buildLogoutBtn(),
                        ]),
                      ),
                    ),
            ),
          ])),
        ]),
      ),
    );
  }

  Widget _buildAppBar() => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
        decoration: BoxDecoration(
            color: _T.surface.withOpacity(0.8),
            border:
                Border(bottom: BorderSide(color: _T.border.withOpacity(0.5)))),
        child: Row(children: [
          ShaderMask(
            shaderCallback: (b) =>
                const LinearGradient(colors: [_T.neon, _T.purple])
                    .createShader(b),
            child: Text(AppLocalizations.profile,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3)),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() =>
                AppLocalizations.isMongolian = !AppLocalizations.isMongolian),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: _T.glass,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _T.border)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.language_rounded, size: 13, color: _T.txt2),
                const SizedBox(width: 4),
                Text(AppLocalizations.langToggle,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _T.txt2)),
              ]),
            ),
          ),
        ]),
      );

  Widget _buildAvatar() => GestureDetector(
        onTap: _pickPhoto,
        child: Stack(alignment: Alignment.bottomRight, children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [_T.neon, _T.purple]),
                boxShadow: [
                  BoxShadow(
                      color: _T.neon.withOpacity(0.35),
                      blurRadius: 24,
                      spreadRadius: 2)
                ]),
            child: Padding(
              padding: const EdgeInsets.all(2.5),
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _T.glass,
                    image: _avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(_avatarUrl!), fit: BoxFit.cover)
                        : null),
                child: _uploading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : _avatarUrl == null
                        ? Center(
                            child: Text(
                                _profile != null &&
                                        _profile!.firstName.isNotEmpty
                                    ? _profile!.firstName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800)))
                        : null,
              ),
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [_T.neon, _T.purple]),
                boxShadow: [
                  BoxShadow(color: _T.neon.withOpacity(0.4), blurRadius: 8)
                ]),
            child: const Icon(Icons.camera_alt_rounded,
                color: Colors.white, size: 14),
          ),
        ]),
      );

  Widget _buildName() => Column(children: [
        Text(_profile?.fullName ?? '—',
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _T.txt1,
                letterSpacing: -0.3)),
        const SizedBox(height: 4),
        Text(_profile?.phone ?? '—',
            style: const TextStyle(fontSize: 13, color: _T.txt2)),
        if (_profile?.isVerified == true) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: _T.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _T.success.withOpacity(0.3))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.verified_rounded, color: _T.success, size: 14),
              const SizedBox(width: 4),
              Text(AppLocalizations.verified,
                  style: const TextStyle(
                      fontSize: 11,
                      color: _T.success,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
        ],
      ]);

  Widget _buildScoreCard() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F2A5A), Color(0xFF1D4ED8)]),
          border: Border.all(color: _T.neon.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
                color: _T.neon.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 8))
          ],
        ),
        child: Column(children: [
          Container(
              height: 1,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.2),
                Colors.transparent
              ]))),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _ScoreItem(
                label: AppLocalizations.creditScore,
                value: '${_profile?.creditScore ?? 0}',
                suffix: '/850',
                icon: Icons.star_rounded,
                color: _T.warning),
            Container(width: 1, height: 44, color: Colors.white24),
            _ScoreItem(
                label: AppLocalizations.grade,
                value: _profile?.creditScoreLabel ?? '—',
                icon: Icons.emoji_events_rounded,
                color: _T.cyan),
            Container(width: 1, height: 44, color: Colors.white24),
            _ScoreItem(
                label: AppLocalizations.income,
                value:
                    AppUtils.formatCurrencyShort(_profile?.monthlyIncome ?? 0),
                icon: Icons.account_balance_wallet_rounded,
                color: _T.success),
          ]),
        ]),
      );

  Widget _buildInfoCard() => _GlassCard(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionLabel(AppLocalizations.personalInfo, Icons.person_rounded),
          _InfoRow(
              label: AppLocalizations.register,
              value: _profile?.registerNumber ?? '—'),
          _InfoRow(
              label: AppLocalizations.employment,
              value: AppUtils.getEmploymentTypeLabel(_profile?.employmentType)),
          _InfoRow(
              label: AppLocalizations.employer,
              value: _profile?.employerName ?? '—',
              isLast: true),
        ]),
      );

  Widget _buildMenuCard() => _GlassCard(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionLabel(AppLocalizations.settings, Icons.settings_rounded),
          _MenuRow(
            icon: Icons.edit_rounded,
            label: AppLocalizations.editProfile,
            onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditProfileScreen()))
                .then((_) => _load()),
          ),
          _MenuRow(
            icon: Icons.lock_reset_rounded,
            label: AppLocalizations.changePassword,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ChangePasswordScreen())),
          ),
          _MenuRow(
            icon: Icons.notifications_rounded,
            label: AppLocalizations.notificationSettings,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotificationSettingsScreen())),
          ),
          _MenuRow(
            icon: Icons.palette_rounded,
            label:
                AppLocalizations.isMongolian ? 'Гадаад байдал' : 'Appearance',
            iconColor: _T.purple,
            // ══ ЗАСВАР: шууд AppearanceScreen дуудна — Provider глобал байна ══
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppearanceScreen()),
            ),
          ),
          _MenuRow(
            icon: Icons.help_rounded,
            label: AppLocalizations.helpContact,
            iconColor: _T.cyan,
            isLast: true,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const HelpContactScreen())),
          ),
        ]),
      );

  Widget _buildLogoutBtn() => GestureDetector(
        onTap: () async {
          await SupabaseService.signOut();
          if (mounted)
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => LoginScreen()), (_) => false);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
              color: _T.error.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _T.error.withOpacity(0.3))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.logout_rounded,
                color: _T.error.withOpacity(0.9), size: 18),
            const SizedBox(width: 8),
            Text(AppLocalizations.logout,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _T.error.withOpacity(0.9))),
          ]),
        ),
      );
}

class _SimpleBgPainter extends CustomPainter {
  final double t;
  _SimpleBgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0x073B82F6)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 56)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    for (double y = 0; y < size.height; y += 56)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    final glow = Paint()..style = PaintingStyle.fill;
    final dots = <List<dynamic>>[
      [0.1, 0.1, _T.neon, 0.35],
      [0.9, 0.15, _T.purple, 0.28],
      [0.05, 0.6, _T.cyan, 0.25],
      [0.92, 0.55, _T.neon, 0.28]
    ];
    for (final d in dots) {
      final ox = math.sin(t + (d[0] as double) * 5) * 15;
      final oy = math.cos(t * 0.8 + (d[1] as double) * 4) * 12;
      final x = (d[0] as double) * size.width + ox;
      final y = (d[1] as double) * size.height + oy;
      final c = d[2] as Color;
      final op = d[3] as double;
      glow.shader =
          RadialGradient(colors: [c.withOpacity(op * 0.22), c.withOpacity(0)])
              .createShader(Rect.fromCircle(center: Offset(x, y), radius: 150));
      canvas.drawCircle(Offset(x, y), 150, glow);
    }
  }

  @override
  bool shouldRepaint(_SimpleBgPainter old) => old.t != t;
}

class _ScoreItem extends StatelessWidget {
  final String label, value, suffix;
  final IconData icon;
  final Color color;
  const _ScoreItem(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color,
      this.suffix = ''});

  @override
  Widget build(BuildContext context) => Column(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 6),
        RichText(
            text: TextSpan(
          text: value,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
          children: [
            if (suffix.isNotEmpty)
              TextSpan(
                  text: suffix,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 11))
          ],
        )),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
                fontWeight: FontWeight.w600)),
      ]);
}

// ═══════════════════════════════════════════════════════════════
// МЭДЭЭЛЭЛ ЗАСАХ ДЭЛГЭЦ
// ═══════════════════════════════════════════════════════════════
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _lastNameCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _employerCtrl = TextEditingController();
  final _incomeCtrl = TextEditingController();
  final _emergNameCtrl = TextEditingController();
  final _emergPhoneCtrl = TextEditingController();
  final _lastNameFocus = FocusNode();
  final _firstNameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _employerFocus = FocusNode();
  final _incomeFocus = FocusNode();
  final _emergNameFocus = FocusNode();
  final _emergPhoneFocus = FocusNode();
  String? _employmentType;
  bool _loading = false, _loadingProfile = true;

  List<Map<String, String>> get _empTypes => [
        {
          'value': 'employee',
          'label': AppLocalizations.isMongolian ? 'Ажилтан' : 'Employee'
        },
        {
          'value': 'self_employed',
          'label':
              AppLocalizations.isMongolian ? 'Өөрөө ажиллагч' : 'Self-employed'
        },
        {
          'value': 'business_owner',
          'label': AppLocalizations.isMongolian
              ? 'Бизнес эзэмшигч'
              : 'Business Owner'
        },
      ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final p = await SupabaseService.getProfile();
      if (mounted && p != null) {
        _lastNameCtrl.text = p.lastName ?? '';
        _firstNameCtrl.text = p.firstName;
        _phoneCtrl.text = p.phone ?? '';
        _emailCtrl.text = p.email ?? '';
        _addressCtrl.text = p.address ?? '';
        _employerCtrl.text = p.employerName ?? '';
        _incomeCtrl.text = p.monthlyIncome?.toString() ?? '';
        _emergNameCtrl.text = p.emergencyContactName ?? '';
        _emergPhoneCtrl.text = p.emergencyContactPhone ?? '';
        _employmentType = p.employmentType;
        setState(() => _loadingProfile = false);
      } else {
        if (mounted) setState(() => _loadingProfile = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _lastNameCtrl,
      _firstNameCtrl,
      _phoneCtrl,
      _emailCtrl,
      _addressCtrl,
      _employerCtrl,
      _incomeCtrl,
      _emergNameCtrl,
      _emergPhoneCtrl
    ]) c.dispose();
    for (final f in [
      _lastNameFocus,
      _firstNameFocus,
      _phoneFocus,
      _emailFocus,
      _addressFocus,
      _employerFocus,
      _incomeFocus,
      _emergNameFocus,
      _emergPhoneFocus
    ]) f.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_lastNameCtrl.text.isEmpty || _firstNameCtrl.text.isEmpty) {
      _showMsg(
          context,
          AppLocalizations.isMongolian
              ? 'Овог нэрийг бөглөнө үү'
              : 'Please enter your name',
          isError: true);
      return;
    }
    setState(() => _loading = true);
    try {
      await SupabaseService.updateProfile({
        'last_name': _lastNameCtrl.text.trim(),
        'first_name': _firstNameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'employer_name': _employerCtrl.text.trim(),
        'monthly_income': double.tryParse(_incomeCtrl.text) ?? 0,
        'emergency_contact_name': _emergNameCtrl.text.trim(),
        'emergency_contact_phone': _emergPhoneCtrl.text.trim(),
        'employment_type': _employmentType,
      });
      if (mounted) {
        _showMsg(
            context,
            AppLocalizations.isMongolian
                ? 'Мэдээлэл амжилттай хадгалагдлаа!'
                : 'Profile updated!');
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted)
        _showMsg(
            context,
            AppLocalizations.isMongolian
                ? 'Хадгалахад алдаа гарлаа'
                : 'Failed to save',
            isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      appBar: _darkAppBar(AppLocalizations.editProfile),
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator(color: _T.neon))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GlassCard(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          _sectionLabel(
                              AppLocalizations.isMongolian
                                  ? 'Хувийн мэдээлэл'
                                  : 'Personal Info',
                              Icons.person_rounded),
                          _DarkField(
                              controller: _lastNameCtrl,
                              focusNode: _lastNameFocus,
                              nextFocusNode: _firstNameFocus,
                              label: AppLocalizations.isMongolian
                                  ? 'Овог'
                                  : 'Last Name',
                              hint: AppLocalizations.isMongolian
                                  ? 'Овгоо оруулна уу'
                                  : 'Enter last name',
                              icon: Icons.person_outline_rounded),
                          const SizedBox(height: 14),
                          _DarkField(
                              controller: _firstNameCtrl,
                              focusNode: _firstNameFocus,
                              nextFocusNode: _phoneFocus,
                              label: AppLocalizations.isMongolian
                                  ? 'Нэр'
                                  : 'First Name',
                              hint: AppLocalizations.isMongolian
                                  ? 'Нэрээ оруулна уу'
                                  : 'Enter first name',
                              icon: Icons.person_outline_rounded),
                        ])),
                    const SizedBox(height: 14),
                    _GlassCard(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          _sectionLabel(
                              AppLocalizations.isMongolian
                                  ? 'Холбоо барих'
                                  : 'Contact',
                              Icons.phone_rounded),
                          _DarkField(
                              controller: _phoneCtrl,
                              focusNode: _phoneFocus,
                              nextFocusNode: _emailFocus,
                              label: AppLocalizations.isMongolian
                                  ? 'Утасны дугаар'
                                  : 'Phone',
                              hint: '8 оронтой дугаар',
                              icon: Icons.phone_iphone_rounded,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(8)
                              ]),
                          const SizedBox(height: 14),
                          _DarkField(
                              controller: _emailCtrl,
                              focusNode: _emailFocus,
                              nextFocusNode: _addressFocus,
                              label: AppLocalizations.isMongolian
                                  ? 'И-мэйл / Gmail'
                                  : 'Email / Gmail',
                              hint: 'example@gmail.com',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 14),
                          _DarkField(
                              controller: _addressCtrl,
                              focusNode: _addressFocus,
                              nextFocusNode: _employerFocus,
                              label: AppLocalizations.homeAddress,
                              hint: AppLocalizations.isMongolian
                                  ? 'Дүүрэг, хороо, байр, тоот'
                                  : 'District, khoroo, building, apt',
                              icon: Icons.location_on_outlined,
                              maxLines: 2),
                        ])),
                    const SizedBox(height: 14),
                    _GlassCard(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          _sectionLabel(
                              AppLocalizations.isMongolian
                                  ? 'Ажлын мэдээлэл'
                                  : 'Employment',
                              Icons.work_rounded),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    AppLocalizations.employmentType
                                        .toUpperCase(),
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: _T.txt3,
                                        letterSpacing: 1.2)),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                      color: _T.surface,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: _T.border)),
                                  child: DropdownButtonFormField<String>(
                                    value: _employmentType,
                                    dropdownColor: _T.glassHi,
                                    style: const TextStyle(
                                        color: _T.txt1, fontSize: 14),
                                    icon: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: _T.txt3),
                                    decoration: const InputDecoration(
                                        prefixIcon: Icon(Icons.work_outline,
                                            size: 18, color: _T.txt3),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        filled: true,
                                        fillColor: Colors.transparent,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 14)),
                                    items: _empTypes
                                        .map((t) => DropdownMenuItem(
                                            value: t['value'],
                                            child: Text(t['label']!,
                                                style: const TextStyle(
                                                    color: _T.txt1))))
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => _employmentType = v),
                                  ),
                                ),
                              ]),
                          const SizedBox(height: 14),
                          _DarkField(
                              controller: _employerCtrl,
                              focusNode: _employerFocus,
                              nextFocusNode: _incomeFocus,
                              label: AppLocalizations.employerName,
                              hint: AppLocalizations.isMongolian
                                  ? 'Байгууллагын нэр'
                                  : 'Company name',
                              icon: Icons.business_outlined),
                          const SizedBox(height: 14),
                          _DarkField(
                              controller: _incomeCtrl,
                              focusNode: _incomeFocus,
                              nextFocusNode: _emergNameFocus,
                              label: AppLocalizations.monthlyIncome,
                              hint: '0',
                              icon: Icons.attach_money_rounded,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ]),
                        ])),
                    const SizedBox(height: 14),
                    _GlassCard(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          _sectionLabel(
                              AppLocalizations.isMongolian
                                  ? 'Ойр дотны хүний мэдээлэл'
                                  : 'Emergency Contact',
                              Icons.people_rounded),
                          _DarkField(
                              controller: _emergNameCtrl,
                              focusNode: _emergNameFocus,
                              nextFocusNode: _emergPhoneFocus,
                              label: AppLocalizations.isMongolian
                                  ? 'Овог нэр'
                                  : 'Full name',
                              hint: AppLocalizations.isMongolian
                                  ? 'Нэрийг оруулна уу'
                                  : 'Enter full name',
                              icon: Icons.people_outline),
                          const SizedBox(height: 14),
                          _DarkField(
                              controller: _emergPhoneCtrl,
                              focusNode: _emergPhoneFocus,
                              onSubmitted: _save,
                              label: AppLocalizations.isMongolian
                                  ? 'Утасны дугаар'
                                  : 'Phone number',
                              hint: '8 оронтой дугаар',
                              icon: Icons.phone_in_talk_outlined,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(8)
                              ],
                              textInputAction: TextInputAction.done),
                        ])),
                    const SizedBox(height: 24),
                    _saveBtn(_save, _loading, AppLocalizations.save),
                    const SizedBox(height: 40),
                  ]),
            ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// НУУЦ ҮГ СОЛИХ ДЭЛГЭЦ
// ═══════════════════════════════════════════════════════════════
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _curCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confCtrl = TextEditingController();
  final _curFocus = FocusNode();
  final _newFocus = FocusNode();
  final _confFocus = FocusNode();
  bool _showCur = false, _showNew = false, _showConf = false, _loading = false;
  double _strength = 0;
  String _strengthLabel = '';
  Color _strengthColor = _T.error;

  void _checkStrength(String val) {
    int s = 0;
    if (val.length >= 8) s++;
    if (val.contains(RegExp(r'[A-Z]'))) s++;
    if (val.contains(RegExp(r'[0-9]'))) s++;
    if (val.contains(RegExp(r'[^A-Za-z0-9]'))) s++;
    setState(() {
      if (s <= 1) {
        _strength = 0.25;
        _strengthLabel = AppLocalizations.passwordWeak;
        _strengthColor = _T.error;
      } else if (s <= 2) {
        _strength = 0.60;
        _strengthLabel = AppLocalizations.passwordMedium;
        _strengthColor = _T.warning;
      } else {
        _strength = 1.0;
        _strengthLabel = AppLocalizations.passwordStrong;
        _strengthColor = _T.success;
      }
    });
  }

  Future<void> _save() async {
    if (_newCtrl.text != _confCtrl.text) {
      _showMsg(context, AppLocalizations.passwordMismatch, isError: true);
      return;
    }
    setState(() => _loading = true);
    try {
      await SupabaseService.changePassword(
          currentPassword: _curCtrl.text, newPassword: _newCtrl.text);
      if (mounted) {
        _showMsg(context, AppLocalizations.passwordSaved);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showMsg(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    for (final c in [_curCtrl, _newCtrl, _confCtrl]) c.dispose();
    for (final f in [_curFocus, _newFocus, _confFocus]) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      appBar: _darkAppBar(AppLocalizations.changePassword),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: _T.neon.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _T.neon.withOpacity(0.2))),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded,
                  color: _T.neonSoft, size: 18),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(AppLocalizations.passwordHint,
                      style: const TextStyle(fontSize: 12, color: _T.txt2))),
            ]),
          ),
          const SizedBox(height: 20),
          _GlassCard(
              child: Column(children: [
            _DarkField(
                controller: _curCtrl,
                focusNode: _curFocus,
                nextFocusNode: _newFocus,
                label: AppLocalizations.currentPassword,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: !_showCur,
                suffix: _eyeBtn(
                    () => setState(() => _showCur = !_showCur), _showCur)),
            const SizedBox(height: 14),
            _DarkField(
                controller: _newCtrl,
                focusNode: _newFocus,
                nextFocusNode: _confFocus,
                label: AppLocalizations.newPassword,
                hint: '••••••••',
                icon: Icons.lock_reset_outlined,
                obscure: !_showNew,
                onChanged: _checkStrength,
                suffix: _eyeBtn(
                    () => setState(() => _showNew = !_showNew), _showNew)),
            if (_newCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                      value: _strength,
                      minHeight: 4,
                      backgroundColor: _T.border,
                      valueColor: AlwaysStoppedAnimation(_strengthColor))),
              const SizedBox(height: 4),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(_strengthLabel,
                      style: TextStyle(
                          fontSize: 11,
                          color: _strengthColor,
                          fontWeight: FontWeight.w700))),
            ],
            const SizedBox(height: 14),
            _DarkField(
                controller: _confCtrl,
                focusNode: _confFocus,
                onSubmitted: _save,
                label: AppLocalizations.confirmPassword,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: !_showConf,
                textInputAction: TextInputAction.done,
                suffix: _eyeBtn(
                    () => setState(() => _showConf = !_showConf), _showConf)),
            if (_confCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(children: [
                Icon(
                    _newCtrl.text == _confCtrl.text
                        ? Icons.check_circle_outline_rounded
                        : Icons.cancel_outlined,
                    size: 13,
                    color: _newCtrl.text == _confCtrl.text
                        ? _T.success
                        : _T.error),
                const SizedBox(width: 4),
                Text(
                    _newCtrl.text == _confCtrl.text
                        ? (AppLocalizations.isMongolian
                            ? 'Нууц үг таарч байна'
                            : 'Passwords match')
                        : AppLocalizations.passwordMismatch,
                    style: TextStyle(
                        fontSize: 11,
                        color: _newCtrl.text == _confCtrl.text
                            ? _T.success
                            : _T.error)),
              ]),
            ],
          ])),
          const SizedBox(height: 24),
          _saveBtn(_save, _loading, AppLocalizations.save),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  Widget _eyeBtn(VoidCallback onTap, bool show) => GestureDetector(
      onTap: onTap,
      child: Icon(
          show ? Icons.visibility_rounded : Icons.visibility_off_rounded,
          size: 18,
          color: _T.txt3));
}

// ═══════════════════════════════════════════════════════════════
// МЭДЭГДЛИЙН ТОХИРГОО
// ═══════════════════════════════════════════════════════════════
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});
  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _paymentReminder = true,
      _loanStatus = true,
      _promotions = false,
      _overdue = true,
      _appUpdates = false;

  Widget _toggle(
          {required IconData icon,
          required String title,
          required String subtitle,
          required bool value,
          required ValueChanged<bool> onChanged,
          Color? iconColor}) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF0F1E3A), Color(0xFF070E1D)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _T.border)),
        child: Row(children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: (iconColor ?? _T.neon).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                      color: (iconColor ?? _T.neon).withOpacity(0.2))),
              child: Icon(icon, color: iconColor ?? _T.neonSoft, size: 19)),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _T.txt1)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(fontSize: 11, color: _T.txt2)),
              ])),
          Switch(
              value: value,
              onChanged: onChanged,
              activeColor: _T.neon,
              activeTrackColor: _T.neon.withOpacity(0.3),
              inactiveThumbColor: _T.txt3,
              inactiveTrackColor: _T.border),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final mn = AppLocalizations.isMongolian;
    return Scaffold(
      backgroundColor: _T.bg,
      appBar: _darkAppBar(AppLocalizations.notificationSettings),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          _toggle(
              icon: Icons.alarm_rounded,
              title: mn ? 'Төлбөрийн сануулга' : 'Payment Reminder',
              subtitle: mn
                  ? 'Төлбөрийн хугацаа болоход мэдэгдэл авах'
                  : 'Get notified before payment due',
              value: _paymentReminder,
              onChanged: (v) => setState(() => _paymentReminder = v)),
          _toggle(
              icon: Icons.credit_score_rounded,
              title: mn ? 'Зээлийн төлөв' : 'Loan Status',
              subtitle: mn
                  ? 'Зээлийн хүсэлтийн шийдвэр гарахад мэдэгдэл авах'
                  : 'Get notified on loan updates',
              value: _loanStatus,
              onChanged: (v) => setState(() => _loanStatus = v)),
          _toggle(
              icon: Icons.warning_amber_rounded,
              title: mn ? 'Хугацаа хэтэрсэн' : 'Overdue Alert',
              subtitle: mn
                  ? 'Хугацаа хэтэрсэн төлбөрийн мэдэгдэл'
                  : 'Alert when payment is overdue',
              value: _overdue,
              iconColor: _T.error,
              onChanged: (v) => setState(() => _overdue = v)),
          _toggle(
              icon: Icons.local_offer_rounded,
              title: mn ? 'Урамшуулал & Санал' : 'Promotions & Offers',
              subtitle: mn
                  ? 'Тусгай санал болон урамшууллын мэдээлэл'
                  : 'Special offers and promotions',
              value: _promotions,
              iconColor: _T.warning,
              onChanged: (v) => setState(() => _promotions = v)),
          _toggle(
              icon: Icons.system_update_rounded,
              title: mn ? 'Аппын шинэчлэлт' : 'App Updates',
              subtitle: mn
                  ? 'Шинэ хувилбарын талаар мэдэгдэл авах'
                  : 'Get notified about new versions',
              value: _appUpdates,
              onChanged: (v) => setState(() => _appUpdates = v)),
          const SizedBox(height: 16),
          _saveBtn(() {
            _showMsg(
                context, mn ? 'Тохиргоо хадгалагдлаа!' : 'Settings saved!');
            Navigator.pop(context);
          }, false, AppLocalizations.save),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ТУСЛАМЖ & ХОЛБОО БАРИХ
// ═══════════════════════════════════════════════════════════════
class HelpContactScreen extends StatefulWidget {
  const HelpContactScreen({super.key});
  @override
  State<HelpContactScreen> createState() => _HelpContactScreenState();
}

class _HelpContactScreenState extends State<HelpContactScreen> {
  final _msgCtrl = TextEditingController();
  bool _sending = false;
  int _expanded = -1;

  final _faqs = [
    {
      'q': 'Зээл хэрхэн авах вэ?',
      'a':
          '"Зээл авах" товчийг дарж, шаардлагатай мэдээллийг бөглөж, хүсэлт илгээнэ үү. Бид 24 цагийн дотор хариу өгнө.'
    },
    {
      'q': 'Төлбөрийг хэрхэн хийх вэ?',
      'a':
          'Доорх "Зээл" таб руу орж, идэвхтэй зээлээ сонгоод "Төлбөр хийх" товчийг дарна уу.'
    },
    {
      'q': 'Зээлийн оноо яаж нэмэгдэх вэ?',
      'a':
          'Төлбөрөө хугацаандаа хийх, зээлийн дүнгийн хязгаарт хүрэхгүй байх, мэдээллээ бүрэн оруулах нь оноог нэмэгдүүлнэ.'
    },
    {
      'q': 'Нууц үгээ мартсан бол?',
      'a': 'Нэвтрэх дэлгэц дээрх "Нууц үг мартсан?" товчийг дарж шинэчлэнэ үү.'
    },
    {
      'q': 'Хэдэн зээл нэгэн зэрэг авч болох вэ?',
      'a':
          'Зээлийн оноо болон орлогоос хамааран нэгэн зэрэг 1-3 зээл авах боломжтой.'
    },
  ];

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_msgCtrl.text.trim().isEmpty) {
      _showMsg(
          context,
          AppLocalizations.isMongolian
              ? 'Мессеж оруулна уу'
              : 'Please enter message',
          isError: true);
      return;
    }
    setState(() => _sending = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _sending = false);
      _msgCtrl.clear();
      _showMsg(
          context,
          AppLocalizations.isMongolian
              ? 'Мессеж илгээгдлээ!'
              : 'Message sent!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mn = AppLocalizations.isMongolian;
    return Scaffold(
      backgroundColor: _T.bg,
      appBar: _darkAppBar(AppLocalizations.helpContact),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF0F2A5A), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _T.neon.withOpacity(0.25)),
                boxShadow: [
                  BoxShadow(color: _T.neon.withOpacity(0.15), blurRadius: 24)
                ]),
            child: Column(children: [
              _contactTile(
                  Icons.phone_rounded, mn ? 'Утас' : 'Phone', '+976 7700-0000'),
              Divider(color: Colors.white24, height: 18),
              _contactTile(Icons.email_outlined, mn ? 'И-мэйл' : 'Email',
                  'support@zeel.mn'),
              Divider(color: Colors.white24, height: 18),
              _contactTile(
                  Icons.access_time_rounded,
                  mn ? 'Ажлын цаг' : 'Working Hours',
                  mn ? 'Да-Ба: 09:00 - 18:00' : 'Mon-Fri: 09:00 - 18:00'),
            ]),
          ),
          const SizedBox(height: 24),
          ShaderMask(
              shaderCallback: (b) =>
                  const LinearGradient(colors: [_T.neon, _T.purple])
                      .createShader(b),
              child: Text(mn ? 'Түгээмэл асуулт' : 'FAQ',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white))),
          const SizedBox(height: 12),
          ...List.generate(_faqs.length, (i) {
            final exp = _expanded == i;
            return GestureDetector(
              onTap: () => setState(() => _expanded = exp ? -1 : i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: exp
                            ? [const Color(0xFF0F2A5A), const Color(0xFF0A1628)]
                            : [
                                const Color(0xFF0F1E3A),
                                const Color(0xFF070E1D)
                              ]),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: exp ? _T.neon.withOpacity(0.4) : _T.border)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                            child: Text(_faqs[i]['q']!,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _T.txt1))),
                        Icon(
                            exp
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: exp ? _T.neonSoft : _T.txt3,
                            size: 20)
                      ]),
                      if (exp) ...[
                        const SizedBox(height: 10),
                        Text(_faqs[i]['a']!,
                            style: const TextStyle(
                                fontSize: 12, color: _T.txt2, height: 1.6))
                      ],
                    ]),
              ),
            );
          }),
          const SizedBox(height: 24),
          ShaderMask(
              shaderCallback: (b) =>
                  const LinearGradient(colors: [_T.neon, _T.purple])
                      .createShader(b),
              child: Text(mn ? 'Мессеж илгээх' : 'Send Message',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white))),
          const SizedBox(height: 12),
          _GlassCard(
              child: _DarkField(
                  controller: _msgCtrl,
                  label: mn
                      ? 'Таны асуулт эсвэл санал'
                      : 'Your question or feedback',
                  hint: mn ? 'Энд бичнэ үү...' : 'Write here...',
                  icon: Icons.message_outlined,
                  maxLines: 4)),
          const SizedBox(height: 16),
          _saveBtn(_sendMessage, _sending, mn ? 'Илгээх' : 'Send',
              icon: Icons.send_rounded),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  Widget _contactTile(IconData icon, String label, String value) =>
      Row(children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 11)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ]),
      ]);
}

// ═══════════════════════════════════════════════════════════════
// МЭДЭГДЭЛ ДЭЛГЭЦ
// ═══════════════════════════════════════════════════════════════
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final n = await SupabaseService.getNotifications();
      if (mounted)
        setState(() {
          _notifs = n;
          _loading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  IconData _icon(String? t) {
    switch (t) {
      case 'payment_due':
        return Icons.alarm_rounded;
      case 'payment_received':
        return Icons.check_circle_rounded;
      case 'loan_approved':
        return Icons.thumb_up_rounded;
      case 'loan_rejected':
        return Icons.cancel_rounded;
      case 'overdue':
        return Icons.warning_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _color(String? t) {
    switch (t) {
      case 'payment_due':
        return _T.warning;
      case 'payment_received':
        return _T.success;
      case 'loan_approved':
        return _T.success;
      case 'loan_rejected':
        return _T.error;
      case 'overdue':
        return _T.error;
      default:
        return _T.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mn = AppLocalizations.isMongolian;
    return Scaffold(
      backgroundColor: _T.bg,
      appBar: _darkAppBar(mn ? 'Мэдэгдлүүд' : 'Notifications'),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _T.neon))
          : _notifs.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                          color: _T.glass,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _T.border)),
                      child: const Icon(Icons.notifications_none_rounded,
                          size: 34, color: _T.txt3)),
                  const SizedBox(height: 14),
                  Text(mn ? 'Мэдэгдэл байхгүй' : 'No notifications',
                      style: const TextStyle(fontSize: 14, color: _T.txt2)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifs.length,
                  itemBuilder: (_, i) {
                    final n = _notifs[i];
                    final isRead = n['is_read'] == true;
                    final c = _color(n['type']);
                    return GestureDetector(
                      onTap: () {
                        SupabaseService.markNotificationRead(n['id']);
                        setState(() => _notifs[i]['is_read'] = true);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: isRead
                                    ? [
                                        const Color(0xFF0F1E3A),
                                        const Color(0xFF070E1D)
                                      ]
                                    : [
                                        Color.lerp(
                                            const Color(0xFF0F1E3A), c, 0.08)!,
                                        const Color(0xFF070E1D)
                                      ]),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color:
                                    isRead ? _T.border : c.withOpacity(0.35))),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                      color: c.withOpacity(0.12),
                                      shape: BoxShape.circle),
                                  child: Icon(_icon(n['type']),
                                      color: c, size: 20)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(n['title'] ?? '',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: _T.txt1)),
                                    const SizedBox(height: 3),
                                    Text(n['body'] ?? '',
                                        style: const TextStyle(
                                            fontSize: 12, color: _T.txt2),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text(
                                        AppUtils.formatDateTime(
                                            DateTime.parse(n['created_at'])),
                                        style: const TextStyle(
                                            fontSize: 10, color: _T.txt3)),
                                  ])),
                              if (!isRead)
                                Container(
                                    width: 7,
                                    height: 7,
                                    margin: const EdgeInsets.only(top: 3),
                                    decoration: BoxDecoration(
                                        color: c, shape: BoxShape.circle)),
                            ]),
                      ),
                    );
                  },
                ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ДУНДЫН ТУСЛАХ ФУНКЦУУД
// ═══════════════════════════════════════════════════════════════
PreferredSizeWidget _darkAppBar(String title) => AppBar(
      backgroundColor: _T.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: Builder(
          builder: (ctx) => GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: _T.glass,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _T.border)),
                    child: const Icon(Icons.arrow_back_ios_rounded,
                        color: _T.txt2, size: 15)),
              )),
      title: Text(title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: _T.txt1)),
      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _T.border.withOpacity(0.5))),
    );

Widget _saveBtn(VoidCallback onTap, bool loading, String label,
        {IconData? icon}) =>
    GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: loading
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)]),
          color: loading ? _T.glass : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: loading
              ? []
              : [
                  BoxShadow(
                      color: _T.neon.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6))
                ],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (loading)
            const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
          else ...[
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 17),
              const SizedBox(width: 8)
            ],
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
          ],
        ]),
      ),
    );
