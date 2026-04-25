import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final bool showArrow;
  final bool showDivider;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
    this.showArrow = true,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Arrow
                if (showArrow)
                  const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: kSecondaryTextColor,
                    size: 14,
                  ),
                if (showArrow) const SizedBox(width: 4),

                // Value
                if (value != null)
                  Text(
                    value!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: kSecondaryTextColor,
                    ),
                  ),

                const Spacer(),

                // Label
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: kPrimaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 10),

                // Icon
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: kAccentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: kAccentColor, size: 18),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: kDividerColor,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
