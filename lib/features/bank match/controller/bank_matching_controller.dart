import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../../core/models/receiving_account_model.dart';
import '../../../core/services/firestore_service.dart';
import '../model/bank_match_model.dart';

enum MatchingStep { upload, processing, results }

class BankMatchingController extends GetxController {
  final Rx<MatchingStep> currentStep = MatchingStep.upload.obs;
  final Rx<ReceivingAccountModel?> selectedAccount = Rx<ReceivingAccountModel?>(
    null,
  );
  final RxString fileName = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<ReceivingAccountModel> accounts = <ReceivingAccountModel>[].obs;

  final RxList<BankTransactionModel> matchedList = <BankTransactionModel>[].obs;
  final RxList<BankTransactionModel> unmatchedList =
      <BankTransactionModel>[].obs;

  // الحوالات المعلقة من Firestore
  List<Map<String, dynamic>> _pendingTransfers = [];

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

  void selectAccount(ReceivingAccountModel? account) =>
      selectedAccount.value = account;

  Future<void> pickFile() async {
    if (selectedAccount.value == null) {
      Get.snackbar(
        '',
        'الرجاء اختيار الحساب البنكي أولاً',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result == null) return;

    fileName.value = result.files.single.name;
    await _processExcelFile(result.files.single.path!);
  }

  Future<void> _processExcelFile(String path) async {
    try {
      currentStep.value = MatchingStep.processing;
      isLoading.value = true;

      // 1. جلب الحوالات المعلقة
      final allTransfers = await FirestoreService.getTransfersByDate(
        DateTime.now(),
      );
      _pendingTransfers = allTransfers
          .where((t) => t['status'] == 'pending')
          .toList();

      // 2. قراءة الـ Excel
      final bytes = File(path).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      final List<String> bankRefs = [];
      for (final table in excel.tables.keys) {
        final sheet = excel.tables[table]!;
        for (final row in sheet.rows) {
          for (final cell in row) {
            final value = cell?.value?.toString() ?? '';
            // دور على أي خلية تبدأ بـ REF أو رقم مرجعي
            if (value.toUpperCase().contains('REF') || value.length > 8) {
              bankRefs.add(value.trim());
            }
          }
        }
      }

      // 3. مطابقة
      final matched = <BankTransactionModel>[];
      final unmatched = <BankTransactionModel>[];

      for (final transfer in _pendingTransfers) {
        final ref = transfer['referenceNumber'] as String;
        final isFound = bankRefs.any(
          (bankRef) => bankRef.contains(ref) || ref.contains(bankRef),
        );

        final model = BankTransactionModel(
          referenceNumber: ref,
          amount: (transfer['amount'] as num).toDouble(),
          senderName: transfer['senderName'] as String,
          status: isFound ? MatchStatus.matched : MatchStatus.unmatched,
        );

        if (isFound) {
          matched.add(model);
        } else {
          unmatched.add(model);
        }
      }

      matchedList.value = matched;
      unmatchedList.value = unmatched;
      currentStep.value = MatchingStep.results;
    } catch (e) {
      Get.snackbar(
        '',
        'خطأ في قراءة الملف',
        snackPosition: SnackPosition.BOTTOM,
      );
      currentStep.value = MatchingStep.upload;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> applyUpdates() async {
    try {
      isLoading.value = true;
      for (final transfer in _pendingTransfers) {
        final ref = transfer['referenceNumber'] as String;
        final isMatched = matchedList.any((m) => m.referenceNumber == ref);
        if (isMatched) {
          await FirestoreService.updateTransferStatus(
            transfer['id'],
            'received',
          );
        }
      }
      Get.back();
      Get.snackbar(
        '',
        'تم تحديث حالة الحوالات ✅',
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
    _pendingTransfers = [];
  }
}
