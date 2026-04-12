import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';

class SettingsController extends GetxController {
  final RxString employeeName = 'أحمد محمد'.obs;
  final RxString employeeEmail = 'ahmed@darmiqdad.com'.obs;
  final RxString storeName = 'مكتبة دار المقداد'.obs;
  final RxString defaultCurrency = 'شيكل ₪'.obs;
  final RxInt employeesCount = 3.obs;
  final RxString appVersion = '1.0.0'.obs;

  Future<void> signOut() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'تسجيل الخروج',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
          textAlign: TextAlign.right,
        ),
        content: Text(
          'هل أنت متأكد من تسجيل الخروج؟',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: Color(0xff6B7280),
          ),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Color(0xff6B7280),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Firebase sign out
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void goToStoreName() {
    // TODO: Navigate to edit store name
  }

  void goToCurrency() {
    // TODO: Navigate to edit currency
  }

  void goToEmployees() {
    // TODO: Navigate to employees management
  }

  void goToContactUs() {
    // TODO: Launch email or URL
  }
}