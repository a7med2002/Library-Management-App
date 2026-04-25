import 'package:flutter/material.dart';
import 'package:library_managment/core/Constants/app_colors.dart';
import 'package:library_managment/core/Constants/app_text_styles.dart';

class PaymentListItem extends StatelessWidget {
  final Map<String, dynamic> payment;
  final String time;

  const PaymentListItem({super.key, required this.payment, required this.time});

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
              _serviceIcon(payment['serviceType'] ?? ''),
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
                  payment['customerName'] ?? '',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: kPrimaryTextColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_serviceLabel(payment['serviceType'] ?? '')} · $time',
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
                '₪ ${(payment['amount'] as num).toStringAsFixed(2)}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTextColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                payment['accountName'] ?? '',
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

  IconData _serviceIcon(String type) {
    switch (type) {
      case 'printing':
        return Icons.print_rounded;
      case 'photocopying':
        return Icons.document_scanner_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }

  String _serviceLabel(String type) {
    switch (type) {
      case 'printing':
        return 'طباعة';
      case 'photocopying':
        return 'تصوير';
      default:
        return 'خدمة أخرى';
    }
  }
}
