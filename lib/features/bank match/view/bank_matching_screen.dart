import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/Core/Widgets/app_primary_button.dart';
import 'package:library_managment/core/models/receiving_account_model.dart';
import '../controller/bank_matching_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../widgets/step_indicator.dart';
import '../widgets/upload_box.dart';
import '../widgets/match_result_item.dart';

class BankMatchingScreen extends GetView<BankMatchingController> {
  const BankMatchingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(BankMatchingController());
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          _BankMatchingHeader(),
          Expanded(
            child: Obx(() {
              switch (controller.currentStep.value) {
                case MatchingStep.upload:
                  return _UploadStep();
                case MatchingStep.processing:
                  return _ProcessingStep();
                case MatchingStep.results:
                  return _ResultsStep();
              }
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────
class _BankMatchingHeader extends StatelessWidget {
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
          Text('مطابقة كشف البنك', style: AppTextStyles.titleMedium),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

// ─── Step 1: Upload ───────────────────────────────────────────
class _UploadStep extends GetView<BankMatchingController> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          StepIndicator(currentStep: 1),
          const SizedBox(height: 24),
          UploadBox(
            fileName: controller.fileName,
            onTap: controller.pickFile,
          ),
          const SizedBox(height: 24),
          // Account Selector
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'اختر الحساب البنكي',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: kPrimaryTextColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _AccountDropdown(),
        ],
      ),
    );
  }
}

// ─── Account Dropdown ─────────────────────────────────────────
class _AccountDropdown extends GetView<BankMatchingController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kDividerColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ReceivingAccountModel>(
              isExpanded: true,
              value: controller.selectedAccount.value,
              hint: Text(
                'اختر الحساب',
                style: AppTextStyles.bodySmall.copyWith(color: kHintColor),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: kSecondaryTextColor,
              ),
              items: controller.accounts
                  .map((account) => DropdownMenuItem(
                        value: account,
                        child: Text(
                          account.name,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: kPrimaryTextColor,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ))
                  .toList(),
              onChanged: controller.selectAccount,
            ),
          ),
        ));
  }
}

// ─── Step 2: Processing ───────────────────────────────────────
class _ProcessingStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StepIndicator(currentStep: 2),
        const Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: kAccentColor,
                  strokeWidth: 3,
                ),
                SizedBox(height: 24),
                Text(
                  'جاري تحليل الكشف ومطابقة الحوالات...',
                  style: TextStyle(
                    fontSize: 15,
                    color: kSecondaryTextColor,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Step 3: Results ──────────────────────────────────────────
class _ResultsStep extends GetView<BankMatchingController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StepIndicator(currentStep: 3),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary
                Obx(() => _ResultSummary(
                      matched: controller.matchedList.length,
                      total: controller.matchedList.length +
                          controller.unmatchedList.length,
                    )),
                const SizedBox(height: 20),

                // Matched
                Obx(() {
                  if (controller.matchedList.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ResultSectionTitle(
                        title: 'حوالات تم تأكيدها',
                        icon: Icons.check_circle_rounded,
                        color: kSuccessColor,
                      ),
                      const SizedBox(height: 10),
                      ...controller.matchedList.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: MatchResultItem(
                            item: item,
                            isMatched: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),

                // Unmatched
                Obx(() {
                  if (controller.unmatchedList.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ResultSectionTitle(
                        title: 'حوالات لم تُعثر عليها',
                        icon: Icons.cancel_rounded,
                        color: kErrorColor,
                      ),
                      const SizedBox(height: 10),
                      ...controller.unmatchedList.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: MatchResultItem(
                            item: item,
                            isMatched: false,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),

                // Apply Button
                Obx(() => AppPrimaryButton(
                      label: 'تطبيق التحديثات',
                      isLoading: controller.isLoading.value,
                      onTap: controller.applyUpdates,
                    )),
                const SizedBox(height: 12),

                // Reset Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: controller.resetToUpload,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kDividerColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'رفع ملف آخر',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: kSecondaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Result Summary ───────────────────────────────────────────
class _ResultSummary extends StatelessWidget {
  final int matched;
  final int total;

  const _ResultSummary({required this.matched, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'تم مطابقة $matched من أصل $total حوالة',
        style: AppTextStyles.bodyMedium.copyWith(
          color: kWhiteColor,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ─── Section Title ────────────────────────────────────────────
class _ResultSectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _ResultSectionTitle({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Icon(icon, color: color, size: 18),
      ],
    );
  }
}