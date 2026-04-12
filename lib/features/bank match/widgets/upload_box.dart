import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class UploadBox extends StatelessWidget {
  final RxString fileName;
  final VoidCallback onTap;

  const UploadBox({
    super.key,
    required this.fileName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Obx(() => Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: fileName.value.isNotEmpty ? kAccentColor : kDividerColor,
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  fileName.value.isNotEmpty
                      ? Icons.check_circle_rounded
                      : Icons.upload_rounded,
                  color: fileName.value.isNotEmpty
                      ? kSuccessColor
                      : kAccentColor,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  fileName.value.isNotEmpty
                      ? fileName.value
                      : 'اضغط لرفع كشف البنك',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: fileName.value.isNotEmpty
                        ? kSuccessColor
                        : kPrimaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Excel (.xlsx) أو PDF',
                  style: AppTextStyles.caption.copyWith(
                    color: kSecondaryTextColor,
                  ),
                ),
              ],
            ),
          )),
    );
  }
}