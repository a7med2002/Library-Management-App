import 'package:get/get.dart';
import 'package:library_managment/features/transfers/model/transfer_model.dart';
import '../../../core/services/firestore_service.dart';

enum TransferFilter { all, received, pending }

class TransfersController extends GetxController {
  RxList<TransferModel> allTransfers = <TransferModel>[].obs;
  RxList<TransferModel> filteredTransfers = <TransferModel>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<TransferFilter> activeFilter = TransferFilter.all.obs;

  @override
  void onInit() {
    super.onInit();
    _listenTransfers();
  }

  void _listenTransfers() {
    FirestoreService.transfersStream().listen((list) {
      allTransfers.value = list.map((e) {
        return TransferModel.fromMap(e, e['id']);
      }).toList();

      _applyFilter();
    });
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
    List<TransferModel> result = List.from(allTransfers);

    if (searchQuery.value.isNotEmpty) {
      result = result
          .where(
            (t) =>
                t.senderName.contains(searchQuery.value) ||
                t.referenceNumber.contains(searchQuery.value),
          )
          .toList();
    }

    if (activeFilter.value == TransferFilter.received) {
      result = result
          .where((t) => t.status == TransferStatus.received)
          .toList();
    } else if (activeFilter.value == TransferFilter.pending) {
      result = result.where((t) => t.status == TransferStatus.pending).toList();
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
}
