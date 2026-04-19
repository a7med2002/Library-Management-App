import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/Core/Routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsController extends GetxController {
  final RxString employeeName = ''.obs;
  final RxString employeeEmail = ''.obs;
  final RxString storeName = 'مكتبة دار المقداد'.obs;
  final RxString defaultCurrency = 'شيكل ₪'.obs;
  final RxInt employeesCount = 0.obs;
  final RxString appVersion = '1.0.0'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
    _loadSettings();
  }

  // void _loadUser() {
  //   final user = AuthService.currentUser;
  //   if (user != null) {
  //     employeeName.value = user.name;
  //     employeeEmail.value = user.email;
  //   }
  // }
  void _loadUser() {
    final user = AuthService.currentUser;
    if (user != null) {
      employeeName.value = user.name.isNotEmpty ? user.name : 'مستخدم';
      employeeEmail.value = user.email.isNotEmpty ? user.email : '';
      return;
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      employeeName.value = firebaseUser.displayName ?? 'مستخدم';
      employeeEmail.value = firebaseUser.email ?? '';
    }
  }

  Future<void> _loadSettings() async {
    final data = await FirestoreService.getSettings();
    if (data != null) {
      storeName.value = data['storeName'] ?? storeName.value;
      defaultCurrency.value = data['currency'] ?? defaultCurrency.value;
    }
  }

  Future<void> signOut() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'تسجيل الخروج',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'هل أنت متأكد من تسجيل الخروج؟',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Cairo', color: Colors.grey),
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
      await AuthService.signOut();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> updateStoreName(String name) async {
    storeName.value = name;
    await FirestoreService.updateSettings({'storeName': name});
  }

  Future<void> updateCurrency(String currency) async {
    defaultCurrency.value = currency;
    await FirestoreService.updateSettings({'currency': currency});
  }

  void goToAccounts() => Get.toNamed(AppRoutes.addAccount);
}
