import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/features/payment/model/payment_model.dart';
import '../../../core/services/firestore_service.dart';

enum PaymentFilter { today, thisWeek, custom }

class PaymentsController extends GetxController {
  // final RxList<Map<String, dynamic>> allPayments =
  //     <Map<String, dynamic>>[].obs;
  // final RxList<Map<String, dynamic>> filteredPayments =
  //     <Map<String, dynamic>>[].obs;
  RxList<PaymentModel> allPayments = <PaymentModel>[].obs;
  RxList<PaymentModel> filteredPayments = <PaymentModel>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<PaymentFilter> activeFilter = PaymentFilter.today.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    _listenPayments();
  }

  // void _listenPayments() {
  //   FirestoreService.paymentsStream(selectedDate.value).listen((list) {
  //     allPayments.value = list;
  //     _applyFilter();
  //   });
  // }

  void _listenPayments() {
    FirestoreService.paymentsStream(selectedDate.value).listen((list) {
      allPayments.value = list.map((e) {
        return PaymentModel.fromMap(e, e['id']);
      }).toList();

      _applyFilter();
    });
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _applyFilter();
  }

  void onFilterChanged(PaymentFilter filter) {
    activeFilter.value = filter;
    _applyFilter();
  }

  // void _applyFilter() {
  //   List<Map<String, dynamic>> result = List.from(allPayments);
  //   if (searchQuery.value.isNotEmpty) {
  //     result = result
  //         .where(
  //           (p) => (p['customerName'] as String).contains(searchQuery.value),
  //         )
  //         .toList();
  //   }
  //   filteredPayments.value = result;
  // }

  void _applyFilter() {
    List<PaymentModel> result = List.from(allPayments);

    if (searchQuery.value.isNotEmpty) {
      result = result
          .where((p) => p.customerName.contains(searchQuery.value))
          .toList();
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
}
