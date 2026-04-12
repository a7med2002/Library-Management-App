import 'package:flutter/material.dart';

enum AccountType { bank, wallet }

class ReceivingAccountModel {
  final String id;
  final String name;
  final String identifier;
  final AccountType type;
  final IconData icon;

  const ReceivingAccountModel({
    required this.id,
    required this.name,
    required this.identifier,
    required this.type,
    required this.icon,
  });
}

// ─── Static Dummy Accounts ────────────────────────────────────
class AppAccounts {
  static const List<ReceivingAccountModel> all = [
    ReceivingAccountModel(
      id: '1',
      name: 'بنك — أحمد',
      identifier: 'PS12 3456 7890',
      type: AccountType.bank,
      icon: Icons.account_balance_rounded,
    ),
    ReceivingAccountModel(
      id: '2',
      name: 'محفظة BI — أحمد',
      identifier: 'XXXXXXX-059',
      type: AccountType.wallet,
      icon: Icons.grid_view_rounded,
    ),
    ReceivingAccountModel(
      id: '3',
      name: 'جوال باي — أحمد',
      identifier: 'XXXXXXX-059',
      type: AccountType.wallet,
      icon: Icons.add_to_home_screen_rounded,
    ),
    ReceivingAccountModel(
      id: '4',
      name: 'محفظة — عمرو',
      identifier: 'XXXXXXX-056',
      type: AccountType.wallet,
      icon: Icons.credit_card_rounded,
    ),
  ];
}