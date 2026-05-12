import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'loan_products_screen.dart';
import 'my_loans_screen.dart';
import 'ai_chat_screen.dart';
import 'profile_screen.dart';

// =============================================
// BOTTOM NAVIGATION WRAPPER
// =============================================
class MainNavigation extends StatefulWidget {
  final int initialIndex;
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  static const _bg = Color(0xFF12121D);
  static const _navBg = Color(0xFF1A1A2E);
  static const _purple = Color(0xFF8A2BE2);

  final List<Widget> _screens = [
    const HomeScreen(),
    const MyLoansScreen(),
    const LoanProductsScreen(),
    const AiChatScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: _navBg,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06), width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.grid_view_rounded,
                activeIcon: Icons.grid_view_rounded,
                index: 0,
                currentIndex: _currentIndex,
                onTap: _onTap,
              ),
              _NavItem(
                icon: Icons.credit_card_outlined,
                activeIcon: Icons.credit_card_rounded,
                index: 1,
                currentIndex: _currentIndex,
                onTap: _onTap,
              ),
              _CenterNavItem(
                isActive: _currentIndex == 2,
                onTap: () => _onTap(2),
              ),
              _NavItem(
                icon: Icons.auto_awesome_outlined,
                activeIcon: Icons.auto_awesome_rounded,
                index: 3,
                currentIndex: _currentIndex,
                onTap: _onTap,
                badge: true,
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                index: 4,
                currentIndex: _currentIndex,
                onTap: _onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(int index) => setState(() => _currentIndex = index);
}

// ── Энгийн nav item — текстгүй, зөвхөн icon ──────
class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final int index, currentIndex;
  final ValueChanged<int> onTap;
  final bool badge;

  static const _purple = Color(0xFF8A2BE2);

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? _purple.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  active ? activeIcon : icon,
                  color: active ? _purple : Colors.grey,
                  size: 24,
                ),
                if (badge && !active)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            // ── Идэвхтэй үед жижиг цэг харуулна ──
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: active ? 4 : 0,
              height: active ? 4 : 0,
              decoration: BoxDecoration(
                color: active ? _purple : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Голын том товч (Бүтээгдэхүүн) — текстгүй ────
class _CenterNavItem extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _CenterNavItem({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF8A2BE2), Color(0xFF4A00E0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFF6B21A8), Color(0xFF3730A3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8A2BE2).withOpacity(isActive ? 0.5 : 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.storefront_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}
