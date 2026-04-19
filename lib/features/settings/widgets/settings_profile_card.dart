import 'package:flutter/material.dart';
import 'package:library_managment/Core/Constants/app_colors.dart';
import 'package:library_managment/Core/Constants/app_text_styles.dart';

class SettingsProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onSignOut;

  const SettingsProfileCard({
    super.key,
    required this.name,
    required this.email,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sign Out Button
          GestureDetector(
            onTap: onSignOut,
            child: Row(
              children: [
                const Icon(Icons.logout_rounded, color: kErrorColor, size: 18),
                const SizedBox(width: 4),
                Text(
                  'تسجيل الخروج',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: kErrorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Name & Email
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                name,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTextColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                email,
                style: AppTextStyles.caption.copyWith(
                  color: kSecondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name.characters.first : 'م',
                style: AppTextStyles.titleMedium.copyWith(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
