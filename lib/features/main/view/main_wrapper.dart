import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/features/payment/view/payments_screen.dart';
import 'package:library_managment/features/settings/view/settings_screen.dart';
import 'package:library_managment/features/transfers/view/transfers_screen.dart';
import '../controller/main_wrapper_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../home/view/home_screen.dart';


class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  static final List<Widget> _pages = [
    const HomeScreen(),
    const TransfersScreen(),
    const PaymentsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainWrapperController());

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Obx(() => _pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => _BottomNavBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
        ),
      ),
    );
  }
}

// ─── Bottom Nav Bar ───────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
    _NavItem(icon: Icons.swap_horiz_rounded, label: 'الحوالات'),
    _NavItem(icon: Icons.credit_card_rounded, label: 'المدفوعات'),
    _NavItem(icon: Icons.settings_rounded, label: 'الإعدادات'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(
              _items.length,
              (index) => Expanded(
                child: _NavBarItem(
                  item: _items[index],
                  isSelected: currentIndex == index,
                  onTap: () => onTap(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Nav Bar Item ─────────────────────────────────────────────
class _NavBarItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? kPrimaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              item.icon,
              color: isSelected ? kPrimaryColor : kSecondaryTextColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: AppTextStyles.caption.copyWith(
              color: isSelected ? kPrimaryColor : kSecondaryTextColor,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Nav Item Model ───────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}