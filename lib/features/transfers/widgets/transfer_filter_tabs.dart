import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controller/transfers_controller.dart';

class TransferFilterTabs extends StatelessWidget {
  final Rx<TransferFilter> activeFilter;
  final Function(TransferFilter) onChanged;

  const TransferFilterTabs({
    super.key,
    required this.activeFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          _Tab(
            label: 'الكل',
            isSelected: activeFilter.value == TransferFilter.all,
            onTap: () => onChanged(TransferFilter.all),
          ),
          const SizedBox(width: 8),
          _Tab(
            label: '✅ واصلة',
            isSelected: activeFilter.value == TransferFilter.received,
            onTap: () => onChanged(TransferFilter.received),
          ),
          const SizedBox(width: 8),
          _Tab(
            label: '⏳ معلقة',
            isSelected: activeFilter.value == TransferFilter.pending,
            onTap: () => onChanged(TransferFilter.pending),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Tab({
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
