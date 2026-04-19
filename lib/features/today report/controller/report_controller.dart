import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/services/firestore_service.dart';
import '../model/report_model.dart';

class ReportController extends GetxController {
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxDouble totalPayments = 0.0.obs;
  final RxInt totalOperations = 0.obs;
  final RxDouble totalTransfers = 0.0.obs;
  final RxInt pendingTransfers = 0.obs;
  final RxBool isLoading = false.obs;
  final RxList<AccountReportModel> accountsBreakdown =
      <AccountReportModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;

      final payments =
          await FirestoreService.getPaymentsByDate(selectedDate.value);
      final transfers =
          await FirestoreService.getTransfersByDate(selectedDate.value);

      // حساب الإجماليات
      totalPayments.value = payments.fold(
          0.0, (sum, p) => sum + (p['amount'] as num).toDouble());
      totalOperations.value = payments.length;

      final received =
          transfers.where((t) => t['status'] == 'received').toList();
      final pending =
          transfers.where((t) => t['status'] == 'pending').toList();

      totalTransfers.value = received.fold(
          0.0, (sum, t) => sum + (t['amount'] as num).toDouble());
      pendingTransfers.value = pending.length;

      // توزيع حسب الحساب
      final Map<String, double> accountMap = {};
      for (final p in payments) {
        final name = p['accountName'] as String;
        accountMap[name] = (accountMap[name] ?? 0) +
            (p['amount'] as num).toDouble();
      }
      for (final t in received) {
        final name = t['accountName'] as String;
        accountMap[name] = (accountMap[name] ?? 0) +
            (t['amount'] as num).toDouble();
      }

      final total =
          accountMap.values.fold(0.0, (sum, v) => sum + v);

      accountsBreakdown.value = accountMap.entries
          .map((e) => AccountReportModel(
                accountName: e.key,
                amount: e.value,
                percentage: total > 0 ? e.value / total : 0,
              ))
          .toList();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
              primary: Color(0xff1B2A4A),
              onSurface: Color(0xff1B2A4A)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      selectedDate.value = picked;
      await loadData();
    }
  }

  Future<void> exportReport() async {
    try {
      isLoading.value = true;
      final pdf = pw.Document();

      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'تقرير يوم $formattedDate',
                style: pw.TextStyle(
                    fontSize: 20, fontWeight: pw.FontWeight.bold),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${totalPayments.value.toStringAsFixed(0)} ₪'),
                  pw.Text('إجمالي الدفعات',
                      textDirection: pw.TextDirection.rtl),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${totalTransfers.value.toStringAsFixed(0)} ₪'),
                  pw.Text('إجمالي الحوالات الواصلة',
                      textDirection: pw.TextDirection.rtl),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${pendingTransfers.value}'),
                  pw.Text('حوالات معلقة',
                      textDirection: pw.TextDirection.rtl),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('توزيع حسب الحساب',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  textDirection: pw.TextDirection.rtl),
              pw.SizedBox(height: 10),
              ...accountsBreakdown.value.map((item) => pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                          '${item.amount.toStringAsFixed(0)} ₪'),
                      pw.Text(item.accountName,
                          textDirection: pw.TextDirection.rtl),
                    ],
                  )),
            ],
          );
        },
      ));

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  double get maxAmount => accountsBreakdown.isEmpty
      ? 1
      : accountsBreakdown
          .map((e) => e.amount)
          .reduce((a, b) => a > b ? a : b);

  String get formattedDate {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${selectedDate.value.day} '
        '${months[selectedDate.value.month - 1]} '
        '${selectedDate.value.year}';
  }
}