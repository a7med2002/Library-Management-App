import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/Core/Widgets/app_primary_button.dart';
import 'package:library_managment/Core/Widgets/app_text_field.dart';
import 'package:library_managment/features/transfers/model/transfer_model.dart';
import '../controller/add_transfer_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/receiving_account_model.dart';


class AddTransferScreen extends GetView<AddTransferController> {
  const AddTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AddTransferController());
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          _AddTransferHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── اسم المُحوِّل ─────────────────────
                  _SectionLabel('اسم المُحوِّل'),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: controller.senderNameController,
                    hint: 'أدخل اسم المرسل',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 20),

                  // ── الرقم المرجعي ─────────────────────
                  _SectionLabel('الرقم المرجعي'),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: controller.referenceNumberController,
                    hint: 'رقم العملية من البنك',
                    icon: Icons.tag_rounded,
                  ),
                  const SizedBox(height: 20),

                  // ── المبلغ ────────────────────────────
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

                  // ── الحساب المستقبِل ──────────────────
                  _SectionLabel('الحساب المستقبِل'),
                  const SizedBox(height: 10),
                  _AccountsList(),
                  const SizedBox(height: 20),

                  // ── حالة الحوالة ──────────────────────
                  _SectionLabel('حالة الحوالة'),
                  const SizedBox(height: 10),
                  _StatusSelector(),
                  const SizedBox(height: 20),

                  // ── ملاحظات ───────────────────────────
                  _SectionLabel('ملاحظات (اختياري)'),
                  const SizedBox(height: 8),
                  _NotesField(),
                  const SizedBox(height: 28),

                  // ── زر الحفظ ─────────────────────────
                  Obx(() => AppPrimaryButton(
                        label: 'حفظ الحوالة',
                        isLoading: controller.isLoading.value,
                        onTap: controller.submitTransfer,
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
class _AddTransferHeader extends StatelessWidget {
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
          Text('إضافة حوالة جديدة', style: AppTextStyles.titleMedium),
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

// ─── Accounts List ────────────────────────────────────────────
class _AccountsList extends GetView<AddTransferController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          children: controller.accounts
              .map((account) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _AccountCard(
                      account: account,
                      isSelected:
                          controller.selectedAccount.value?.id == account.id,
                      onTap: () => controller.selectAccount(account),
                    ),
                  ))
              .toList(),
        ));
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                account.icon,
                color: kPrimaryColor,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Status Selector ──────────────────────────────────────────
class _StatusSelector extends GetView<AddTransferController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: [
            Expanded(
              child: _StatusOption(
                label: 'واصلة',
                emoji: '✅',
                isSelected:
                    controller.transferStatus.value == TransferStatus.received,
                selectedColor: kSuccessColor,
                onTap: () => controller.selectStatus(TransferStatus.received),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatusOption(
                label: 'لم تصل بعد',
                emoji: '⏳',
                isSelected:
                    controller.transferStatus.value == TransferStatus.pending,
                selectedColor: kPendingColor,
                onTap: () => controller.selectStatus(TransferStatus.pending),
              ),
            ),
          ],
        ));
  }
}

class _StatusOption extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _StatusOption({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withOpacity(0.08)
              : kCardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? selectedColor : kDividerColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            '$emoji $label',
            style: AppTextStyles.bodySmall.copyWith(
              color: isSelected ? selectedColor : kSecondaryTextColor,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Notes Field ──────────────────────────────────────────────
class _NotesField extends GetView<AddTransferController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kDividerColor),
      ),
      child: TextField(
        controller: controller.notesController,
        maxLines: 4,
        textAlign: TextAlign.right,
        style: AppTextStyles.bodySmall.copyWith(color: kPrimaryTextColor),
        decoration: InputDecoration(
          hintText: 'أضف ملاحظة...',
          hintStyle:
              AppTextStyles.bodySmall.copyWith(color: kHintColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }
}