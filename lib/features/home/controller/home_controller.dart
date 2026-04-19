import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/Core/Routes/app_routes.dart';
import 'package:library_managment/Core/Services/objectbox_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';

class HomeController extends GetxController {
  final RxString employeeName = ''.obs;
  final RxDouble todayTotal = 0.0.obs;
  final RxInt pendingTransfers = 0.obs;
  final RxList<Map<String, dynamic>> recentTransactions =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // تأكد إن ObjectBox جاهز
      await ObjectBoxService.init();
      _loadUser();
      _listenTodayData();
    } catch (e) {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void _loadUser() {
    final user = AuthService.currentUser;
    if (user != null) {
      employeeName.value = user.name.split(' ').first;
    }
  }

  void _listenTodayData() {
    final today = DateTime.now();

    // ─── Payments listener ────────────────────────────
    FirestoreService.paymentsStream(today).listen((payments) {
      _lastPayments = payments;
      _calculateTotal();
      _mergeRecentTransactions(payments: payments);
    });

    // ─── Transfers listener ───────────────────────────
    FirestoreService.transfersStream().listen((transfers) {
      _lastTransfers = transfers;
      pendingTransfers.value = transfers
          .where((t) => t['status'] == 'pending')
          .length;
      _calculateTotal();
      _mergeRecentTransactions(transfers: transfers);
    });
  }

  void _calculateTotal() {
    // إجمالي المدفوعات
    final paymentsTotal = _lastPayments.fold(
      0.0,
      (sum, p) => sum + (p['amount'] as num).toDouble(),
    );

    // إجمالي الحوالات الواصلة فقط (اليوم)
    final today = DateTime.now();
    final todayReceivedTransfers = _lastTransfers.where((t) {
      if (t['status'] != 'received') return false;
      final timestamp = t['createdAt'];
      if (timestamp == null) return false;
      final date = timestamp.toDate();
      return date.day == today.day &&
          date.month == today.month &&
          date.year == today.year;
    }).toList();

    final transfersTotal = todayReceivedTransfers.fold(
      0.0,
      (sum, t) => sum + (t['amount'] as num).toDouble(),
    );

    // المجموع الكلي
    todayTotal.value = paymentsTotal + transfersTotal;
  }

  List<Map<String, dynamic>> _lastPayments = [];
  List<Map<String, dynamic>> _lastTransfers = [];

  void _mergeRecentTransactions({
    List<Map<String, dynamic>>? payments,
    List<Map<String, dynamic>>? transfers,
  }) {
    if (payments != null) _lastPayments = payments;
    if (transfers != null) _lastTransfers = transfers;

    final all = [
      ..._lastPayments.map((p) => {...p, 'transactionType': 'payment'}),
      ..._lastTransfers.map((t) => {...t, 'transactionType': 'transfer'}),
    ];

    // رتّب حسب الأحدث
    all.sort((a, b) {
      final aDate = a['createdAt'];
      final bDate = b['createdAt'];
      if (aDate == null || bDate == null) return 0;
      return bDate.compareTo(aDate);
    });

    // خذ آخر 5
    recentTransactions.value = all.take(5).toList();
  }

  IconData getTransactionIcon(Map<String, dynamic> tx) {
    if (tx['transactionType'] == 'transfer') {
      return Icons.swap_horiz_rounded;
    }
    switch (tx['serviceType']) {
      case 'printing':
        return Icons.print_rounded;
      case 'photocopying':
        return Icons.document_scanner_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }

  Color getIconColor(Map<String, dynamic> tx) {
    return tx['transactionType'] == 'transfer'
        ? const Color(0xff4CAF50)
        : const Color(0xffC9A84C);
  }

  Color getIconBgColor(Map<String, dynamic> tx) {
    return tx['transactionType'] == 'transfer'
        ? const Color(0xffE8F5E9)
        : const Color(0xffFFF3E0);
  }

  bool isReceived(Map<String, dynamic> tx) {
    if (tx['transactionType'] == 'payment') return true;
    return tx['status'] == 'received';
  }

  String formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    final DateTime date = timestamp is DateTime
        ? timestamp
        : timestamp.toDate();
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final m = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'ص' : 'م';
    return '$hour:$m $period';
  }
}
