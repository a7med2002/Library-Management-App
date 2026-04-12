import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/features/transfers/model/transfer_model.dart';
import '../../../core/models/receiving_account_model.dart';

class AddTransferController extends GetxController {
  final senderNameController = TextEditingController();
  final referenceNumberController = TextEditingController();
  final amountController = TextEditingController();
  final notesController = TextEditingController();

  final Rx<ReceivingAccountModel?> selectedAccount =
      Rx<ReceivingAccountModel?>(null);
  final Rx<TransferStatus> transferStatus = TransferStatus.received.obs;
  final RxBool isLoading = false.obs;

  final List<ReceivingAccountModel> accounts = AppAccounts.all;

  void selectAccount(ReceivingAccountModel account) =>
      selectedAccount.value = account;

  void selectStatus(TransferStatus status) =>
      transferStatus.value = status;

  Future<void> submitTransfer() async {
    if (senderNameController.text.trim().isEmpty) {
      _showError('الرجاء إدخال اسم المُحوِّل');
      return;
    }
    if (referenceNumberController.text.trim().isEmpty) {
      _showError('الرجاء إدخال الرقم المرجعي');
      return;
    }
    if (amountController.text.trim().isEmpty) {
      _showError('الرجاء إدخال المبلغ');
      return;
    }
    if (selectedAccount.value == null) {
      _showError('الرجاء اختيار الحساب المستقبِل');
      return;
    }

    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1)); // TODO: Firebase
      Get.back();
      Get.snackbar(
        '',
        'تم حفظ الحوالة بنجاح ✅',
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
    senderNameController.dispose();
    referenceNumberController.dispose();
    amountController.dispose();
    notesController.dispose();
    super.onClose();
  }
}