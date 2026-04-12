import 'package:flutter/material.dart';

enum ServiceType { printing, photocopying, other }

enum PaymentStatus { received }

class PaymentModel {
  final String id;
  final String customerName;
  final double amount;
  final ServiceType serviceType;
  final String accountName;
  final DateTime date;

  PaymentModel({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.serviceType,
    required this.accountName,
    required this.date,
  });

  String get serviceTypeAr {
    switch (serviceType) {
      case ServiceType.printing:
        return 'طباعة';
      case ServiceType.photocopying:
        return 'تصوير';
      case ServiceType.other:
        return 'خدمة أخرى';
    }
  }

  IconData get serviceIcon {
    switch (serviceType) {
      case ServiceType.printing:
        return Icons.print_rounded;
      case ServiceType.photocopying:
        return Icons.document_scanner_rounded;
      case ServiceType.other:
        return Icons.miscellaneous_services_rounded;
    }
  }
}