enum TransferStatus { received, pending }

class TransferModel {
  final String id;
  final String senderName;
  final String referenceNumber;
  final double amount;
  final String accountName;
  final TransferStatus status;
  final DateTime date;
  final String? notes;

  TransferModel({
    required this.id,
    required this.senderName,
    required this.referenceNumber,
    required this.amount,
    required this.accountName,
    required this.status,
    required this.date,
    this.notes,
  });
}