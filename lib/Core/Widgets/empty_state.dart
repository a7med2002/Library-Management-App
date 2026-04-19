import 'package:flutter/material.dart';
import 'package:library_managment/Core/Constants/app_colors.dart';
import 'package:library_managment/Core/Constants/app_text_styles.dart';


class EmptyState extends StatelessWidget {
  final String message;

  const EmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: kHintColor),
          const SizedBox(height: 12),
          Text(message,
              style: AppTextStyles.bodySmall.copyWith(color: kHintColor)),
        ],
      ),
    );
  }
}