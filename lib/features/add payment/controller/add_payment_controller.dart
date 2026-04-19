import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/features/payment/model/payment_model.dart';
import '../../../core/models/receiving_account_model.dart';
import '../../../core/services/firestore_service.dart';

class AddPaymentController extends GetxController {
  final customerNameController = TextEditingController();
  final amountController = TextEditingController();

  final Rx<ServiceType> selectedService = ServiceType.printing.obs;
  final Rx<ReceivingAccountModel?> selectedAccount =
      Rx<ReceivingAccountModel?>(null);
  final RxList<ReceivingAccountModel> accounts =
      <ReceivingAccountModel>[].obs;
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

  void selectService(ServiceType type) => selectedService.value = type;
  
  void selectAccount(ReceivingAccountModel account) =>
      selectedAccount.value = account;

  Future<void> submitPayment() async {
    if (customerNameController.text.trim().isEmpty) {
      _showError('الرجاء إدخال اسم الزبون'); return;
    }
    if (amountController.text.trim().isEmpty) {
      _showError('الرجاء إدخال المبلغ'); return;
    }
    if (selectedAccount.value == null) {
      _showError('الرجاء اختيار وسيلة الاستلام'); return;
    }

    try {
      isLoading.value = true;
      await FirestoreService.addPayment({
        'customerName': customerNameController.text.trim(),
        'amount': double.parse(amountController.text.trim()),
        'serviceType': selectedService.value.name,
        'accountId': selectedAccount.value!.id,
        'accountName': selectedAccount.value!.name,
      });
      Get.back();
      Get.snackbar('', 'تم تسجيل الدفعة بنجاح ✅',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade800,
          margin: const EdgeInsets.all(16),
          borderRadius: 12);
    } catch (e) {
      _showError('حدث خطأ، حاول مجدداً');
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String msg) => Get.snackbar('', msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade50,
      colorText: Colors.red.shade800,
      margin: const EdgeInsets.all(16),
      borderRadius: 12);

  @override
  void onClose() {
    customerNameController.dispose();
    amountController.dispose();
    super.onClose();
  }
}