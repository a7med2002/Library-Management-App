import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/Core/Constants/app_colors.dart';
import 'package:library_managment/Core/Constants/app_text_styles.dart';
import 'package:library_managment/Core/Routes/app_routes.dart';
import 'package:library_managment/Core/Widgets/quick_action_button.dart';
import 'package:library_managment/Core/Widgets/summary_card.dart';
import 'package:library_managment/features/home/controller/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          _HomeHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _QuickActions(),
                  const SizedBox(height: 24),
                  _RecentTransactions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Home Header ─────────────────────────────────────────────
class _HomeHeader extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    final dateStr =
        '${days[now.weekday - 1]}، ${now.day} ${months[now.month - 1]} ${now.year}';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 24,
        right: 16,
        left: 16,
      ),
      decoration: const BoxDecoration(color: kPrimaryColor),
      child: Column(
        children: [
          // ── Row: Logo + Name | Date ──────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // التاريخ على اليسار
              Text(
                dateStr,
                style: AppTextStyles.caption.copyWith(
                  color: kWhiteColor.withOpacity(0.7),
                ),
              ),
              // الشعار + الاسم على اليمين
              Obx(
                () => Row(
                  children: [
                    Text(
                      'مرحباً، ${controller.employeeName.value} 👋',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: kWhiteColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // App Logo صغير
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: kWhiteColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Summary Cards داخل الهيدر ────────────────
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'إجمالي اليوم',
                    value:
                        '₪ ${controller.todayTotal.value.toStringAsFixed(0)}',
                    icon: Icons.credit_card_rounded,
                    iconColor: kAccentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    title: 'حوالات معلقة',
                    value: controller.pendingTransfers.value.toString(),
                    icon: Icons.swap_horiz_rounded,
                    iconColor: kPendingColor,
                    valueColor: kPendingColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Actions ────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('إجراءات سريعة', style: AppTextStyles.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QuickActionButton(
                label: 'تسجيل دفعة',
                icon: Icons.add_rounded,
                iconColor: kAccentColor,
                onTap: () => Get.toNamed(AppRoutes.addPayment),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionButton(
                label: 'إضافة حوالة',
                icon: Icons.arrow_downward_rounded,
                iconColor: kSuccessColor,
                onTap: () => Get.toNamed(AppRoutes.addTransfer),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QuickActionButton(
                label: 'كشف اليوم',
                icon: Icons.description_rounded,
                iconColor: kSecondaryTextColor,
                onTap: () => Get.toNamed(AppRoutes.report),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionButton(
                label: 'مطابقة البنك',
                icon: Icons.account_balance_rounded,
                iconColor: kPendingColor,
                onTap: () => Get.toNamed(AppRoutes.bankMatching),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Recent Transactions ──────────────────────────────────────
class _RecentTransactions extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('آخر العمليات', style: AppTextStyles.titleMedium),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: kAccentColor),
            );
          }
          if (controller.recentTransactions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'لا توجد عمليات اليوم',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: kSecondaryTextColor,
                  ),
                ),
              ),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.recentTransactions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final tx = controller.recentTransactions[index];
              return _TransactionCard(tx: tx);
            },
          );
        }),
      ],
    );
  }
}

class _TransactionCard extends GetView<HomeController> {
  final Map<String, dynamic> tx;
  const _TransactionCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: controller.getIconBgColor(tx),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              controller.getTransactionIcon(tx),
              color: controller.getIconColor(tx),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Name & Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['customerName'] ?? tx['senderName'] ?? '',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: kPrimaryTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  controller.formatTime(tx['createdAt']),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          // Amount & Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₪ ${(tx['amount'] as num).toStringAsFixed(2)}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: controller.isReceived(tx)
                      ? kSuccessColor.withOpacity(0.12)
                      : kPendingColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.isReceived(tx) ? '✅ واصلة' : '⏳ معلقة',
                  style: AppTextStyles.caption.copyWith(
                    color: controller.isReceived(tx)
                        ? kSuccessColor
                        : kPendingColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
