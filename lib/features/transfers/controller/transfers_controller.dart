import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/firestore_service.dart';

enum TransferFilter { all, received, pending }

class TransfersController extends GetxController {
  final RxList<Map<String, dynamic>> allTransfers =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredTransfers =
      <Map<String, dynamic>>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<TransferFilter> activeFilter = TransferFilter.all.obs;

  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = FirestoreService.transfersStream().listen((list) {
      allTransfers.value = list;
      _applyFilter();
    }, onError: (e) => debugPrint('❌ Transfers stream error: $e'));
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _applyFilter();
  }

  void onFilterChanged(TransferFilter filter) {
    activeFilter.value = filter;
    _applyFilter();
  }

  void _applyFilter() {
    List<Map<String, dynamic>> result = List.from(allTransfers);

    if (searchQuery.value.isNotEmpty) {
      result = result
          .where(
            (t) =>
                (t['senderName'] ?? '').contains(searchQuery.value) ||
                (t['referenceNumber'] ?? '').contains(searchQuery.value),
          )
          .toList();
    }

    if (activeFilter.value == TransferFilter.received) {
      result = result.where((t) => t['status'] == 'received').toList();
    } else if (activeFilter.value == TransferFilter.pending) {
      result = result.where((t) => t['status'] == 'pending').toList();
    }

    filteredTransfers.value = result;
  }

  Future<void> updateStatus(String id, String status) async {
    await FirestoreService.updateTransferStatus(id, status);
  }

  String formatDate(dynamic timestamp) {
    if (timestamp == null) return '';

    // ✅ تعامل مع Timestamp و DateTime معاً
    final DateTime date = timestamp is DateTime
        ? timestamp
        : timestamp.toDate();

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
