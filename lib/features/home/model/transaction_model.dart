enum TransactionType { payment, transfer }
enum TransactionStatus { received, pending }

class TransactionModel {
  final String id;
  final String customerName;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final String accountName;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.type,
    required this.status,
    required this.accountName,
    required this.date,
  });
}