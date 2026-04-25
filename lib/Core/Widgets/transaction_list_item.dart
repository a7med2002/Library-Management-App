import 'package:flutter/material.dart';
import 'package:library_managment/core/Constants/app_colors.dart';
import 'package:library_managment/core/Constants/app_text_styles.dart';
import 'package:library_managment/features/home/model/transaction_model.dart';


class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;
  final String time;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final isPayment = transaction.type == TransactionType.payment;
    final isReceived = transaction.status == TransactionStatus.received;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isPayment ? kIconBgPayment : kIconBgTransfer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPayment ? Icons.credit_card_rounded : Icons.swap_horiz_rounded,
              color: isPayment ? kAccentColor : kSuccessColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Name & Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.customerName,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: kPrimaryTextColor,
                    )),
                const SizedBox(height: 2),
                Text(time, style: AppTextStyles.caption),
              ],
            ),
          ),
          // Amount & Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₪ ${transaction.amount.toStringAsFixed(2)}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTextColor,
                ),
              ),
              const SizedBox(height: 4),
              _StatusBadge(isReceived: isReceived),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isReceived;
  const _StatusBadge({required this.isReceived});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isReceived
            ? kSuccessColor.withOpacity(0.12)
            : kPendingColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isReceived ? '✅ واصلة' : '⏳ معلقة',
        style: AppTextStyles.caption.copyWith(
          color: isReceived ? kSuccessColor : kPendingColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}