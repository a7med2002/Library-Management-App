import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/core/services/firestore_service.dart';

enum PaymentFilter { today, thisWeek, custom }

class PaymentsController extends GetxController {
  RxList<Map<String, dynamic>> allPayments = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredPayments = <Map<String, dynamic>>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<PaymentFilter> activeFilter = PaymentFilter.today.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = FirestoreService.paymentsStream(DateTime.now()).listen((
      list,
    ) {
      allPayments.value = list;
      _applyFilter();
    }, onError: (e) => debugPrint('Stream error: $e'));
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _applyFilter();
  }

  void onFilterChanged(PaymentFilter filter) {
    activeFilter.value = filter;
    _applyFilter();
  }

  void _applyFilter() {
    List<Map<String, dynamic>> result = List.from(allPayments);

    if (searchQuery.value.isNotEmpty) {
      result = result
          .where((p) => (p['customerName'] ?? '').contains(searchQuery.value))
          .toList();
    }

    // فلتر التاريخ
    if (activeFilter.value == PaymentFilter.today) {
      final now = DateTime.now();
      result = result.where((p) {
        final timestamp = p['createdAt'];
        if (timestamp == null) return false;
        final date = timestamp.toDate();
        return date.day == now.day &&
            date.month == now.month &&
            date.year == now.year;
      }).toList();
    } else if (activeFilter.value == PaymentFilter.thisWeek) {
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      result = result.where((p) {
        final timestamp = p['createdAt'];
        if (timestamp == null) return false;
        return timestamp.toDate().isAfter(weekAgo);
      }).toList();
    }

    filteredPayments.value = result;
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

  IconData serviceIcon(String type) {
    switch (type) {
      case 'printing':
        return Icons.print_rounded;
      case 'photocopying':
        return Icons.document_scanner_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }

  String serviceLabel(String type) {
    switch (type) {
      case 'printing':
        return 'طباعة';
      case 'photocopying':
        return 'تصوير';
      default:
        return 'خدمة أخرى';
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
