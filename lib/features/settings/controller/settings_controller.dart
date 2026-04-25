import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/core/Routes/app_routes.dart';
import 'package:library_managment/core/Services/auth_service.dart';
import 'package:library_managment/core/Services/firestore_service.dart';
import 'package:library_managment/core/Services/notification_service.dart';
import 'package:library_managment/core/Services/store_service.dart';
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
    _listenEmployeesCount();
  }

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

  void _listenEmployeesCount() {
    FirebaseFirestore.instance.collection('users').snapshots().listen((snap) {
      employeesCount.value = snap.docs.length;
    });
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

    if (confirmed != true) return;

    try {
      // 1. وقف الـ notifications
      await NotificationService.onUserLoggedOut();

      // 2. مسح الـ store id
      StoreService.clearStoreId();

      // 3. Sign out من Firebase و Google
      await AuthService.signOut();

      // 4. ✅ مسح كل الـ GetX controllers
      Get.deleteAll(force: true);

      // 5. روح للـ Login
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      debugPrint('❌ SignOut Error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تسجيل الخروج',
        snackPosition: SnackPosition.BOTTOM,
      );
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

  Future<void> addEmployee(String email) async {
    try {
      Get.snackbar(
        '',
        'تم إضافة الموظف ✅',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      Get.snackbar('', 'حدث خطأ', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
