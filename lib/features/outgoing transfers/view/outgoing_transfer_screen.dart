import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/core/Constants/app_colors.dart';
import 'package:library_managment/core/Constants/app_text_styles.dart';
import 'package:library_managment/core/Routes/app_routes.dart';
import 'package:library_managment/core/Widgets/app_search_bar.dart';
import 'package:library_managment/core/Widgets/empty_state.dart';
import 'package:library_managment/features/outgoing%20transfers/controller/outgoing_transfer_controller';

class OutgoingTransfersScreen extends GetView<OutgoingTransfersController> {
  const OutgoingTransfersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OutgoingTransfersController());
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          _Header(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  AppSearchBar(
                    hint: 'ابحث باسم المستلم...',
                    onChanged: controller.onSearchChanged,
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _OutgoingList()),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addOutgoingTransfer),
        backgroundColor: kErrorColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: kWhiteColor, size: 28),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 16,
        right: 16,
        left: 16,
      ),
      color: kBackgroundColor,
      child: Text('المصروفات', style: AppTextStyles.titleMedium),
    );
  }
}

class _OutgoingList extends GetView<OutgoingTransfersController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.filteredList.isEmpty) {
        return const EmptyState(message: 'لا توجد مصروفات بعد');
      }
      return ListView.separated(
        itemCount: controller.filteredList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, index) {
          final item = controller.filteredList[index];
          return _OutgoingCard(item: item);
        },
      );
    });
  }
}

class _OutgoingCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _OutgoingCard({required this.item});

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
          // Amount + Account
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₪ ${(item['amount'] as num).toStringAsFixed(2)}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: kErrorColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item['accountName'] ?? '',
                style: AppTextStyles.caption.copyWith(
                  color: kSecondaryTextColor,
                ),
              ),
              const SizedBox(height: 4),
              _CategoryBadge(category: item['category'] ?? ''),
            ],
          ),

          const Spacer(),

          // Name + Notes
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['recipientName'] ?? '',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: kPrimaryTextColor,
                ),
              ),
              if ((item['notes'] ?? '').toString().isNotEmpty)
                Text(item['notes'], style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(width: 12),

          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: kErrorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_upward_rounded,
              color: kErrorColor,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});

  String get label {
    switch (category) {
      case 'supplies':
        return 'مستلزمات';
      case 'bills':
        return 'فواتير';
      case 'salaries':
        return 'رواتب';
      default:
        return 'أخرى';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: kErrorColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: kErrorColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
