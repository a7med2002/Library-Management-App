import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../model/bank_match_model.dart';

class MatchResultItem extends StatelessWidget {
  final BankTransactionModel item;
  final bool isMatched;

  const MatchResultItem({
    super.key,
    required this.item,
    required this.isMatched,
  });

  @override
  Widget build(BuildContext context) {
    final color = isMatched ? kSuccessColor : kErrorColor;
    final bgColor = isMatched
        ? kSuccessColor.withOpacity(0.06)
        : kErrorColor.withOpacity(0.06);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Amount
          Text(
            '₪ ${item.amount.toStringAsFixed(0)}',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Spacer(),
          // Name & Ref
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.senderName,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: kPrimaryTextColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.referenceNumber,
                style: AppTextStyles.caption.copyWith(
                  color: kSecondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Icon
          Icon(
            isMatched ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: color,
            size: 22,
          ),
        ],
      ),
    );
  }
}
