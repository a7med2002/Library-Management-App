import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum AccountType { bank, wallet }

class ReceivingAccountModel {
  final String id;
  final String name;
  final String identifier;
  final AccountType type;
  final IconData icon;
  final DateTime? createdAt;

  const ReceivingAccountModel({
    required this.id,
    required this.name,
    required this.identifier,
    required this.type,
    required this.icon,
    this.createdAt,
  });

  // ─── Firestore ────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'identifier': identifier,
      'type': type.name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory ReceivingAccountModel.fromMap(
      String id, Map<String, dynamic> map) {
    return ReceivingAccountModel(
      id: id,
      name: map['name'] ?? '',
      identifier: map['identifier'] ?? '',
      type: map['type'] == 'bank' ? AccountType.bank : AccountType.wallet,
      icon: map['type'] == 'bank'
          ? Icons.account_balance_rounded
          : Icons.account_balance_wallet_rounded,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}