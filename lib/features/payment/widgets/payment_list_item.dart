import 'package:flutter/material.dart';
import 'package:library_managment/Core/Constants/app_colors.dart';
import 'package:library_managment/Core/Constants/app_text_styles.dart';
import 'package:library_managment/features/payment/model/payment_model.dart';


class PaymentListItem extends StatelessWidget {
  final PaymentModel payment;
  final String time;

  const PaymentListItem({
    super.key,
    required this.payment,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: kIconBgPayment,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              payment.serviceIcon,
              color: kAccentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Name & Service
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.customerName,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: kPrimaryTextColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${payment.serviceTypeAr} · $time',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          // Amount & Account
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₪ ${payment.amount.toStringAsFixed(2)}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTextColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                payment.accountName,
                style: AppTextStyles.caption.copyWith(
                  color: kSecondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}