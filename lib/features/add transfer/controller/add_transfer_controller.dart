import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/core/Services/notification_service.dart';
import '../../../core/models/receiving_account_model.dart';
import '../../../core/services/firestore_service.dart';

class AddTransferController extends GetxController {
  final senderNameController = TextEditingController();
  final referenceNumberController = TextEditingController();
  final amountController = TextEditingController();
  final notesController = TextEditingController();

  final Rx<ReceivingAccountModel?> selectedAccount = Rx<ReceivingAccountModel?>(
    null,
  );
  final RxString transferStatus = 'pending'.obs;
  final RxList<ReceivingAccountModel> accounts = <ReceivingAccountModel>[].obs;
  final RxBool isLoading = false.obs;

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

  void selectAccount(ReceivingAccountModel account) =>
      selectedAccount.value = account;

  void selectStatus(String status) {
    transferStatus.value = status;
  }

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
      await FirestoreService.addTransfer({
        'senderName': senderNameController.text.trim(),
        'referenceNumber': referenceNumberController.text.trim(),
        'amount': double.parse(amountController.text.trim()),
        'accountId': selectedAccount.value!.id,
        'accountName': selectedAccount.value!.name,
        'status': transferStatus.value.toString(),
        'notes': notesController.text.trim(),
      });

      // ✅ أرسل إشعار
      await NotificationService.notifyTransferAdded(
        senderName: senderNameController.text.trim(),
        amount: double.parse(amountController.text.trim()),
        accountName: selectedAccount.value!.name,
        status: transferStatus.value,
      );

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
    } catch (e) {
      debugPrint('❌ Transfer Error: $e');
      _showError('حدث خطأ، حاول مجدداً');
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String msg) => Get.snackbar(
    '',
    msg,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.red.shade50,
    colorText: Colors.red.shade800,
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
  );

  @override
  void onClose() {
    senderNameController.dispose();
    referenceNumberController.dispose();
    amountController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
