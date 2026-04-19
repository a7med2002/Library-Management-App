import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory TransferModel.fromMap(Map<String, dynamic> map, String id) {
    return TransferModel(
      id: id,
      senderName: map['senderName'] ?? '',
      referenceNumber: map['referenceNumber'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      accountName: map['accountName'] ?? '',
      status: map['status'] == 'received'
          ? TransferStatus.received
          : TransferStatus.pending,
      // ✅ استخدم createdAt مع null safety
      date: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      notes: map['notes'] ?? '',
    );
  }
}