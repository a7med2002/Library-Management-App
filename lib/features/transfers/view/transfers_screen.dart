import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/core/Constants/app_colors.dart';
import 'package:library_managment/core/Constants/app_text_styles.dart';
import 'package:library_managment/core/Routes/app_routes.dart';
import 'package:library_managment/core/Widgets/app_search_bar.dart';
import 'package:library_managment/core/Widgets/empty_state.dart';
import 'package:library_managment/features/transfers/controller/transfers_controller.dart';
import 'package:library_managment/features/transfers/widgets/transfer_filter_tabs.dart';
import 'package:library_managment/features/transfers/widgets/transfer_list_item.dart';

class TransfersScreen extends GetView<TransfersController> {
  const TransfersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(TransfersController());
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          _TransfersHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  TransferFilterTabs(
                    activeFilter: controller.activeFilter,
                    onChanged: controller.onFilterChanged,
                  ),
                  const SizedBox(height: 12),
                  AppSearchBar(
                    hint: 'ابحث باسم أو رقم مرجعي...',
                    onChanged: controller.onSearchChanged,
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _TransfersList()),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addTransfer),
        backgroundColor: kAccentColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: kWhiteColor, size: 28),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────
class _TransfersHeader extends StatelessWidget {
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
      child: Text('الحوالات', style: AppTextStyles.titleMedium),
    );
  }
}

// ─── Transfers List ───────────────────────────────────────────
class _TransfersList extends GetView<TransfersController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.filteredTransfers.isEmpty) {
        return const EmptyState(message: 'لا توجد حوالات بعد');
      }
      return ListView.separated(
        itemCount: controller.filteredTransfers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, index) {
          final transfer = controller.filteredTransfers[index];
          return TransferListItem(
            transfer: transfer,
            date: controller.formatDate(transfer['createdAt']),
          );
        },
      );
    });
  }
}
