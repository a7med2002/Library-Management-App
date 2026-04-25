import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/core/Constants/app_colors.dart';
import 'package:library_managment/core/Constants/app_text_styles.dart';
import 'package:library_managment/core/Widgets/app_primary_button.dart';
import 'package:library_managment/core/Widgets/app_text_field.dart';
import 'package:library_managment/core/models/receiving_account_model.dart';
import 'package:library_managment/features/outgoing%20transfers/controller/add_outgoing_transfer_controller';

class AddOutgoingTransferScreen extends GetView<AddOutgoingTransferController> {
  const AddOutgoingTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AddOutgoingTransferController());
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
                  _Label('اسم المستلم / التاجر'),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: controller.recipientNameController,
                    hint: 'مثال: تاجر القرطاسية',
                    icon: Icons.store_rounded,
                  ),
                  const SizedBox(height: 20),

                  _Label('المبلغ'),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: controller.amountController,
                    hint: '0.00',
                    icon: Icons.attach_money_rounded,
                    keyboardType: TextInputType.number,
                    suffixText: '₪',
                    textAlign: TextAlign.end,
                  ),
                  const SizedBox(height: 20),

                  _Label('التصنيف'),
                  const SizedBox(height: 10),
                  _CategorySelector(),
                  const SizedBox(height: 20),

                  _Label('الحساب المدفوع منه'),
                  const SizedBox(height: 10),
                  _AccountsList(),
                  const SizedBox(height: 20),

                  _Label('الرقم المرجعي (اختياري)'),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: controller.referenceController,
                    hint: 'رقم الفاتورة أو العملية',
                    icon: Icons.tag_rounded,
                  ),
                  const SizedBox(height: 20),

                  _Label('ملاحظات (اختياري)'),
                  const SizedBox(height: 8),
                  _NotesField(),
                  const SizedBox(height: 28),

                  Obx(
                    () => AppPrimaryButton(
                      label: 'تسجيل المصروف',
                      isLoading: controller.isLoading.value,
                      onTap: controller.submit,
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
          Text('تسجيل مصروف جديد', style: AppTextStyles.titleMedium),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

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

class _CategorySelector extends GetView<AddOutgoingTransferController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.5,
        children: OutgoingCategory.values.map((cat) {
          final isSelected = controller.selectedCategory.value == cat;
          return GestureDetector(
            onTap: () => controller.selectCategory(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected ? kErrorColor.withOpacity(0.08) : kCardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? kErrorColor : kDividerColor,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    cat.icon,
                    size: 18,
                    color: isSelected ? kErrorColor : kSecondaryTextColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected ? kErrorColor : kSecondaryTextColor,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AccountsList extends GetView<AddOutgoingTransferController> {
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
            color: isSelected ? kErrorColor : kDividerColor,
            width: isSelected ? 1.5 : 1,
          ),
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
              child: Icon(account.icon, color: kPrimaryColor, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotesField extends GetView<AddOutgoingTransferController> {
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
        maxLines: 3,
        textAlign: TextAlign.right,
        style: AppTextStyles.bodySmall.copyWith(color: kPrimaryTextColor),
        decoration: InputDecoration(
          hintText: 'أضف ملاحظة...',
          hintStyle: AppTextStyles.bodySmall.copyWith(color: kHintColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }
}
