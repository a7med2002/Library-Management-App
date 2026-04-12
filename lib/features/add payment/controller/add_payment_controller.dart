import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/features/payment/model/payment_model.dart';
import '../../../core/models/receiving_account_model.dart';

class AddPaymentController extends GetxController {
  final customerNameController = TextEditingController();
  final amountController = TextEditingController();

  final Rx<ServiceType> selectedService = ServiceType.printing.obs;
  final Rx<ReceivingAccountModel?> selectedAccount =
      Rx<ReceivingAccountModel?>(null);

  final RxBool isLoading = false.obs;

  final List<ReceivingAccountModel> accounts = AppAccounts.all;

  void selectService(ServiceType type) => selectedService.value = type;

  void selectAccount(ReceivingAccountModel account) =>
      selectedAccount.value = account;

  Future<void> submitPayment() async {
    if (customerNameController.text.trim().isEmpty) {
      _showError('الرجاء إدخال اسم الزبون');
      return;
    }
    if (amountController.text.trim().isEmpty) {
      _showError('الرجاء إدخال المبلغ');
      return;
    }
    if (selectedAccount.value == null) {
      _showError('الرجاء اختيار وسيلة الاستلام');
      return;
    }

    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1)); // TODO: Firebase
      Get.back();
      Get.snackbar(
        '',
        'تم تسجيل الدفعة بنجاح ✅',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String msg) {
    Get.snackbar(
      '',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade50,
      colorText: Colors.red.shade800,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  @override
  void onClose() {
    customerNameController.dispose();
    amountController.dispose();
    super.onClose();
  }
}