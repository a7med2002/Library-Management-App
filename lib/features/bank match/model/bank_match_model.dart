enum MatchStatus { matched, unmatched }

class BankTransactionModel {
  final String referenceNumber;
  final double amount;
  final String senderName;
  final MatchStatus status;

  BankTransactionModel({
    required this.referenceNumber,
    required this.amount,
    required this.senderName,
    required this.status,
  });
}