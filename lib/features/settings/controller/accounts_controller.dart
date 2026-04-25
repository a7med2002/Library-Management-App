import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/receiving_account_model.dart';
import '../../../core/services/firestore_service.dart';

class AccountsController extends GetxController {
  final RxList<ReceivingAccountModel> accounts = <ReceivingAccountModel>[].obs;
  final RxBool isLoading = false.obs;

  // Add Account Form
  final nameController = TextEditingController();
  final identifierController = TextEditingController();
  final Rx<AccountType> selectedType = AccountType.bank.obs;

  @override
  void onInit() {
    super.onInit();
    _listenAccounts();
  }

  void _listenAccounts() {
    FirestoreService.accountsStream().listen((list) {
      accounts.value = list;
    });
  }

  Future<void> addAccount() async {
    if (nameController.text.trim().isEmpty ||
        identifierController.text.trim().isEmpty) {
      Get.snackbar(
        '',
        'الرجاء تعبئة جميع الحقول',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      final account = ReceivingAccountModel(
        id: '',
        name: nameController.text.trim(),
        identifier: identifierController.text.trim(),
        type: selectedType.value,
        icon: selectedType.value == AccountType.bank
            ? Icons.account_balance_rounded
            : Icons.account_balance_wallet_rounded,
      );
      await FirestoreService.addAccount(account);
      Get.back();
      _clearForm();
      Get.snackbar(
        '',
        'تم إضافة الحساب ✅',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'حذف الحساب',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'هل أنت متأكد من حذف هذا الحساب؟',
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

    if (confirmed == true) {
      await FirestoreService.deleteAccount(id);
    }
  }

  void _clearForm() {
    nameController.clear();
    identifierController.clear();
    selectedType.value = AccountType.bank;
  }

  @override
  void onClose() {
    nameController.dispose();
    identifierController.dispose();
    super.onClose();
  }
}
