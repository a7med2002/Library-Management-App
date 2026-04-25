import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/accounts_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/receiving_account_model.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_primary_button.dart';

class AddAccountScreen extends GetView<AccountsController> {
  const AddAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AccountsController());
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          _Header(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('اسم الحساب'),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: controller.nameController,
                    hint: 'مثال: بنك — أحمد',
                    icon: Icons.label_outline_rounded,
                  ),
                  const SizedBox(height: 20),

                  _SectionLabel('رقم الحساب / رقم الهاتف'),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: controller.identifierController,
                    hint: 'PS12 3456 7890',
                    icon: Icons.numbers_rounded,
                  ),
                  const SizedBox(height: 20),

                  _SectionLabel('نوع الحساب'),
                  const SizedBox(height: 10),
                  _AccountTypeSelector(),
                  const SizedBox(height: 32),

                  Obx(
                    () => AppPrimaryButton(
                      label: 'إضافة الحساب',
                      isLoading: controller.isLoading.value,
                      onTap: controller.addAccount,
                    ),
                  ),
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
class _Header extends StatelessWidget {
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
          Text('إضافة حساب جديد', style: AppTextStyles.titleMedium),
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

// ─── Account Type Selector ────────────────────────────────────
class _AccountTypeSelector extends GetView<AccountsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _TypeOption(
              label: 'بنك',
              icon: Icons.account_balance_rounded,
              isSelected: controller.selectedType.value == AccountType.bank,
              onTap: () => controller.selectedType.value = AccountType.bank,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TypeOption(
              label: 'محفظة رقمية',
              icon: Icons.account_balance_wallet_rounded,
              isSelected: controller.selectedType.value == AccountType.wallet,
              onTap: () => controller.selectedType.value = AccountType.wallet,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor.withOpacity(0.08) : kCardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? kPrimaryColor : kDividerColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? kPrimaryColor : kSecondaryTextColor,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? kPrimaryColor : kSecondaryTextColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
