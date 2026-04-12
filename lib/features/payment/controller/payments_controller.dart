import 'package:get/get.dart';
import '../model/payment_model.dart';

enum PaymentFilter { today, thisWeek, custom }

class PaymentsController extends GetxController {
  final RxList<PaymentModel> allPayments = <PaymentModel>[].obs;
  final RxList<PaymentModel> filteredPayments = <PaymentModel>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<PaymentFilter> activeFilter = PaymentFilter.today.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
    _applyFilter();
  }

  void _loadDummyData() {
    allPayments.value = [
      PaymentModel(
        id: '1',
        customerName: 'أحمد محمد',
        amount: 150,
        serviceType: ServiceType.printing,
        accountName: 'بنك — أحمد',
        date: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      PaymentModel(
        id: '2',
        customerName: 'سارة عبدالله',
        amount: 75,
        serviceType: ServiceType.photocopying,
        accountName: 'محفظة BI — أحمد',
        date: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      PaymentModel(
        id: '3',
        customerName: 'فاطمة حسن',
        amount: 320,
        serviceType: ServiceType.other,
        accountName: 'جوال باي — أحمد',
        date: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      PaymentModel(
        id: '4',
        customerName: 'عمر خالد',
        amount: 200,
        serviceType: ServiceType.printing,
        accountName: 'بنك — أحمد',
        date: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ];
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
    List<PaymentModel> result = List.from(allPayments);

    // Search
    if (searchQuery.value.isNotEmpty) {
      result = result
          .where((p) => p.customerName.contains(searchQuery.value))
          .toList();
    }

    // Date filter
    final now = DateTime.now();
    if (activeFilter.value == PaymentFilter.today) {
      result = result
          .where((p) =>
              p.date.day == now.day &&
              p.date.month == now.month &&
              p.date.year == now.year)
          .toList();
    } else if (activeFilter.value == PaymentFilter.thisWeek) {
      final weekAgo = now.subtract(const Duration(days: 7));
      result = result.where((p) => p.date.isAfter(weekAgo)).toList();
    }

    filteredPayments.value = result;
  }

  String formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final m = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'ص' : 'م';
    return '$hour:$m $period';
  }
}