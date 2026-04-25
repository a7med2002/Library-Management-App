import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/core/Services/firestore_service.dart';

class TransferDetailController extends GetxController {
  final Map<String, dynamic> transferData;

  TransferDetailController({required this.transferData});

  final RxString status = ''.obs;
  final RxBool isLoading = false.obs;

  // ✅ getter بدل late field
  Map<String, dynamic> get transfer => transferData;

  @override
  void onInit() {
    super.onInit();
    debugPrint('📋 FULL TRANSFER DATA: $transferData');
    status.value = transferData['status']?.toString() ?? 'pending';
  }

  bool get isPending => status.value == 'pending';

  String get formattedDate {
    final timestamp = transferData['createdAt'];
    if (timestamp == null) return '';
    try {
      final date = timestamp.toDate();
      final months = [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر',
      ];
      final hour = date.hour > 12 ? date.hour - 12 : date.hour;
      final m = date.minute.toString().padLeft(2, '0');
      final period = date.hour < 12 ? 'ص' : 'م';
      return '${date.day} ${months[date.month - 1]} ${date.year} — $hour:$m $period';
    } catch (e) {
      return '';
    }
  }

  Future<void> markAsReceived() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'تأكيد الاستلام',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'هل تأكد وصول هذه الحوالة؟',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Cairo', color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'تأكيد',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Color(0xff4CAF50),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      isLoading.value = true;
      final id = transferData['id']?.toString() ?? '';
      if (id.isEmpty) return;
      await FirestoreService.updateTransferStatus(id, 'received');
      status.value = 'received';
      transferData['status'] = 'received';
      Get.back();
      Get.snackbar(
        '',
        'تم تأكيد وصول الحوالة ✅',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      debugPrint('❌ Error: $e');
      Get.snackbar(
        '',
        'حدث خطأ، حاول مجدداً',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTransfer() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'حذف الحوالة',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'هل أنت متأكد من حذف هذه الحوالة؟',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Cairo', color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'حذف',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      isLoading.value = true;
      final id = transferData['id']?.toString() ?? '';
      if (id.isEmpty) return;
      await FirestoreService.deleteTransfer(id);
      Get.back();
      Get.snackbar(
        '',
        'تم حذف الحوالة 🗑️',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      debugPrint('❌ Error: $e');
      Get.snackbar(
        '',
        'حدث خطأ، حاول مجدداً',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
