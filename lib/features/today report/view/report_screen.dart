import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/Core/Constants/app_colors.dart';
import 'package:library_managment/Core/Constants/app_text_styles.dart';
import 'package:library_managment/Core/Widgets/app_primary_button.dart';
import 'package:library_managment/features/today%20report/controller/report_controller.dart';
import 'package:library_managment/features/today%20report/widgets/account_breakdown_item.dart';
import 'package:library_managment/features/today%20report/widgets/report_stat_card.dart';


class ReportScreen extends GetView<ReportController> {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ReportController());
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          _ReportHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DateSelector(),
                  const SizedBox(height: 16),
                  _StatsGrid(),
                  const SizedBox(height: 24),
                  _AccountsBreakdown(),
                  const SizedBox(height: 24),
                  Obx(() => AppPrimaryButton(
                        label: '⬇ تصدير التقرير',
                        isLoading: controller.isLoading.value,
                        onTap: controller.exportReport,
                      )),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────
class _ReportHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 16,
        right: 16,
        left: 16,
      ),
      color: kBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: kPrimaryTextColor,
              size: 20,
            ),
          ),
          Text('تقرير اليوم', style: AppTextStyles.titleMedium),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

// ─── Date Selector ────────────────────────────────────────────
class _DateSelector extends GetView<ReportController> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.pickDate(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kDividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: kSecondaryTextColor,
              size: 18,
            ),
            Obx(() => Text(
                  controller.formattedDate,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: kPrimaryTextColor,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Stats Grid ───────────────────────────────────────────────
class _StatsGrid extends GetView<ReportController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          childAspectRatio: 1.4,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ReportStatCard(
              title: 'إجمالي الدفعات المستلمة',
              value: '₪ ${controller.totalPayments.value.toStringAsFixed(0)}',
              icon: Icons.credit_card_rounded,
              iconBgColor: kIconBgPayment,
              iconColor: kAccentColor,
            ),
            ReportStatCard(
              title: 'عدد العمليات',
              value: controller.totalOperations.value.toString(),
              icon: Icons.receipt_long_rounded,
              iconBgColor: const Color(0xffEEF2FF),
              iconColor: kPrimaryColor,
            ),
            ReportStatCard(
              title: 'إجمالي الحوالات الواصلة',
              value: '₪ ${controller.totalTransfers.value.toStringAsFixed(0)}',
              icon: Icons.swap_horiz_rounded,
              iconBgColor: kIconBgTransfer,
              iconColor: kSuccessColor,
            ),
            ReportStatCard(
              title: 'حوالات معلقة',
              value: controller.pendingTransfers.value.toString(),
              icon: Icons.warning_amber_rounded,
              iconBgColor: kIconBgWarning,
              iconColor: kPendingColor,
            ),
          ],
        ));
  }
}

// ─── Accounts Breakdown ───────────────────────────────────────
class _AccountsBreakdown extends GetView<ReportController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('توزيع حسب الحساب', style: AppTextStyles.titleMedium),
        const SizedBox(height: 12),
        Obx(() => Column(
              children: controller.accountsBreakdown
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AccountBreakdownItem(
                          item: item,
                          maxAmount: controller.maxAmount,
                        ),
                      ))
                  .toList(),
            )),
      ],
    );
  }
}