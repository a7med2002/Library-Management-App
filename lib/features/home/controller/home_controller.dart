import 'package:get/get.dart';
import '../model/transaction_model.dart';

class HomeController extends GetxController {
  final RxString employeeName = 'أحمد'.obs;
  final RxDouble todayTotal = 2245.0.obs;
  final RxInt pendingTransfers = 3.obs;
  final RxList<TransactionModel> recentTransactions = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
  }

  void _loadDummyData() {
    recentTransactions.value = [
      TransactionModel(
        id: '1',
        customerName: 'أحمد محمد',
        amount: 150,
        type: TransactionType.payment,
        status: TransactionStatus.received,
        accountName: 'بنك — أحمد',
        date: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      TransactionModel(
        id: '2',
        customerName: 'خالد يوسف',
        amount: 500,
        type: TransactionType.transfer,
        status: TransactionStatus.pending,
        accountName: 'بنك — أحمد',
        date: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      TransactionModel(
        id: '3',
        customerName: 'سارة عبدالله',
        amount: 75,
        type: TransactionType.payment,
        status: TransactionStatus.received,
        accountName: 'محفظة BI — أحمد',
        date: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      TransactionModel(
        id: '4',
        customerName: 'محمود علي',
        amount: 1200,
        type: TransactionType.transfer,
        status: TransactionStatus.received,
        accountName: 'محفظة BI — أحمد',
        date: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      ),
      TransactionModel(
        id: '5',
        customerName: 'فاطمة حسن',
        amount: 320,
        type: TransactionType.payment,
        status: TransactionStatus.received,
        accountName: 'جوال باي — أحمد',
        date: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  String formatTime(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'ص' : 'م';
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    return '$hour:$m $period';
  }
}