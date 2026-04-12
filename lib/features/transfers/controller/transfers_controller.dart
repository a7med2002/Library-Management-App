import 'package:get/get.dart';
import '../model/transfer_model.dart';

enum TransferFilter { all, received, pending }

class TransfersController extends GetxController {
  final RxList<TransferModel> allTransfers = <TransferModel>[].obs;
  final RxList<TransferModel> filteredTransfers = <TransferModel>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<TransferFilter> activeFilter = TransferFilter.all.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
    _applyFilter();
  }

  void _loadDummyData() {
    allTransfers.value = [
      TransferModel(
        id: '1',
        senderName: 'خالد يوسف',
        referenceNumber: 'REF-20240115-001',
        amount: 500,
        accountName: 'بنك — أحمد',
        status: TransferStatus.pending,
        date: DateTime(2024, 1, 15),
      ),
      TransferModel(
        id: '2',
        senderName: 'محمود علي',
        referenceNumber: 'REF-20240115-002',
        amount: 1200,
        accountName: 'محفظة BI — أحمد',
        status: TransferStatus.received,
        date: DateTime(2024, 1, 15),
      ),
      TransferModel(
        id: '3',
        senderName: 'عبدالرحمن سعيد',
        referenceNumber: 'REF-20240114-003',
        amount: 800,
        accountName: 'جوال باي — أحمد',
        status: TransferStatus.received,
        date: DateTime(2024, 1, 14),
      ),
      TransferModel(
        id: '4',
        senderName: 'ياسر عمر',
        referenceNumber: 'REF-20240114-004',
        amount: 350,
        accountName: 'محفظة — عمرو',
        status: TransferStatus.pending,
        date: DateTime(2024, 1, 14),
      ),
    ];
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
          .where((t) =>
              t.senderName.contains(searchQuery.value) ||
              t.referenceNumber.contains(searchQuery.value))
          .toList();
    }

    if (activeFilter.value == TransferFilter.received) {
      result = result
          .where((t) => t.status == TransferStatus.received)
          .toList();
    } else if (activeFilter.value == TransferFilter.pending) {
      result = result
          .where((t) => t.status == TransferStatus.pending)
          .toList();
    }

    filteredTransfers.value = result;
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}