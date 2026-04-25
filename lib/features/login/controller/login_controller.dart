import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/core/Routes/app_routes.dart';
import 'package:library_managment/core/Services/auth_service.dart';
import 'package:library_managment/core/Services/notification_service.dart';

class LoginController extends GetxController {
  final RxBool isLoading = false.obs;

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final user = await AuthService.signInWithGoogle();
      if (user != null) {
        await NotificationService.onUserLoggedIn();
        Get.offAllNamed(AppRoutes.main);
      }
    } catch (e) {
      debugPrint('❌ Login Error: $e'); // شوف الـ error الحقيقي
      Get.snackbar(
        'خطأ',
        e.toString(), // ✅ مؤقتاً اعرض الـ error الحقيقي
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
