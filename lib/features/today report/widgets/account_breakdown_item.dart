import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../model/report_model.dart';

class AccountBreakdownItem extends StatelessWidget {
  final AccountReportModel item;
  final double maxAmount;

  const AccountBreakdownItem({
    super.key,
    required this.item,
    required this.maxAmount,
  });

  @override
  Widget build(BuildContext context) {
    final barWidth = (item.amount / maxAmount).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Name & Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₪ ${item.amount.toStringAsFixed(0)}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: kAccentColor,
                ),
              ),
              Text(
                item.accountName,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: kPrimaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress Bar
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Background
                  Container(
                    height: 6,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: kDividerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // Fill
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    height: 6,
                    width: constraints.maxWidth * barWidth,
                    decoration: BoxDecoration(
                      color: kAccentColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
