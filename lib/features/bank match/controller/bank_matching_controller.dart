import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/receiving_account_model.dart';
import '../model/bank_match_model.dart';

enum MatchingStep { upload, processing, results }

class BankMatchingController extends GetxController {
  final Rx<MatchingStep> currentStep = MatchingStep.upload.obs;
  final Rx<ReceivingAccountModel?> selectedAccount =
      Rx<ReceivingAccountModel?>(null);
  final RxString fileName = ''.obs;
  final RxBool isLoading = false.obs;

  final List<ReceivingAccountModel> accounts = AppAccounts.all;

  // Results
  final RxList<BankTransactionModel> matchedList =
      <BankTransactionModel>[].obs;
  final RxList<BankTransactionModel> unmatchedList =
      <BankTransactionModel>[].obs;

  void selectAccount(ReceivingAccountModel? account) =>
      selectedAccount.value = account;

  Future<void> pickFile() async {
    if (selectedAccount.value == null) {
      _showError('الرجاء اختيار الحساب البنكي أولاً');
      return;
    }
    // TODO: استخدم file_picker package
    // FilePickerResult? result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['xlsx', 'pdf'],
    // );
    // if (result != null) fileName.value = result.files.single.name;

    // Dummy لحد ما تربط الـ file picker
    fileName.value = 'bank_statement_jan2024.xlsx';
    await _processFile();
  }

  Future<void> _processFile() async {
    try {
      currentStep.value = MatchingStep.processing;
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 2)); // TODO: parse file
      _loadDummyResults();
      currentStep.value = MatchingStep.results;
    } finally {
      isLoading.value = false;
    }
  }

  void _loadDummyResults() {
    matchedList.value = [
      BankTransactionModel(
        referenceNumber: 'REF-20240115-002',
        amount: 1200,
        senderName: 'محمود علي',
        status: MatchStatus.matched,
      ),
      BankTransactionModel(
        referenceNumber: 'REF-20240114-003',
        amount: 800,
        senderName: 'عبدالرحمن سعيد',
        status: MatchStatus.matched,
      ),
    ];

    unmatchedList.value = [
      BankTransactionModel(
        referenceNumber: 'REF-20240115-001',
        amount: 500,
        senderName: 'خالد يوسف',
        status: MatchStatus.unmatched,
      ),
      BankTransactionModel(
        referenceNumber: 'REF-20240114-004',
        amount: 350,
        senderName: 'ياسر عمر',
        status: MatchStatus.unmatched,
      ),
    ];
  }

  Future<void> applyUpdates() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1)); // TODO: Firebase
      Get.back();
      Get.snackbar(
        '',
        'تم تحديث حالة الحوالات بنجاح ✅',
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

  void resetToUpload() {
    currentStep.value = MatchingStep.upload;
    fileName.value = '';
    matchedList.clear();
    unmatchedList.clear();
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
}