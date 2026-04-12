import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/report_model.dart';

class ReportController extends GetxController {
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  final RxDouble totalPayments = 2245.0.obs;
  final RxInt totalOperations = 12.obs;
  final RxDouble totalTransfers = 3500.0.obs;
  final RxInt pendingTransfers = 3.obs;
  final RxBool isLoading = false.obs;

  final RxList<AccountReportModel> accountsBreakdown =
      <AccountReportModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void _loadData() {
    accountsBreakdown.value = [
      AccountReportModel(
        accountName: 'بنك — أحمد',
        amount: 1800,
        percentage: 0.49,
      ),
      AccountReportModel(
        accountName: 'محفظة BI — أحمد',
        amount: 1200,
        percentage: 0.33,
      ),
      AccountReportModel(
        accountName: 'جوال باي — أحمد',
        amount: 600,
        percentage: 0.16,
      ),
      AccountReportModel(
        accountName: 'محفظة — عمرو',
        amount: 400,
        percentage: 0.11,
      ),
    ];
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff1B2A4A),
              onSurface: Color(0xff1B2A4A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedDate.value = picked;
      _loadData();
    }
  }

  String get formattedDate {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${selectedDate.value.day} ${months[selectedDate.value.month - 1]} ${selectedDate.value.year}';
  }

  double get maxAmount =>
      accountsBreakdown.isEmpty
          ? 1
          : accountsBreakdown
              .map((e) => e.amount)
              .reduce((a, b) => a > b ? a : b);

  Future<void> exportReport() async {
    // TODO: export PDF
    Get.snackbar(
      '',
      'جاري تصدير التقرير... 📄',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade50,
      colorText: Colors.blue.shade800,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}