import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/transfer_detail_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_primary_button.dart';

class TransferDetailScreen extends GetView<TransferDetailController> {
  const TransferDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    // ✅ لو موجود مسبقاً احذفه وعيد إنشاءه
    if (Get.isRegistered<TransferDetailController>()) {
      Get.delete<TransferDetailController>(force: true);
    }

    final controller = Get.put(
      TransferDetailController(transferData: Map<String, dynamic>.from(args)),
    );
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          _Header(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _StatusCard(),
                  const SizedBox(height: 16),
                  _DetailsCard(),
                  const SizedBox(height: 24),
                  _ActionButtons(),
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
          Text('تفاصيل الحوالة', style: AppTextStyles.titleMedium),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

// ─── Status Card ──────────────────────────────────────────────
class _StatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransferDetailController>();
    return Obx(() {
      final isReceived = !controller.isPending;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isReceived
              ? kSuccessColor.withOpacity(0.08)
              : kPendingColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isReceived
                ? kSuccessColor.withOpacity(0.3)
                : kPendingColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              isReceived
                  ? Icons.check_circle_rounded
                  : Icons.hourglass_empty_rounded,
              color: isReceived ? kSuccessColor : kPendingColor,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              isReceived ? 'واصلة ✅' : 'معلقة ⏳',
              style: AppTextStyles.titleMedium.copyWith(
                color: isReceived ? kSuccessColor : kPendingColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '₪ ${((controller.transfer['amount'] ?? 0) as num).toStringAsFixed(2)}',
              style: AppTextStyles.displayLarge.copyWith(
                color: kPrimaryTextColor,
                fontSize: 28,
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─── Details Card ─────────────────────────────────────────────
class _DetailsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransferDetailController>();
    final tx = controller.transfer;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _DetailRow(
            label: 'اسم المُحوِّل',
            value: tx['senderName'] ?? '',
            icon: Icons.person_outline_rounded,
          ),
          _Divider(),
          _DetailRow(
            label: 'الرقم المرجعي',
            value: tx['referenceNumber'] ?? '',
            icon: Icons.tag_rounded,
          ),
          _Divider(),
          _DetailRow(
            label: 'الحساب المستقبِل',
            value: tx['accountName'] ?? '',
            icon: Icons.account_balance_rounded,
          ),
          _Divider(),
          _DetailRow(
            label: 'التاريخ',
            value: controller.formattedDate,
            icon: Icons.calendar_today_rounded,
          ),
          if ((tx['notes'] ?? '').toString().isNotEmpty) ...[
            _Divider(),
            _DetailRow(
              label: 'ملاحظات',
              value: tx['notes']?.toString() ?? '', // ✅
              icon: Icons.notes_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Value
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: kPrimaryTextColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          const SizedBox(width: 12),
          // Label + Icon
          Row(
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: kSecondaryTextColor,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: kAccentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: kAccentColor, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: kDividerColor);
  }
}

// ─── Action Buttons ───────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransferDetailController>();
    return Obx(() {
      if (!controller.isPending) {
        // واصلة — بس زر الحذف
        return _DeleteButton();
      }
      // معلقة — زر التأكيد + الحذف
      return Column(
        children: [
          AppPrimaryButton(
            label: 'تأكيد وصول الحوالة ✅',
            isLoading: controller.isLoading.value,
            onTap: controller.markAsReceived,
          ),
          const SizedBox(height: 12),
          _DeleteButton(),
        ],
      );
    });
  }
}

class _DeleteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransferDetailController>();
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: controller.isLoading.value
            ? null
            : controller.deleteTransfer,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: kErrorColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          'حذف الحوالة 🗑️',
          style: AppTextStyles.bodySmall.copyWith(
            color: kErrorColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
