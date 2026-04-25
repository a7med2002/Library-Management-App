import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/core/Constants/app_colors.dart';
import 'package:library_managment/core/Constants/app_text_styles.dart';
import 'package:library_managment/core/Routes/app_routes.dart';
import 'package:library_managment/core/Widgets/app_primary_button.dart';
import 'package:library_managment/core/Widgets/app_text_field.dart';
import 'package:library_managment/core/models/receiving_account_model.dart';
import 'package:library_managment/features/add%20payment/controller/add_payment_controller.dart';
import 'package:library_managment/features/payment/model/payment_model.dart';

class AddPaymentScreen extends GetView<AddPaymentController> {
  const AddPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AddPaymentController());
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          _AddPaymentHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── اسم الزبون ──────────────────────
                  _SectionLabel('اسم الزبون'),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: controller.customerNameController,
                    hint: 'أدخل اسم الزبون',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 20),

                  // ── المبلغ ───────────────────────────
                  _SectionLabel('المبلغ'),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: controller.amountController,
                    hint: '0.00',
                    icon: Icons.attach_money_rounded,
                    keyboardType: TextInputType.number,
                    suffixText: '\$',
                    textAlign: TextAlign.end,
                  ),
                  const SizedBox(height: 20),

                  // ── نوع الخدمة ───────────────────────
                  _SectionLabel('نوع الخدمة'),
                  const SizedBox(height: 8),
                  _ServiceTypeSelector(),
                  const SizedBox(height: 20),

                  // ── وسيلة الاستلام ───────────────────
                  _SectionLabel('وسيلة الاستلام'),
                  const SizedBox(height: 4),
                  Text(
                    'اختر الحساب الذي استلمت عليه',
                    style: AppTextStyles.caption.copyWith(
                      color: kSecondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _AccountsList(),
                  const SizedBox(height: 12),
                  _AddAccountButton(),
                  const SizedBox(height: 24),

                  // ── زر التسجيل ───────────────────────
                  Obx(
                    () => AppPrimaryButton(
                      label: 'تسجيل الدفعة',
                      isLoading: controller.isLoading.value,
                      onTap: controller.submitPayment,
                    ),
                  ),
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
class _AddPaymentHeader extends StatelessWidget {
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
          Text('تسجيل دفعة جديدة', style: AppTextStyles.titleMedium),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(
        fontWeight: FontWeight.w600,
        color: kPrimaryTextColor,
      ),
    );
  }
}

// ─── Service Type Selector ────────────────────────────────────
class _ServiceTypeSelector extends GetView<AddPaymentController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          _ServiceChip(
            label: 'طباعة',
            icon: Icons.print_rounded,
            type: ServiceType.printing,
            isSelected:
                controller.selectedService.value == ServiceType.printing,
            onTap: () => controller.selectService(ServiceType.printing),
          ),
          const SizedBox(width: 8),
          _ServiceChip(
            label: 'تصوير',
            icon: Icons.document_scanner_rounded,
            type: ServiceType.photocopying,
            isSelected:
                controller.selectedService.value == ServiceType.photocopying,
            onTap: () => controller.selectService(ServiceType.photocopying),
          ),
          const SizedBox(width: 8),
          _ServiceChip(
            label: 'خدمة أخرى',
            icon: Icons.miscellaneous_services_rounded,
            type: ServiceType.other,
            isSelected: controller.selectedService.value == ServiceType.other,
            onTap: () => controller.selectService(ServiceType.other),
          ),
        ],
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final ServiceType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceChip({
    required this.label,
    required this.icon,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor.withOpacity(0.08) : kCardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? kPrimaryColor : kDividerColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? kPrimaryColor : kSecondaryTextColor,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? kPrimaryColor : kSecondaryTextColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Accounts List ────────────────────────────────────────────
class _AccountsList extends GetView<AddPaymentController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: controller.accounts
            .map(
              (account) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _AccountCard(
                  account: account,
                  isSelected:
                      controller.selectedAccount.value?.id == account.id,
                  onTap: () => controller.selectAccount(account),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final ReceivingAccountModel account;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountCard({
    required this.account,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? kAccentColor : kDividerColor,
            width: isSelected ? 1.5 : 1,
          ),
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
            // Name & Identifier
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    account.name,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: kPrimaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    account.identifier,
                    style: AppTextStyles.caption.copyWith(
                      color: kSecondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(account.icon, color: kPrimaryColor, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add Account Button ───────────────────────────────────────
class _AddAccountButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // انتظر لما يرجع من شاشة الإضافة
        await Get.toNamed(AppRoutes.addAccount);
      },
      child: Center(
        child: Text(
          '+ إضافة حساب جديد',
          style: AppTextStyles.bodySmall.copyWith(
            color: kAccentColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
