import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/core/Constants/app_colors.dart';
import 'package:library_managment/core/Routes/app_routes.dart';
import 'package:library_managment/core/Services/auth_service.dart';
import 'package:library_managment/core/Services/firestore_service.dart';

class HomeController extends GetxController {
  final RxString employeeName = ''.obs;
  final RxDouble todayTotal = 0.0.obs;
  final RxInt pendingTransfers = 0.obs;
  final RxList<Map<String, dynamic>> recentTransactions =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  List<Map<String, dynamic>> _lastPayments = [];
  List<Map<String, dynamic>> _lastTransfers = [];

  final RxDouble todayOutgoing = 0.0.obs;
  List<Map<String, dynamic>> _lastOutgoing = [];

  StreamSubscription? _paymentsSubscription;
  StreamSubscription? _transfersSubscription;
  StreamSubscription? _outgoingSubscription;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
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

    _paymentsSubscription = FirestoreService.paymentsStream(today).listen((
      payments,
    ) {
      _lastPayments = payments;
      _calculateTotal();
      _mergeRecentTransactions(payments: payments);
    }, onError: (e) => debugPrint('Payments stream error: $e'));

    _transfersSubscription = FirestoreService.transfersStream().listen((
      transfers,
    ) {
      _lastTransfers = transfers;
      pendingTransfers.value = transfers
          .where((t) => t['status'] == 'pending')
          .length;
      _calculateTotal();
      _mergeRecentTransactions(transfers: transfers);
    }, onError: (e) => debugPrint('Transfers stream error: $e'));

    _outgoingSubscription = FirestoreService.outgoingTransfersStream().listen((
      outgoing,
    ) {
      _lastOutgoing = outgoing;
      _calculateOutgoing();
      _mergeRecentTransactions(outgoing: outgoing);
    }, onError: (e) => debugPrint('Outgoing stream error: $e'));
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

  void _mergeRecentTransactions({
    List<Map<String, dynamic>>? payments,
    List<Map<String, dynamic>>? transfers,
    List<Map<String, dynamic>>? outgoing,
  }) {
    if (payments != null) _lastPayments = payments;
    if (transfers != null) _lastTransfers = transfers;
    if (outgoing != null) _lastOutgoing = outgoing;

    final all = [
      ..._lastPayments.map((p) => {...p, 'transactionType': 'payment'}),
      ..._lastTransfers.map((t) => {...t, 'transactionType': 'transfer'}),
      ..._lastOutgoing.map((o) => {...o, 'transactionType': 'outgoing'}),
    ];

    all.sort((a, b) {
      final aDate = a['createdAt'];
      final bDate = b['createdAt'];
      if (aDate == null || bDate == null) return 0;
      return bDate.compareTo(aDate);
    });

    recentTransactions.value = all.take(5).toList();
  }

  void _calculateOutgoing() {
    final today = DateTime.now();
    final todayOutgoing = _lastOutgoing.where((t) {
      final timestamp = t['createdAt'];
      if (timestamp == null) return false;
      final date = timestamp.toDate();
      return date.day == today.day &&
          date.month == today.month &&
          date.year == today.year;
    }).toList();

    this.todayOutgoing.value = todayOutgoing.fold(
      0.0,
      (sum, t) => sum + (t['amount'] as num).toDouble(),
    );
  }

  IconData getTransactionIcon(Map<String, dynamic> tx) {
    switch (tx['transactionType']) {
      case 'payment':
        switch (tx['serviceType']) {
          case 'printing':
            return Icons.print_rounded;
          case 'photocopying':
            return Icons.document_scanner_rounded;
          default:
            return Icons.miscellaneous_services_rounded;
        }
      case 'transfer':
        return Icons.arrow_downward_rounded; // وارد
      case 'outgoing':
        return Icons.arrow_upward_rounded; // صادر
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  Color getIconColor(Map<String, dynamic> tx) {
    switch (tx['transactionType']) {
      case 'payment':
        return kAccentColor;
      case 'transfer':
        return kSuccessColor;
      case 'outgoing':
        return kErrorColor;
      default:
        return kSecondaryTextColor;
    }
  }

  Color getIconBgColor(Map<String, dynamic> tx) {
    switch (tx['transactionType']) {
      case 'payment':
        return kIconBgPayment;
      case 'transfer':
        return kIconBgTransfer;
      case 'outgoing':
        return kErrorColor.withOpacity(0.1);
      default:
        return kBackgroundColor;
    }
  }

  bool? isReceived(Map<String, dynamic> tx) {
    if (tx['transactionType'] == 'outgoing') return null;
    if (tx['transactionType'] == 'payment') return true;
    return tx['status'] == 'received';
  }

  // ✅ الـ badge label
  String getBadgeLabel(Map<String, dynamic> tx) {
    if (tx['transactionType'] == 'outgoing') {
      return _categoryLabel(tx['category'] ?? '');
    }
    if (tx['transactionType'] == 'payment') return '✅ مدفوعة';
    return tx['status'] == 'received' ? '✅ واصلة' : '⏳ معلقة';
  }

  Color getBadgeColor(Map<String, dynamic> tx) {
    if (tx['transactionType'] == 'outgoing') return kErrorColor;
    if (tx['transactionType'] == 'payment') return kSuccessColor;
    return tx['status'] == 'received' ? kSuccessColor : kPendingColor;
  }

  Color getBadgeBgColor(Map<String, dynamic> tx) {
    if (tx['transactionType'] == 'outgoing') {
      return kErrorColor.withOpacity(0.1);
    }
    if (tx['transactionType'] == 'payment') {
      return kSuccessColor.withOpacity(0.12);
    }
    return tx['status'] == 'received'
        ? kSuccessColor.withOpacity(0.12)
        : kPendingColor.withOpacity(0.12);
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'supplies':
        return '🛍 مستلزمات';
      case 'bills':
        return '🧾 فواتير';
      case 'salaries':
        return '👥 رواتب';
      default:
        return '📦 أخرى';
    }
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

  @override
  void onClose() {
    _paymentsSubscription?.cancel();
    _transfersSubscription?.cancel();
    _outgoingSubscription?.cancel();
    super.onClose();
  }
}
