import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/core/widgets/app_search_bar.dart';
import 'package:library_managment/core/widgets/empty_state.dart';
import '../controller/payments_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../widgets/payment_list_item.dart';

class PaymentsScreen extends GetView<PaymentsController> {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PaymentsController());
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          _PaymentsHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _FilterTabs(),
                  const SizedBox(height: 12),
                  AppSearchBar(
                    hint: 'ابحث باسم الزبون...',
                    onChanged: controller.onSearchChanged,
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _PaymentsList()),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addPayment),
        backgroundColor: kAccentColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: kWhiteColor, size: 28),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────
class _PaymentsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 16,
        right: 16,
        left: 16,
      ),
      color: kBackgroundColor,
      child: Text('سجل المدفوعات', style: AppTextStyles.titleMedium),
    );
  }
}

// ─── Filter Tabs ──────────────────────────────────────────────
class _FilterTabs extends GetView<PaymentsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          _FilterTab(
            label: 'اليوم',
            isSelected: controller.activeFilter.value == PaymentFilter.today,
            onTap: () => controller.onFilterChanged(PaymentFilter.today),
          ),
          const SizedBox(width: 8),
          _FilterTab(
            label: 'هذا الأسبوع',
            isSelected: controller.activeFilter.value == PaymentFilter.thisWeek,
            onTap: () => controller.onFilterChanged(PaymentFilter.thisWeek),
          ),
          const SizedBox(width: 8),
          _FilterTab(
            label: 'مخصص',
            isSelected: controller.activeFilter.value == PaymentFilter.custom,
            onTap: () => controller.onFilterChanged(PaymentFilter.custom),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : kCardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ],
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? kWhiteColor : kSecondaryTextColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ─── Payments List ────────────────────────────────────────────
class _PaymentsList extends GetView<PaymentsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.filteredPayments.isEmpty) {
        return const EmptyState(message: 'لا توجد مدفوعات بعد');
      }
      return ListView.separated(
        itemCount: controller.filteredPayments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, index) {
          final payment = controller.filteredPayments[index];
          return PaymentListItem(
            payment: payment,
            time: controller.formatTime(payment['createdAt']),
          );
        },
      );
    });
  }
}
