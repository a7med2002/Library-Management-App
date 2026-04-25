import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/core/Services/firestore_service.dart';
import 'package:library_managment/core/Services/pdf_service.dart';
import 'package:library_managment/core/Services/store_service.dart';
import 'package:library_managment/core/services/auth_service.dart';
import 'package:library_managment/features/today%20report/model/report_model.dart';


class ReportController extends GetxController {
  final RxBool isAdmin = false.obs;
  final RxBool isLoading = false.obs;
  // ─── Date Range ───────────────────────────────────────────
  final Rx<DateTime> fromDate = DateTime.now().obs;
  final Rx<DateTime> toDate = DateTime.now().obs;
  final RxBool isRangeMode = false.obs;

  // ─── Stats ────────────────────────────────────────────────
  final RxDouble totalPayments = 0.0.obs;
  final RxInt totalOperations = 0.obs;
  final RxDouble totalIncoming = 0.0.obs;
  final RxInt pendingCount = 0.obs;
  final RxDouble totalOutgoing = 0.0.obs;
  final RxDouble netTotal = 0.0.obs;
  final RxList<AccountReportModel> accountsBreakdown =
      <AccountReportModel>[].obs;

  // ─── Raw Data ─────────────────────────────────────────────
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> _incomingTransfers = [];
  List<Map<String, dynamic>> _outgoingTransfers = [];

  // حد أقصى للموظف
  static const int _maxEmployeeDays = 7;

  @override
  void onInit() {
    super.onInit();
    _checkAdminStatus();
    loadData();
  }

  Future<void> _checkAdminStatus() async {
    final email = AuthService.currentUser?.email ?? '';
    isAdmin.value = await StoreService.isAdmin(email);
    debugPrint('👤 Is Admin: ${isAdmin.value}');
  }

  // ─── حساب أقدم تاريخ مسموح ─────────────────────────────
  DateTime get _minAllowedDate {
    if (isAdmin.value) {
      // Admin → شهر كامل
      return DateTime.now().subtract(const Duration(days: 30));
    }
    // Employee → أسبوع فقط
    return DateTime.now().subtract(const Duration(days: _maxEmployeeDays));
  }

  // ─── Pick Single Date ─────────────────────────────────────
  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate.value,
      // ✅ أقدم تاريخ حسب الصلاحية
      firstDate: _minAllowedDate,
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xff1B2A4A),
            onSurface: Color(0xff1B2A4A),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      fromDate.value = picked;
      toDate.value = picked;
      isRangeMode.value = false;
      await loadData();
    }
  }

  // ─── Pick Date Range ──────────────────────────────────────
  Future<void> pickDateRange(BuildContext context) async {
    // ✅ تحقق من الصلاحية قبل ما يفتح الـ picker
    if (!isAdmin.value) {
      // موظف — تحقق إذا النطاق أكبر من أسبوع
      _showEmployeeLimitWarning(context);
    }

    final picked = await showDateRangePicker(
      context: context,
      firstDate: _minAllowedDate, // ✅ محدود حسب الصلاحية
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: fromDate.value, end: toDate.value),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xff1B2A4A),
            onSurface: Color(0xff1B2A4A),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      // ✅ تحقق من النطاق للموظف
      if (!isAdmin.value) {
        final diff = picked.end.difference(picked.start).inDays;
        if (diff > _maxEmployeeDays) {
          Get.snackbar(
            '⚠️ تنبيه',
            'لا يمكنك تحميل كشف لأكثر من $_maxEmployeeDays أيام',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.shade50,
            colorText: Colors.orange.shade800,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
          return;
        }
      }

      fromDate.value = picked.start;
      toDate.value = picked.end;
      isRangeMode.value = true;
      await loadData();
    }
  }

  void _showEmployeeLimitWarning(BuildContext context) {
    Get.snackbar(
      'ℹ️ تنبيه',
      'يمكنك تحميل كشف لآخر $_maxEmployeeDays أيام فقط',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.shade50,
      colorText: Colors.blue.shade800,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  // ─── Load Data ────────────────────────────────────────────

  Future<void> loadData() async {
    try {
      isLoading.value = true;

      // جلب البيانات لكل يوم في النطاق
      _payments = [];
      _incomingTransfers = [];
      _outgoingTransfers = [];

      DateTime current = fromDate.value;
      while (!current.isAfter(toDate.value)) {
        final p = await FirestoreService.getPaymentsByDate(current);
        final t = await FirestoreService.getTransfersByDate(current);
        final o = await FirestoreService.getOutgoingTransfersByDate(current);
        _payments.addAll(p);
        _incomingTransfers.addAll(t);
        _outgoingTransfers.addAll(o);
        current = current.add(const Duration(days: 1));
      }

      _calculateStats();
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateStats() {
    totalPayments.value = _payments.fold(
      0.0,
      (s, p) => s + (p['amount'] as num).toDouble(),
    );
    totalOperations.value = _payments.length;

    final received = _incomingTransfers
        .where((t) => t['status'] == 'received')
        .toList();
    totalIncoming.value = received.fold(
      0.0,
      (s, t) => s + (t['amount'] as num).toDouble(),
    );
    pendingCount.value = _incomingTransfers
        .where((t) => t['status'] == 'pending')
        .length;

    totalOutgoing.value = _outgoingTransfers.fold(
      0.0,
      (s, o) => s + (o['amount'] as num).toDouble(),
    );

    netTotal.value =
        totalPayments.value + totalIncoming.value - totalOutgoing.value;

    // Breakdown by account
    final Map<String, double> accountMap = {};
    for (final p in _payments) {
      final name = p['accountName'] as String;
      accountMap[name] =
          (accountMap[name] ?? 0) + (p['amount'] as num).toDouble();
    }
    for (final t in received) {
      final name = t['accountName'] as String;
      accountMap[name] =
          (accountMap[name] ?? 0) + (t['amount'] as num).toDouble();
    }

    final total = accountMap.values.fold(0.0, (s, v) => s + v);
    accountsBreakdown.value = accountMap.entries
        .map(
          (e) => AccountReportModel(
            accountName: e.key,
            amount: e.value,
            percentage: total > 0 ? e.value / total : 0,
          ),
        )
        .toList();
  }

  // ─── Export — تحقق إضافي قبل التصدير ────────────────────
  Future<void> exportReport() async {
    // ✅ تحقق نهائي قبل التصدير
    if (!isAdmin.value) {
      final diff = toDate.value.difference(fromDate.value).inDays;
      if (diff > _maxEmployeeDays) {
        Get.snackbar(
          '❌ غير مسموح',
          'لا يمكنك تصدير كشف لأكثر من $_maxEmployeeDays أيام',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red.shade800,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        return;
      }
    }

    try {
      isLoading.value = true;
      final storeName = AuthService.currentUser?.name ?? 'مكتبة دار المقداد';

      await PdfService.generateDailyReport(
        fromDate: fromDate.value,
        toDate: toDate.value,
        payments: _payments,
        incomingTransfers: _incomingTransfers,
        outgoingTransfers: _outgoingTransfers,
        storeName: storeName,
      );
    } catch (e) {
      debugPrint('❌ PDF Error: $e');
      Get.snackbar(
        '',
        'حدث خطأ في التصدير',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────
  String get formattedDateLabel {
    if (isRangeMode.value) {
      return '${_fmt(fromDate.value)} — ${_fmt(toDate.value)}';
    }
    return _fmt(fromDate.value);
  }

  String _fmt(DateTime d) {
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
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  double get maxAmount => accountsBreakdown.isEmpty
      ? 1
      : accountsBreakdown.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
}
