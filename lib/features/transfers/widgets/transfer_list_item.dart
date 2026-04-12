import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../model/transfer_model.dart';

class TransferListItem extends StatelessWidget {
  final TransferModel transfer;
  final String date;

  const TransferListItem({
    super.key,
    required this.transfer,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = transfer.status == TransferStatus.pending;

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
          // ── Left: Amount + Account + Status ──────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₪ ${transfer.amount.toStringAsFixed(2)}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTextColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                transfer.accountName,
                style: AppTextStyles.caption.copyWith(
                  color: kSecondaryTextColor,
                ),
              ),
              const SizedBox(height: 6),
              _StatusBadge(isPending: isPending),
            ],
          ),

          const Spacer(),

          // ── Right: Icon + Name + Ref + Date ──────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transfer.senderName,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: kPrimaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        transfer.referenceNumber,
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        date,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: kIconBgTransfer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.swap_horiz_rounded,
                      color: kSuccessColor,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final bool isPending;
  const _StatusBadge({required this.isPending});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPending
            ? kPendingColor.withOpacity(0.12)
            : kSuccessColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPending ? '⏳ معلقة' : '✅ واصلة',
        style: AppTextStyles.caption.copyWith(
          color: isPending ? kPendingColor : kSuccessColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}